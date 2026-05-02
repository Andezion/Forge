const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onRequest } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
const fetch = require("node-fetch");

initializeApp();

const db = getFirestore();

const MALE_WEIGHT_CLASSES = ["59", "66", "74", "83", "93", "105", "120", "120+"];
const FEMALE_WEIGHT_CLASSES = ["47", "52", "57", "63", "69", "76", "84", "84+"];

const EVENTS = [
  { code: "S", name: "squat" },
  { code: "B", name: "bench" },
  { code: "D", name: "deadlift" },
];

async function fetchTopRecord(sex, weightClassCode, eventCode) {
  const url =
    `https://www.openpowerlifting.org/api/rankings?` +
    `start=0&end=1` +
    `&federation=IPF` +
    `&sex=${sex}` +
    `&ageclass=Open` +
    `&equipment=Raw` +
    `&weightclasscode=${encodeURIComponent(weightClassCode)}` +
    `&event=${eventCode}` +
    `&lang=en` +
    `&units=kg`;

  const res = await fetch(url, {
    headers: {
      "User-Agent": "ForgeApp/1.0 (powerlifting training app; contact: support@forge.app)",
      "Accept": "application/json",
    },
    timeout: 10000,
  });

  if (!res.ok) {
    throw new Error(`OPL API ${res.status} for ${sex}/${weightClassCode}/${eventCode}`);
  }

  const data = await res.json();

  // OPL returns { rows: [[rank, name, fed, date, country, wckg, bwkg, age, equip, ...columns]], total_length }
  // Column layout for event-specific (S/B/D): ... the relevant best is in a specific column.
  // For single-event queries, column index 9 = Total (which equals the best lift for single event).
  if (!data.rows || data.rows.length === 0) return null;

  const row = data.rows[0];
  // row[1] = FullName, row[4] = Country, row[9] = Total (best lift for single event)
  const athleteName = row[1] || "Unknown";
  const country = row[4] || "";
  const bestWeight = parseFloat(row[9]);

  if (!bestWeight || bestWeight <= 0) return null;

  return { athleteName, country, weight: bestWeight };
}

async function updateAllRecords() {
  const genderConfigs = [
    { sex: "M", gender: "male", classes: MALE_WEIGHT_CLASSES },
    { sex: "F", gender: "female", classes: FEMALE_WEIGHT_CLASSES },
  ];

  let updated = 0;
  let errors = 0;

  for (const { sex, gender, classes } of genderConfigs) {
    for (const wc of classes) {
      for (const { code, name: exercise } of EVENTS) {
        // Firestore doc key: squat_83_male_raw  (120+ → 120p)
        const wcKey = wc.replace("+", "p");
        const docId = `${exercise}_${wcKey}_${gender}_raw`;

        try {
          const result = await fetchTopRecord(sex, wc, code);
          if (!result) {
            console.warn(`[WR] No result for ${docId}`);
            errors++;
            continue;
          }

          await db.collection("world_records").doc(docId).set(
            {
              exercise,
              weightClass: `-${wc} kg`.replace("-120+", "+120"),
              gender,
              equipped: false,
              weight: result.weight,
              athleteName: result.athleteName,
              country: result.country,
              federation: "IPF",
              updatedAt: Timestamp.now(),
            },
            { merge: true }
          );

          updated++;
          console.log(`[WR] Updated ${docId}: ${result.weight} kg (${result.athleteName})`);

          // Pause between requests to avoid rate-limiting
          await new Promise((r) => setTimeout(r, 500));
        } catch (err) {
          console.error(`[WR] Error updating ${docId}:`, err.message);
          errors++;
          // Continue with next record
        }
      }
    }
  }

  return { updated, errors };
}

// Scheduled: every Sunday at 03:00 UTC
exports.updateWorldRecords = onSchedule(
  {
    schedule: "0 3 * * 0",
    timeZone: "UTC",
    timeoutSeconds: 540,
    memory: "256MiB",
  },
  async () => {
    console.log("[WR] Starting scheduled world records update...");
    const { updated, errors } = await updateAllRecords();
    console.log(`[WR] Done. Updated: ${updated}, Errors: ${errors}`);
  }
);

// Manual trigger via HTTP (for initial seed / admin use)
// Call: POST https://<region>-<project>.cloudfunctions.net/triggerWorldRecordsUpdate
// Header: x-admin-key: <your secret key from Firebase config>
exports.triggerWorldRecordsUpdate = onRequest(
  { timeoutSeconds: 540, memory: "256MiB" },
  async (req, res) => {
    const adminKey = process.env.ADMIN_KEY || "";
    const providedKey = req.headers["x-admin-key"] || "";

    if (!adminKey || providedKey !== adminKey) {
      res.status(403).json({ error: "Forbidden" });
      return;
    }

    console.log("[WR] Manual trigger started...");
    try {
      const { updated, errors } = await updateAllRecords();
      res.json({ success: true, updated, errors });
    } catch (err) {
      console.error("[WR] Manual trigger error:", err);
      res.status(500).json({ error: err.message });
    }
  }
);
