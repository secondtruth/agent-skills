# Consent — § 25 TDDDG, Art. 6/7 DSGVO, with orestbida/cookieconsent v3

**Stand: 2026-08.** cookieconsent 3.1.x (npm `vanilla-cookieconsent`); API reference at cookieconsent.orestbida.com.

## The two laws that stack

1. **§ 25 TDDDG** (Germany; the ePrivacy rule, Art. 5 Abs. 3 of Directive 2002/58/EC, implemented alike across the EU — Austria: § 165 Abs. 3 TKG 2021): storing information on, or reading it from, the user's device needs prior consent. Exempt: what is strictly necessary for a service the user expressly requested (session, cart, login, the consent record itself, load balancing, CSRF tokens) and pure transmission. The rule is technology-neutral — localStorage, fingerprinting and pixel reads count like cookies.
2. **DSGVO** for what happens with the data afterwards: Art. 6 Abs. 1 lit. a consent for analytics and marketing, lit. b contract for payment, lit. f legitimate interest for server logs and security. Art. 7 defines valid consent (freely given, specific, informed, unambiguous, withdrawable as easily as given — Abs. 3) and Art. 7 Abs. 1 obliges the operator to *prove* it.

Case law that shapes the banner: EuGH C-673/17 *Planet49* (2019) and BGH I ZR 7/16 (2020) — pre-ticked boxes are void; the DSK Orientierungshilfe für Telemedienanbieter — a reject option on the first layer, as visible as accept; LG München I 3 O 17493/20 (2022) — loading Google Fonts from Google's servers without consent transmits the IP unlawfully.

## Step 0 — does the site need a banner?

A banner is required only when a consent-requiring service survives the reduction step. Work through the inventory:

| Finding | Banner needed? | Leaner path |
|---|---|---|
| Only first-party session/login/cart cookies | no | mention them in the privacy policy |
| Google Fonts, Font Awesome CDN, jsDelivr/unpkg scripts | no, once replaced | self-host the files (Bunny Fonts or `google-webfonts-helper` for download) |
| Cookieless analytics (Plausible, Umami, Fathom; Matomo with cookies off and IP anonymised) | no — Art. 6 Abs. 1 lit. f, § 25 Abs. 2 exemption holds only while nothing is stored client-side | disclose in the privacy policy; offer an opt-out where the tool supports it |
| GA4, GTM, Meta/LinkedIn/TikTok pixels, Hotjar, Clarity, HubSpot | **yes** | or drop them |
| YouTube, Vimeo, Google Maps, Spotify embeds | yes for live embeds | two-click placeholder that loads the iframe on click (`youtube-nocookie.com`); treat the click as consent for that service |
| reCAPTCHA | yes (Google sets cookies and fingerprints) | hCaptcha in privacy mode, Cloudflare Turnstile, honeypot fields, rate limiting |
| Chat widgets (Intercom, Crisp, Tawk) | yes | load on click of a "start chat" button |
| Stripe/PayPal JS on the checkout page only | covered by lit. b on that page | keep the SDK off pages without checkout |

When the answer is "no" throughout, the site ships with a privacy policy and zero banner — the best outcome for users and the operator. Document that decision in the privacy policy's cookie section.

## Install self-hosted

```bash
npm i vanilla-cookieconsent@3
```

Bundler projects import the package; the CSS and JS then ship with the site's own assets:

```js
import 'vanilla-cookieconsent/dist/cookieconsent.css';
import * as CookieConsent from 'vanilla-cookieconsent';
```

Static sites copy `node_modules/vanilla-cookieconsent/dist/cookieconsent.{css,umd.js}` (or `.esm.js`) into the public assets. The `cdn.jsdelivr.net` URLs from the documentation are for demos: a script fetched from jsDelivr contacts a third party before the visitor has consented to anything.

## Configuration recipe (German-first)

Categories come from the inventory. Keep to the four that users recognise — `necessary`, `functionality`, `analytics`, `marketing` — and drop the ones with no service in them. Every optional service appears as a toggle (`services`) so users can accept one without the other.

```js
CookieConsent.run({
  // mode 'opt-in' is the default and the compliant one; 'opt-out' runs scripts first.
  revision: 1,                       // bump whenever the set of services or the policy changes
  hideFromBots: true,
  disablePageInteraction: false,     // an overlay is lawful; a scroll lock on mobile is hostile
  cookie: {
    name: 'cc_cookie',
    expiresAfterDays: 182,           // six months; re-ask within a year at most
    sameSite: 'Lax',
  },
  guiOptions: {
    consentModal: {
      layout: 'box wide',
      position: 'bottom left',
      equalWeightButtons: true,      // reject looks like accept — the DSK requirement
      flipButtons: false,
    },
    preferencesModal: {
      layout: 'box',
      equalWeightButtons: true,
      flipButtons: false,
    },
  },
  categories: {
    necessary: { enabled: true, readOnly: true },
    analytics: {
      autoClear: {                   // rejecting later removes what the service left behind
        cookies: [{ name: /^_ga/ }, { name: '_gid' }],
        reloadPage: false,
      },
      services: {
        ga4: { label: 'Google Analytics 4' },
      },
    },
    marketing: {
      autoClear: { cookies: [{ name: /^_fbp/ }] },
      services: {
        youtube: {
          label: 'YouTube-Videos',
          onAccept: () => im.acceptService('youtube'),   // iframemanager, see Embeds
          onReject: () => im.rejectService('youtube'),
        },
      },
    },
  },
  language: {
    default: 'de',
    autoDetect: 'document',          // follows <html lang>; add 'en' translations for bilingual sites
    translations: {
      de: {
        consentModal: {
          title: 'Datenschutzeinstellungen',
          description:
            'Wir verwenden technisch notwendige Cookies. Optionale Dienste (Statistik, eingebettete Videos) ' +
            'laden erst nach Ihrer Einwilligung. Sie können Ihre Auswahl jederzeit im Footer unter ' +
            '„Cookie-Einstellungen" ändern. {{revisionMessage}}',
          revisionMessage: 'Wir haben unsere Dienste aktualisiert und bitten erneut um Ihre Auswahl.',
          acceptAllBtn: 'Alle akzeptieren',
          acceptNecessaryBtn: 'Nur notwendige',
          showPreferencesBtn: 'Einstellungen',
          closeIconLabel: 'Schließen und nur notwendige akzeptieren',
          footer: '<a href="/impressum">Impressum</a> <a href="/datenschutz">Datenschutzerklärung</a>',
        },
        preferencesModal: {
          title: 'Cookie-Einstellungen',
          acceptAllBtn: 'Alle akzeptieren',
          acceptNecessaryBtn: 'Nur notwendige',
          savePreferencesBtn: 'Auswahl speichern',
          closeIconLabel: 'Schließen',
          serviceCounterLabel: 'Dienst|Dienste',
          sections: [
            {
              title: 'Notwendig',
              description: 'Sitzung, Sicherheit und die Speicherung dieser Einstellung. Rechtsgrundlage: § 25 Abs. 2 TDDDG.',
              linkedCategory: 'necessary',
            },
            {
              title: 'Statistik',
              description: 'Reichweitenmessung mit Google Analytics 4. Daten werden an Google Ireland Ltd. übermittelt, ' +
                'Drittlandtransfer in die USA auf Basis des EU-US Data Privacy Framework. Rechtsgrundlage: Art. 6 Abs. 1 lit. a DSGVO.',
              linkedCategory: 'analytics',
              cookieTable: {
                caption: 'Cookies',
                headers: { name: 'Name', domain: 'Domain', desc: 'Zweck', exp: 'Laufzeit' },
                body: [
                  { name: '_ga', domain: location.hostname, desc: 'Unterscheidung von Besuchern', exp: '2 Jahre' },
                  { name: '_ga_*', domain: location.hostname, desc: 'Sitzungsstatus', exp: '2 Jahre' },
                ],
              },
            },
            {
              title: 'Marketing und Einbettungen',
              description: 'Eingebettete YouTube-Videos (Google Ireland Ltd.). Rechtsgrundlage: Art. 6 Abs. 1 lit. a DSGVO.',
              linkedCategory: 'marketing',
            },
            {
              title: 'Weitere Informationen',
              description: 'Details in der <a href="/datenschutz">Datenschutzerklärung</a>.',
            },
          ],
        },
      },
    },
  },
});
```

Purpose texts are specific ("Reichweitenmessung mit Google Analytics 4") rather than generic ("um Ihr Erlebnis zu verbessern"); the DSK treats vague purposes as uninformed consent.

## Blocking scripts

Every optional `<script>` gets `type="text/plain"` and `data-category`; cookieconsent rewrites the type once the category is accepted (`manageScriptTags`, default on). `data-service` ties it to a toggle; `data-type="module"` restores ES-module semantics.

```html
<!-- Google Analytics 4: inert until 'analytics' → 'ga4' is accepted -->
<script type="text/plain" data-category="analytics" data-service="ga4"
        async data-src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXX"></script>
<script type="text/plain" data-category="analytics" data-service="ga4">
  window.dataLayer = window.dataLayer || [];
  function gtag(){ dataLayer.push(arguments); }
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXX', { anonymize_ip: true });
</script>
```

`data-src` instead of `src` keeps the browser's preload scanner from fetching the file early — with `src`, some browsers download (though never execute) the script before consent, which is already a request to Google. A script tag activates at most once; logic that must react to every change (re-enable after withdrawal, tag-manager consent updates) goes into `onConsent`/`onChange`:

```js
onConsent: () => { if (CookieConsent.acceptedCategory('analytics')) startAnalytics(); },
onChange: ({ changedCategories }) => {
  if (changedCategories.includes('analytics') && !CookieConsent.acceptedCategory('analytics')) stopAnalytics();
},
```

Google Tag Manager users additionally wire **Consent Mode v2**: set every `gtag('consent', 'default', …)` signal to `denied` before GTM loads, and update from `onConsent`/`onChange` with `acceptedService(...)` — the documentation's `google-consent-mode` guide has the complete mapping. Consent Mode is a tag-level signal, never a replacement for blocking the tag container behind a category.

## Embeds

Live iframes (YouTube, Vimeo, Maps) contact the provider on page load. Use the author's companion [iframemanager](https://github.com/orestbida/iframemanager): each iframe becomes a placeholder with the provider's name, a notice, and a play button; the click accepts that service, and cookieconsent's `services.<name>.onAccept/onReject` keep both tools in sync (the documentation's *IframeManager set-up* page has the two-way wiring). Prefer `youtube-nocookie.com` as the embed host even after consent.

Without iframemanager, the same two-click pattern by hand: render a `<div data-embed="https://www.youtube-nocookie.com/embed/ID">` with a poster image, swap in the iframe on click, and record the click via `CookieConsent.acceptService('youtube', 'marketing')` so the choice persists.

## Withdrawal and the footer

```html
<a href="#" data-cc="show-preferencesModal">Cookie-Einstellungen</a>
```

in the footer of every page, next to Impressum and Datenschutz. Rejecting a category triggers `autoClear` for the cookies listed; anything the service keeps in localStorage is cleared in the service's `onReject`.

## Consent record

cookieconsent stores `consentId`, `consentTimestamp`, `lastConsentTimestamp`, `revision`, accepted `categories` and `services` in its own cookie — that is the Art. 7 Abs. 1 proof for the ordinary case. Sites with a higher risk profile (marketing-heavy, health, finance) log the record server-side from `onFirstConsent`/`onChange`; the documentation's *consent logging* page shows the payload. Bump `revision` whenever a service is added or the policy changes; users with an older revision are asked again, and `revisionMessage` tells them why.

## SPA notes

Run `CookieConsent.run()` once at app start (`useEffect` with an empty dependency list in React; a plugin in Vue; `ngAfterViewInit` in Angular). Route changes need no re-run; scripts stay enabled. Analytics page-view calls on navigation go through your own `if (CookieConsent.acceptedCategory('analytics'))` guard. Server-rendered frameworks keep the optional tags in the document `<head>` with `type="text/plain"`; the plugin activates them on the client.

## Verification checklist

Run in a fresh private window with DevTools open.

1. **Before any interaction:** the Network tab shows only first-party hosts and the consent assets. Cookies: none but the session cookie. No `fonts.g*`, `googletagmanager`, `youtube`, `connect.facebook.net` entries. Otherwise a tag is outside its category or pulled in by a third script.
2. **First layer:** "Alle akzeptieren" and "Nur notwendige" are siblings of equal size; a preferences button exists; closing with ✕ or Escape leaves every optional category off.
3. **Reject all:** reload; optional hosts still absent; `cc_cookie` present with the categories recorded.
4. **Accept all:** optional scripts load; cookies appear; page views are counted.
5. **Withdraw via the footer link:** rejected category's cookies disappear (`autoClear`); on reload the service stays off.
6. **Revision bump:** change `revision`; the modal returns with the revision message.
7. **Embeds:** placeholders render before consent; the click loads the iframe; the toggle in the preferences modal reflects it.
8. **Keyboard and screen reader:** focus lands in the modal, buttons have labels (`closeIconLabel`), `Tab` cycles inside while open.
9. **Bots:** `curl -A Googlebot` receives the page without the modal's markup when `hideFromBots` is on.
10. **Independent check:** `website-recht-check --deep` (see the tooling section of the skill) reports zero tracker contacts before interaction.
