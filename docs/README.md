# Forge Documentation Site

This directory contains the GitHub Pages documentation website for Forge.

## Live Site

Once deployed, the site will be available at: `https://andezion.github.io/Forge/`

## Structure

```
docs/
├── index.html          # Main landing page (user-focused)
├── formulas.html       # Detailed analytics formulas
├── technical.html      # Technical documentation for developers
├── contributing.html   # Contribution guidelines
├── README.md          # This file
└── assets/
    └── css/
        └── styles.css  # Black & gold fire theme
```

## Deploying to GitHub Pages

### Method 1: GitHub Settings (Recommended)

1. Go to your repository on GitHub
2. Click **Settings** -> **Pages**
3. Under "Build and deployment":
   - **Source**: Deploy from a branch
   - **Branch**: `main` (or `master`)
   - **Folder**: `/docs`
4. Click **Save**
5. Wait a few minutes for deployment
6. Your site will be live at `https://andezion.github.io/Forge/`

### Method 2: GitHub Actions (Advanced)

Create `.github/workflows/pages.yml`:

```yaml
name: Deploy GitHub Pages

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./docs
```

## Theme Customization

The site uses a black & gold fire theme. To customize colors, edit `assets/css/styles.css`:

```css
:root {
  --black: #0a0a0a;
  --gold: #d4af37;
  --fire-orange: #ff6b35;
  --fire-red: #c41e3a;
  /* ... */
}
```

## Updating Content

### Adding a New Page

1. Create `new-page.html` in the `docs/` directory
2. Copy the header and footer from existing pages
3. Add navigation link in all pages:
```html
<li><a href="new-page.html">New Page</a></li>
```

### Editing Existing Pages

Simply edit the HTML files directly. Changes will be live after pushing to GitHub.

## Local Testing

To test the site locally:

### Using Python
```bash
cd docs
python -m http.server 8000
# Visit http://localhost:8000
```

### Using Node.js
```bash
cd docs
npx http-server
# Visit http://localhost:8080
```

## Page Descriptions

### index.html
- **Purpose**: User-facing landing page
- **Content**: Features, benefits, getting started
- **Audience**: End users, potential users

### formulas.html
- **Purpose**: Detailed analytics formulas
- **Content**: Mathematical explanations, examples, interpretations
- **Audience**: Power users, data-curious users, contributors

### technical.html
- **Purpose**: Developer documentation
- **Content**: Architecture, code structure, APIs, data models
- **Audience**: Developers, contributors, technical reviewers

### contributing.html
- **Purpose**: Contribution guide
- **Content**: Guidelines, workflow, standards, community rules
- **Audience**: Open source contributors

## Links to Update

Before deploying, update these links in all pages:

1. GitHub repository URL: `https://andezion.github.io/Forge/`
2. Live site URL (after deployment)
3. Your contact information (if adding)

## Analytics (Optional)

To add Google Analytics:

1. Get your tracking ID from Google Analytics
2. Add before `</head>` in all HTML files:

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

## Troubleshooting

### Site not loading
- Check GitHub Pages settings
- Ensure `index.html` exists in `/docs`
- Wait 5-10 minutes after pushing changes

### Styles not loading
- Check file paths are relative: `assets/css/styles.css`
- Verify CSS file was committed and pushed
- Check browser console for 404 errors

### Links broken
- Use relative paths: `formulas.html` not `/formulas.html`
- Test locally before deploying

## Future Enhancements

- [ ] Add dark/light theme toggle
- [ ] Implement search functionality
- [ ] Add interactive formula calculator
- [ ] Create tutorial videos
- [ ] Multi-language support
- [ ] FAQ section
- [ ] Blog/changelog section

## License

Same license as the main project.

## Credits

Design inspired by modern minimalist design principles with a focus on readability and accessibility.

---

Built with 🔥 for the Forge community
