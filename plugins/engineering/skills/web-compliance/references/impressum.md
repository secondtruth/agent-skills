# Impressum — provider identification

**Stand: 2026-08.** Verify details against the primary source before relying on them in an edge case: `gesetze-im-internet.de/ddg/__5.html`, `ris.bka.gv.at` (ECG, UGB, MedienG), `fedlex.admin.ch` (UWG).

## Who needs one

- **Germany:** every digital service offered geschäftsmäßig, "in der Regel gegen Entgelt" (§ 5 DDG). Geschäftsmäßig is met by a business presentation, ads, affiliate links, a paid offer, a professional portfolio — and by the social-media profiles of that business. A purely private page without any economic purpose is exempt; in doubt, publish one. Journalistic-editorial content adds § 18 Abs. 2 MStV regardless of commerce.
- **Austria:** § 5 ECG for commercial services, § 14 UGB for registered businesses, § 25 MedienG for every website ("Offenlegung") — the last applies to private sites too, in a reduced form.
- **Switzerland:** Art. 3 Abs. 1 lit. s UWG for electronic commerce (offering goods or services online). A purely informational site has no Impressum duty; a Datenschutzerklärung under Art. 19 revDSG is still due when personal data is processed.

## Germany — § 5 DDG

| Field | Applies to | Notes |
|---|---|---|
| Name and ladungsfähige Anschrift | everyone | Street address; a Postfach is insufficient. Natural persons: full name. |
| Rechtsform and Vertretungsberechtigte | legal persons (GmbH, UG, AG, e.V., gGmbH …) | Geschäftsführer, Vorstand by name. Capital figures only when the site states them. |
| Fast electronic contact incl. e-mail | everyone | E-mail address in plain text; a second channel (telephone is the safe choice — a contact form alone is contested). |
| Register and number | registered entities | Handelsregister (HRA/HRB + Amtsgericht), Vereinsregister (VR), Partnerschaftsregister, Genossenschaftsregister. |
| Aufsichtsbehörde | activities needing a permit | e.g. financial services, insurance brokers, gambling. |
| Kammer, Berufsbezeichnung, Verleihungsstaat, berufsrechtliche Regelungen | regulated professions | Ärzte, Rechtsanwälte, Steuerberater, Architekten, Ingenieure …; link the rules (e.g. BRAO, BORA). |
| USt-IdNr. (§ 27a UStG) or W-IdNr. (§ 139c AO) | when one exists | Omit the line entirely when the operator has none; a Steuernummer is neither required nor advisable. |
| Liquidation note | AG, KGaA, GmbH in Abwicklung | |
| Verantwortliche Person (§ 18 Abs. 2 MStV) | journalistic-editorial offers | Name and address of the person responsible for content ("V.i.S.d.P."). Applies to blogs and news sections, also of companies. |
| Verbraucherstreitbeilegung (§ 36 VSBG) | businesses with more than ten employees that address consumers | State whether willing or obliged to take part in dispute resolution before a Verbraucherschlichtungsstelle, naming the body when obliged. Smaller businesses may state it voluntarily. |

**Removed duty:** the link to the EU ODR platform (`ec.europa.eu/consumers/odr`) was mandatory under Regulation (EU) 524/2013; the platform closed on 2025-07-20 and the regulation was repealed. A remaining link is stale and should go.

**Legacy wording:** "Angaben gemäß § 5 TMG" and "Telemediengesetz" are outdated since 2024-05-14. Replace with § 5 DDG.

## Austria

| Field | Source | Notes |
|---|---|---|
| Name/Firma, geografische Anschrift, e-mail | § 5 ECG | plus any other fast contact channel |
| Firmenbuchnummer and Firmenbuchgericht | § 5 ECG, § 14 UGB | registered businesses |
| Aufsichtsbehörde | § 5 ECG | permit-based activities |
| Kammer/Berufsverband, Berufsbezeichnung, Verleihungsstaat, berufsrechtliche Vorschriften with access | § 5 ECG | regulated professions |
| UID-Nummer | § 5 ECG | when one exists |
| Gewerbe: Mitgliedschaft WKO, anwendbare Gewerbevorschriften (GewO, `ris.bka.gv.at`) | § 5 ECG, § 63 GewO | trades |
| Medieninhaber, Unternehmensgegenstand, Sitz | § 25 MedienG ("Offenlegung") | every website; name and address suffice for small, presentation-only sites ("kleine Website") |
| Additionally: grundlegende Richtung ("Blattlinie"), vertretungsbefugte Organe, owners with more than 25 % | § 25 MedienG | "große Website" — content beyond self-presentation, e.g. a blog with editorial content or a news section |

## Switzerland

| Field | Source | Notes |
|---|---|---|
| Identity (name/firm) and contact address incl. e-mail | Art. 3 Abs. 1 lit. s UWG | e-commerce only: shops, bookings, paid services offered online |
| Verantwortlicher with contact data, purposes, recipients, export countries | Art. 19 revDSG (privacy information) | the Datenschutzerklärung, whenever personal data is processed |
| Handelsregister/UID | good practice | expected by customers; mandatory data lives in the register entry itself |

Swiss law imposes no consent banner; Art. 45c FMG requires information about cookies and an opt-out possibility, which the privacy policy delivers. A Swiss site that targets EU customers falls under the DSGVO (Art. 3 Abs. 2) and then needs the full EU treatment.

## Placement

- A link labelled exactly **„Impressum"** on every page, usually in the footer. At most two clicks from any page, readable without login, without JavaScript gating, printable. Combined pages ("Impressum & Datenschutz") are tolerated when both words are in the link text; separate pages are cleaner.
- Same page linked from social-media profiles (bio link or "Impressum" field) and from apps.
- The page itself is plain HTML text, machine-readable. Obfuscated e-mail ("name [at] domain") is tolerated but pointless — spam protection belongs in the mailbox.
- Keep the Impressum and the privacy policy current: a changed Geschäftsführer or address is a content update with a deadline, not a nice-to-have.

## German skeleton

Fill every `{…}`; delete rows that apply to nobody in the triage. Leave a `TODO:` where the operator must look the value up.

```
Impressum

Angaben gemäß § 5 DDG

{Firma} {Rechtsform}
{Straße Hausnummer}
{PLZ Ort}
{Land, falls außerhalb Deutschlands}

Vertreten durch: {Geschäftsführer / Vorstand / Inhaber}

Kontakt
Telefon: {+49 …}
E-Mail: {…}

Registereintrag
Eintragung im {Handelsregister / Vereinsregister}
Registergericht: Amtsgericht {…}
Registernummer: {HRB …}

Umsatzsteuer-ID
Umsatzsteuer-Identifikationsnummer gemäß § 27a UStG: {DE…}

Berufsbezeichnung und berufsrechtliche Regelungen          ← reglementierte Berufe
Berufsbezeichnung: {…} (verliehen in {Staat})
Zuständige Kammer: {…}
Es gelten folgende berufsrechtliche Regelungen: {…, abrufbar unter …}

Aufsichtsbehörde                                            ← erlaubnispflichtige Tätigkeiten
{Name, Anschrift, URL}

Redaktionell verantwortlich (§ 18 Abs. 2 MStV)             ← journalistisch-redaktionelle Inhalte
{Name}
{Anschrift}

Verbraucherstreitbeilegung (§ 36 VSBG)
Wir sind {nicht bereit und nicht verpflichtet / verpflichtet}, an Streitbeilegungsverfahren
vor einer Verbraucherschlichtungsstelle teilzunehmen.{ Zuständige Stelle: …}
```

## Errors that trigger Abmahnungen

1. Link hidden under "Kontakt", "Über uns", "Rechtliches", or only on the start page.
2. Postfach instead of a street address; missing Geschäftsführer for a GmbH/UG.
3. Missing e-mail address, or contact form only.
4. "§ 5 TMG" wording; dead ODR-platform link.
5. Missing Kammer/Berufsbezeichnung for a regulated profession; missing V.i.S.d.P. on a blog with editorial content.
6. Outdated data after a move or a change of management.
7. Social-media profiles and apps without a reachable Impressum.
