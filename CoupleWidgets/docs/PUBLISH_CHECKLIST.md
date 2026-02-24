# Checkliste: App-Store-Release

## Im Projekt (vor dem ersten Upload)

- [ ] **Sign in with Apple:** Beim App-Target unter **Signing & Capabilities** → **+ Capability** → **Sign in with Apple** hinzufügen. Erforderlich für Pairing (1:1 mit Apple-Konto).
- [ ] **Hintergrund-Standort (optional):** In Xcode beim App-Target unter **Signing & Capabilities** → **+ Capability** → **Background Modes** hinzufügen und **Location updates** aktivieren. Dann kann sich die Distanz im Widget auch im Hintergrund aktualisieren (nutzt „Signifikante Standortänderungen“).
- [ ] **ReleaseConfig** in `CoupleWidgets/App/UI/SettingsView.swift`: Alle Platzhalter durch deine Daten ersetzen  
  `imprintName`, `imprintStreet`, `imprintPlzOrt`, `imprintEmail`, `supportEmail`; optional `imprintOptional`.
- [ ] **App-Icon:** In `CoupleWidgets/Assets.xcassets/AppIcon.appiconset/` mindestens  
  `Icon-iOS-Default-1024x1024@1x.png` (1024×1024 px) ablegen (siehe README.txt im Ordner).
- [ ] **Build-Nummer** bei jedem neuen Upload in Xcode erhöhen (CURRENT_PROJECT_VERSION / Build).

## App Store Connect

- [ ] App anlegen (Name, Bundle ID, Sprache, Kategorie).
- [ ] **Datenschutz-URL** eintragen (z. B. Webseite oder gehostete Datenschutzerklärung).
- [ ] **Support-URL** eintragen (z. B. Kontaktseite oder gleiche Domain wie Datenschutz).
- [ ] Store-Infos: Beschreibung, Keywords, **Screenshots** (verschiedene iPhone-Größen).
- [ ] Preis: **Kostenlos**.
- [ ] **Age Rating** (Fragebogen) ausfüllen.
- [ ] Ggf. Export Compliance, Advertising Identifier („No“, wenn keine Werbung/Tracking).

## Nach der Veröffentlichung

- [ ] In **ReleaseConfig** in `SettingsView.swift` die echte **App-ID** eintragen  
  (`appStoreAppId` aus App Store Connect). Dann erscheint „App bewerten“ mit funktionierendem Link.
