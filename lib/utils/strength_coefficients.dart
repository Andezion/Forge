class StrengthCoefficients {
  static double wilks(double bodyWeight, double totalLifted,
      {bool isMale = true}) {
    if (bodyWeight <= 0 || totalLifted <= 0) return 0.0;
    final double a, b, c, d, e, f;
    if (isMale) {
      a = -216.0475144;
      b = 16.2606339;
      c = -0.002388645;
      d = -0.00113732;
      e = 7.01863E-06;
      f = -1.291E-08;
    } else {
      a = 594.31747775582;
      b = -27.23842536447;
      c = 0.82112226871;
      d = -0.00930733913;
      e = 0.00004731582;
      f = -0.00000009054;
    }
    final x = bodyWeight;
    final denom = a +
        b * x +
        c * x * x +
        d * x * x * x +
        e * x * x * x * x +
        f * x * x * x * x * x;
    if (denom <= 0) return 0.0;
    return 500 / denom * totalLifted;
  }

  static double dots(double bodyWeight, double totalLifted,
      {bool isMale = true}) {
    if (bodyWeight <= 0 || totalLifted <= 0) return 0.0;
    final double a, b, c, d, e;
    if (isMale) {
      a = -0.0000010930;
      b = 0.0007391293;
      c = -0.1918759221;
      d = 24.0900756;
      e = -307.75076;
    } else {
      a = -0.0000010706;
      b = 0.0005158568;
      c = -0.1126655495;
      d = 13.6175032;
      e = -57.96288;
    }
    final bw = bodyWeight;
    final denom =
        a * bw * bw * bw * bw * bw + b * bw * bw * bw * bw + c * bw * bw * bw +
            d * bw * bw + e * bw + 1;
    if (denom <= 0) return 0.0;
    return 500 / denom * totalLifted;
  }
}
