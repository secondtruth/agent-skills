# Datenschutzerklärung — Art. 12–14 DSGVO

**Stand: 2026-08.** Austria and the EU share the DSGVO; Switzerland uses Art. 19 revDSG, which asks for less (identity, purposes, recipients, export countries) — the EU structure covers it.

## Form (Art. 12)

- Own HTML page, linked from every page as „Datenschutz" or „Datenschutzerklärung", within two clicks, readable without consent or login. A PDF, an image, or a section hidden under "Kontakt" has been ruled insufficient.
- Plain language, structured by processing activity, in the site's language(s). A bilingual site publishes both versions; the German one is authoritative for a German operator.
- Dated; older versions kept by the operator.
- Applies to every site that processes personal data — which every site does, because the server sees IP addresses. There is no small-site exemption.

## Structure and mandatory content (Art. 13)

Each processing activity states **purpose, legal basis, recipient, third-country status, retention**. The skeleton below is ordered the way supervisory authorities and generators order it; sections marked ◇ exist only when the inventory produces a hit.

| # | Section | Required content |
|---|---|---|
| 1 | Verantwortlicher | name, address, e-mail, telephone (matches the Impressum) |
| 2 | Datenschutzbeauftragte:r | contact when one is appointed — mandatory once at least 20 persons (§ 38 Abs. 1 BDSG: „in der Regel mindestens 20 Personen") regularly process personal data by automated means, or for core activities with sensitive data |
| 3 | Hosting und Server-Logs | provider as Auftragsverarbeiter (Art. 28 contract exists — `TODO` if unknown), log fields (IP, timestamp, URL, user agent, referrer), Art. 6 Abs. 1 lit. f, retention (7–14 days is customary), seat country of the provider |
| 4 | Cookies und Einwilligung | two tiers: strictly necessary storage (session, login, cart, the consent record) under § 25 Abs. 2 TDDDG with Art. 6 Abs. 1 lit. b or lit. f; optional categories under § 25 Abs. 1 TDDDG with Art. 6 Abs. 1 lit. a — then how to withdraw (the footer link) and the consent cookie's lifetime; on banner-free sites: the statement that only necessary storage is used |
| 5 ◇ | Kontaktformular / E-Mail | data fields, lit. b (pre-contractual) or lit. f, mail provider as recipient, retention |
| 6 ◇ | Newsletter | double opt-in, lit. a, § 7 UWG reference, provider (recipient, seat, DPF/SCC), open-rate tracking if enabled, withdrawal via unsubscribe link |
| 7 ◇ | Registrierung / Kundenkonto | account fields, lit. b, retention until deletion |
| 8 ◇ | Zahlungsdienste | Stripe, PayPal, Mollie …: lit. b, the provider as independent controller or processor per its terms, third-country transfer |
| 9 ◇ | Webanalyse | one subsection per tool: GA4 (Google Ireland; DPF for US transfer; IP truncation; lit. a), Matomo/Plausible/Umami (self-hosted or EU; lit. f when cookieless) |
| 10 ◇ | Marketing und Pixel | Meta Pixel, LinkedIn Insight, Google Ads: lit. a, joint controllership for Meta page insights, the provider's own policy linked |
| 11 ◇ | Eingebettete Inhalte | YouTube, Vimeo, Maps, Spotify, social plugins: lit. a via the two-click/iframe gate, what the provider receives on activation |
| 12 ◇ | Schriftarten, CDNs, Captcha | self-hosted fonts → one sentence that fonts are served locally; CDN scripts/reCAPTCHA → lit. a (reCAPTCHA) or lit. f with explicit justification and the IP transfer named |
| 13 ◇ | Chat, Support, Buchung | Intercom/Crisp/Calendly …: lit. b or lit. a, provider, seat |
| 14 ◇ | Fehler- und Leistungsmonitoring | Sentry & co.: lit. f, that stack traces may contain personal data, scrubbing in place |
| 15 ◇ | Social-Media-Präsenzen | one paragraph per platform the operator runs a profile on, joint controllership for Facebook/Instagram insights |
| 16 | Drittlandübermittlung | the general statement: transfers to the USA rest on the EU-US Data Privacy Framework for certified providers (name them), otherwise Standardvertragsklauseln (Art. 46 Abs. 2 lit. c) |
| 17 | Speicherdauer | the general rule: as long as the purpose needs, then statutory retention by record class (§ 147 AO, § 257 HGB, since 2025): books, inventories and annual accounts 10 years; Buchungsbelege 8 years; commercial and business letters 6 years |
| 18 | Betroffenenrechte | Auskunft (15), Berichtigung (16), Löschung (17), Einschränkung (18), Datenübertragbarkeit (20), Widerspruch (21) with the prominent Art. 21 notice, Widerruf einer Einwilligung (7 Abs. 3) |
| 19 | Beschwerderecht | Art. 77: any supervisory authority, typically the one of the operator's Bundesland — name it |
| 20 ◇ | Automatisierte Entscheidungen | Art. 22, only when profiling with legal effect exists |
| 21 | Sicherheit | TLS, the usual sentence |
| 22 | Stand | date |

## Mapping the inventory

For every row in the inventory write one subsection using this micro-structure — the reader should be able to answer "what, why, who, where, how long" per service:

```
### {Dienst}
Wir setzen {Dienst} von {Anbieter, Rechtsform, Anschrift} ein, um {Zweck}.
Dabei werden {Datenkategorien} verarbeitet{ und an {Anbieter} übermittelt}.
Rechtsgrundlage: {Art. 6 Abs. 1 lit. a DSGVO (Einwilligung über das Cookie-Banner, widerrufbar unter „Cookie-Einstellungen") | lit. b | lit. f — berechtigtes Interesse: {…}}.
{Die Übermittlung in die USA stützt sich auf {das EU-US Data Privacy Framework (Zertifizierung: …) | Standardvertragsklauseln}.}
Speicherdauer: {…}. Weitere Informationen: {Link zur Datenschutzerklärung des Anbieters}.
```

Facts the code gives you: the service, its purpose, the category, the cookies it sets. Facts it does not: whether an Art. 28 contract is signed, the exact provider entity (Google Ireland Ltd. vs. Google LLC), DPF certification status. Write those as `TODO: prüfen — <where to look>` rather than assuming.

Third-country status per provider changes; check the DPF list (`dataprivacyframework.gov`) when a US provider matters.

## German heading skeleton

```
Datenschutzerklärung

1. Verantwortlicher
2. Datenschutzbeauftragte:r                                 ← wenn bestellt
3. Hosting und Server-Logfiles
4. Cookies, Einwilligung und Widerruf
5. Kontaktaufnahme
6. Newsletter                                               ◇
7. Kundenkonto / Registrierung                              ◇
8. Zahlungsdienstleister                                    ◇
9. Webanalyse                                               ◇
10. Marketing                                               ◇
11. Eingebettete Inhalte von Drittanbietern                 ◇
12. Schriftarten, Skripte, Captcha                          ◇
13. Chat und Terminbuchung                                  ◇
14. Fehler- und Leistungsüberwachung                        ◇
15. Unsere Präsenzen in sozialen Netzwerken                 ◇
16. Datenübermittlung in Drittländer
17. Speicherdauer
18. Ihre Rechte
19. Beschwerderecht bei einer Aufsichtsbehörde
20. Automatisierte Entscheidungsfindung                     ◇
21. Datensicherheit
22. Stand dieser Erklärung
```

## Generators

For the full text, a maintained generator beats hand-written prose: Datenschutz-Generator.de (Dr. Schwenke; free tier for private and small sites, modular per service) and eRecht24 (paid, with an Abmahn-Schutz offering). Feed them the inventory and compare their output against it afterwards — a generator only knows what it was told, and an unticked module is a missing section.
