# Third-party services — detection, behaviour, category, disclosure

**Stand: 2026-08.** Detection patterns partly adapted from `deutsches-recht-mit-claude` (waldo-van-der-code, MIT). Provider entities and transfer mechanisms change; confirm before publishing them in a policy.

Legend — *Before consent:* what happens if the tag is loaded unconditionally. *Category:* the cookieconsent category it belongs in. *Leaner:* the replacement that removes the duty or shrinks it.

## Client-side (visible to the browser)

| Service | Signals in code | Before consent | Category | Leaner |
|---|---|---|---|---|
| Google Analytics 4 / Tag Manager | `googletagmanager.com/gtag`, `gtag(`, `G-[A-Z0-9]{6,}`, `GTM-`, `googletagmanager.com/gtm`, `react-ga4`, `@next/third-parties/google`, `vue-gtag` | IP and page view to Google, `_ga` cookies | analytics (GTM: container gated; tags by category via Consent Mode) | Plausible, Umami, Fathom, Matomo cookieless (lit. f, still disclosed) |
| Google Fonts | `fonts.googleapis.com`, `fonts.gstatic.com`, `@import url(https://fonts`, `next/font/google` (self-hosts at build — fine) | IP to Google on every page view (LG München I 2022) | — (replace) | self-host via google-webfonts-helper or Bunny Fonts download; `@fontsource/*` packages |
| Google Maps | `maps.googleapis.com`, `maps.google.com/maps`, `@googlemaps/`, `google.maps.` | IP, cookies, fingerprinting | marketing/functionality | static map image with a link; Leaflet with self-hosted or OpenStreetMap tiles (still IP to OSMF — disclose, lit. f) |
| YouTube | `youtube.com/embed`, `youtube.com/iframe_api`, `react-youtube`, `lite-youtube` | IP, cookies; `youtube-nocookie.com` still contacts Google on load | marketing | two-click placeholder + `youtube-nocookie.com`; iframemanager |
| Vimeo | `player.vimeo.com` | IP, cookies; `dnt=1` parameter reduces tracking | marketing | two-click placeholder |
| Meta Pixel | `connect.facebook.net`, `fbq(`, `fbevents.js` | full tracking | marketing | remove |
| LinkedIn Insight | `snap.licdn.com`, `_linkedin_partner_id` | full tracking | marketing | remove |
| TikTok Pixel | `analytics.tiktok.com`, `ttq.` | full tracking | marketing | remove |
| Hotjar / Microsoft Clarity | `static.hotjar.com`, `hj(`, `clarity.ms`, `clarity(` | session recording | analytics (disclose recording explicitly) | remove; usability tests |
| HubSpot | `js.hs-scripts.com`, `js.hsforms.net`, `hbspt.` | tracking + forms | marketing | native form + CRM API server-side |
| reCAPTCHA | `google.com/recaptcha`, `grecaptcha`, `react-google-recaptcha` | IP, cookies, fingerprint to Google on every page that loads it | marketing (consent needed before it can protect the form — awkward) | Cloudflare Turnstile, hCaptcha, honeypot + rate limit |
| hCaptcha / Turnstile | `hcaptcha.com`, `challenges.cloudflare.com/turnstile` | IP to the provider, minimal storage | functionality (lit. f often accepted; disclose) | honeypot |
| Cloudflare Web Analytics / Insights | `static.cloudflareinsights.com`, `beacon.min.js` | cookieless beacon | — (lit. f; disclose) | keep or Plausible |
| Vercel Analytics / Speed Insights | `@vercel/analytics`, `vitals.vercel-insights.com` | cookieless, hashed | — (lit. f; disclose) | keep |
| jsDelivr, unpkg, cdnjs, Font Awesome Kit | `cdn.jsdelivr.net`, `unpkg.com`, `cdnjs.cloudflare.com`, `kit.fontawesome.com`, `use.fontawesome.com` | IP to the CDN on every page view | — (replace) | bundle; npm packages |
| Intercom, Crisp, Tawk, Zendesk chat | `widget.intercom.io`, `client.crisp.chat`, `embed.tawk.to`, `zdassets.com` | IP, cookies, fingerprinting | functionality with consent, or load-on-click | load on click of a "Chat starten" button |
| Calendly, Cal.com embeds | `assets.calendly.com`, `cal.com/embed` | IP, cookies | functionality | link out instead of embedding |
| Disqus, social share buttons | `disqus.com/embed.js`, `platform.twitter.com`, `connect.facebook.net/*/sdk.js` | full tracking | marketing | plain share links (`https://…/share?url=`) |
| Stripe.js, PayPal SDK | `js.stripe.com`, `@stripe/stripe-js`, `paypal.com/sdk/js` | fingerprinting cookies even on pages without checkout | necessary on checkout pages (lit. b); keep off elsewhere | load only on the checkout route |
| Sentry browser SDK | `@sentry/browser`, `@sentry/react`, `sentry.io`, `ingest.sentry.io` | error payloads with IP and possibly PII | lit. f with scrubbing (`sendDefaultPii: false`); disclose | self-hosted Sentry / GlitchTip (EU) |
| Web fonts from Adobe Fonts (Typekit) | `use.typekit.net` | IP to Adobe, cookies | marketing (Adobe sets tracking) | self-host licensed fonts where the licence allows |

## Server-side (recipients without cookies)

| Service | Signals in code | Disclose as | Typical basis |
|---|---|---|---|
| Hosting / platform (Vercel, Netlify, Hetzner, AWS, Cloudflare Pages) | deploy config, `vercel.json`, `netlify.toml`, `wrangler.toml`, Dockerfiles | Auftragsverarbeiter; seat; log retention | lit. f |
| Transactional mail (Resend, SendGrid, Postmark, Brevo, Mailgun, SES) | `resend`, `@sendgrid/mail`, `postmark`, `nodemailer` transport hosts | recipient for contact/newsletter data | lit. b / lit. a |
| Newsletter (Mailchimp, Brevo, Klaviyo, Listmonk) | API keys, list IDs, embed forms | recipient; DOI; tracking | lit. a |
| Database / BaaS (Supabase, Firebase, PlanetScale, Neon) | client init, connection strings | Auftragsverarbeiter; seat/region | follows the activity |
| Auth providers (Auth0, Clerk, Firebase Auth) | SDK imports | Auftragsverarbeiter; login data | lit. b |
| Payment (Stripe, PayPal, Mollie, Klarna) | server SDKs, webhooks | independent controller or processor per the provider's terms | lit. b |
| LLM APIs (Anthropic, OpenAI, Mistral) | SDK imports, API hosts | recipient of whatever the user types; third-country; AI Act Art. 50 disclosure for chat | lit. b / lit. a |
| Error and log aggregation (Sentry server, Datadog, Logtail, Axiom) | SDK imports | Auftragsverarbeiter; PII in logs | lit. f |
| Search (Algolia), images (Cloudinary, imgix), uploads (Uploadthing, S3) | SDK imports, hostnames | Auftragsverarbeiter | follows the activity |

## Inventory grep

Run from the repository root; widen the include list to the project's languages. The pattern mirrors the *Signals* column above — extend both together when a service is added; a clean grep is a starting point, not proof of absence. Search for the hostnames as well as the SDKs — a bare `<script src>` in a layout hides from import-based greps.

```bash
grep -rnEi \
  'googletagmanager|google-analytics|gtag\(|G-[A-Z0-9]{6,}|GTM-[A-Z0-9]{4,}|react-ga4|@next/third-parties|vue-gtag|plausible|umami|fathom|matomo|_paq|fonts\.googleapis|fonts\.gstatic|@fontsource|maps\.googleapis|google\.maps\.|@googlemaps|youtube\.com/(embed|iframe_api)|youtube-nocookie|react-youtube|lite-youtube|player\.vimeo|open\.spotify\.com/embed|connect\.facebook\.net|fbq\(|snap\.licdn|analytics\.tiktok|hotjar|clarity\.ms|hs-scripts|hsforms|hbspt|recaptcha|hcaptcha|turnstile|cloudflareinsights|vercel-insights|@vercel/analytics|cdn\.jsdelivr|unpkg\.com|cdnjs\.cloudflare|fontawesome|intercom|crisp\.chat|tawk\.to|zdassets|calendly|cal\.com/embed|disqus|platform\.twitter|js\.stripe|@stripe/stripe-js|paypal\.com/sdk|@sentry/|sentry\.io|typekit' \
  --include='*.html' --include='*.htm' --include='*.js' --include='*.jsx' --include='*.ts' --include='*.tsx' \
  --include='*.vue' --include='*.svelte' --include='*.astro' --include='*.php' --include='*.twig' --include='*.blade.php' \
  --include='*.liquid' --include='*.njk' --include='*.hbs' --include='*.md' --include='*.mdx' --include='*.css' --include='*.scss' \
  --include='*.json' --include='*.yml' --include='*.yaml' --include='*.toml' \
  --exclude-dir=node_modules --exclude-dir=vendor --exclude-dir=dist --exclude-dir=.next --exclude-dir=build .

# Storage and device access the site itself performs
grep -rnE 'document\.cookie|localStorage\.setItem|sessionStorage\.setItem|setCookie|cookies\(\)\.set|Set-Cookie' \
  --include='*.js' --include='*.jsx' --include='*.ts' --include='*.tsx' --include='*.vue' --include='*.svelte' --include='*.astro' --include='*.php' \
  --exclude-dir=node_modules --exclude-dir=vendor --exclude-dir=dist .

# Forms that collect personal data
grep -rnE 'type="(email|tel)"|name="(email|phone|telefon|name|vorname|nachname|iban|address|adresse)"' \
  --include='*.html' --include='*.jsx' --include='*.tsx' --include='*.vue' --include='*.svelte' --include='*.astro' --include='*.php' --include='*.twig' \
  --exclude-dir=node_modules --exclude-dir=vendor --exclude-dir=dist .

# Server-side recipients — manifests first, then the source tree (wrappers and lazily
# imported SDKs only show up there)
grep -rnEi 'resend|sendgrid|postmark|mailgun|brevo|sendinblue|mailchimp|klaviyo|listmonk|nodemailer|smtp|supabase|firebase|planetscale|neon|auth0|clerk|stripe|paypal|mollie|klarna|anthropic|openai|mistral|algolia|cloudinary|imgix|uploadthing|s3\.|datadog|axiom|logtail|sentry' \
  --include='package.json' --include='composer.json' --include='requirements.txt' --include='pyproject.toml' --include='go.mod' --include='Gemfile' --include='Cargo.toml' --include='.env.example' \
  --include='*.js' --include='*.mjs' --include='*.ts' --include='*.tsx' --include='*.php' --include='*.py' --include='*.go' --include='*.rb' --include='*.rs' \
  --exclude-dir=node_modules --exclude-dir=vendor --exclude-dir=dist --exclude-dir=.next --exclude-dir=build --exclude-dir=target .
```

Read the layout/head templates by hand after grepping: CMS themes, tag managers and marketing plugins add tags outside the source tree (WordPress plugins, Shopify apps, Webflow integrations). For those, the inventory comes from the rendered page — `curl -sL <url> | grep -oE 'https?://[^"'"'"' ]+' | sort -u` lists every host the HTML references, and a `--deep` run of website-recht-check lists the hosts the browser actually contacts.
