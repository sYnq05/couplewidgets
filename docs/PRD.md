# CoupleWidgets – Product Requirements Document (PRD)

**Stand:** Aktuell – CloudKit-Sync mit Sign in with Apple (1:1-Pairing), Push-Benachrichtigung bei neuer Note, optional „Standort verwenden“ + Hintergrund-Updates, Namen zentral in Einstellungen, Reset pro Widget, Impressum-Vorlage, Widgets Lock Screen transparent + Home dunkler Gradient.

**Änderungen seit letzter PRD-Aktualisierung:**
- **CloudKit-Sync:** Paar-Daten (Profile, Countdown, Note, Streak) werden über CloudKit (Public Database) zwischen Owner und Partner synchronisiert. Record Type „Couple“, recordName = normalisierter Invite-Code. Siehe **docs/CLOUDKIT.md**, **CoupleWidgets/docs/APPLE_SIGNIN_AND_PAIRING.md**.
- **Sign in with Apple (1:1-Pairing):** Pairing ist an Apple-ID gebunden. Owner/Partner setzen `ownerAppleId`/`partnerAppleId` im Record; nur dieses Paar kann pushen/pullen. Partner-Slot pro Code einmalig; „Code bereits vergeben“-Alert bei Konflikt. Pull nur bei angemeldetem Nutzer; Owner/Partner ohne Apple-ID schreiben nicht in CloudKit.
- **Push-Benachrichtigung (Note):** CloudKit-Subscription auf den Couple-Record; bei Record-Update (z. B. Partner speichert Note) erhält das andere Gerät eine Remote-Notification → Pull → lokale Benachrichtigung „Neue Notiz / From [Name]“. Erfordert Capabilities: Push Notifications, Background Modes → Remote notifications.
- **Standort:** Optional „Standort verwenden“ in Cities (YOUR LOCATION); einmalige Abfrage + Reverse-Geocoding (MapKit). Optional Hintergrund-Updates (significant location changes) für aktuelle Distanz im Widget; Schreiben in App-Group-Cache + Notification für App-Refresh. LocationService nutzt `addressRepresentations` (iOS 26), kein `placemark`.
- **Weitere Logik:** Regenerate löscht alten CloudKit-Record; Unlink (Partner) gibt Partner-Slot in CloudKit frei. Leerer Record-Name (z. B. „----“) wird abgefangen. Sync-Fehler bei App-Wechsel (.active) als Alert; Redeem-Erfolgs-Alert erst nach syncPull. Countdown-Tage konsistent (Kalender-Tage im Formatter). Pending Delete nach Regenerate wird bei .active erneut versucht.
- **Namen zentral in Einstellungen:** „Dein Name“ und „Partner-Name“ nur in Einstellungen (Profil-Section) editierbar; Distance-Screen nur noch Standorte (Land/Stadt). Pairing zeigt Namen read-only + Footer „Namen in Einstellungen bearbeiten“. L10n: profileSection, yourName, partnerNameLabel, editNamesInSettings (DE/EN). Save in Settings → commit() → Cache + Widget-Reload.
- **Standard-Apple Back & Save:** System-Back-Button (kein eigener Leading-Button); HomeView mit `.navigationTitle(L10n.tr(.appTitle))` → Back zeigt „< CoupleWidgets“. Save-Button in Toolbar mit `.buttonStyle(.plain)` und `.foregroundStyle(Color.blue)`; zentral `.tint(Color.blue)` am NavigationStack. **Zurück-Button blau:** `UINavigationBar.appearance().tintColor = .systemBlue` in CoupleWidgetsApp.init(). Distance: weiße Nav-Bar (`.toolbarBackground(Color(UIColor.systemBackground))`). Kein Rahmen/Kreis um Bar-Buttons.
- **Save-Button überall lokalisiert:** CitiesView nutzt `L10n.tr(.save, language: lang)` → „Speichern“ / „Save“; Button größenabhängig vom Text.
- **Menü bereinigt:** „Cities“ aus dem Drei-Punkte-Menü entfernt; nur noch Pairing + Einstellungen. Distance weiterhin über Widget-Karte erreichbar.
- **Zurücksetzen pro Widget:** Reset nicht mehr im HomeView-Menü. Auf jeder Konfigurationsseite unten Section „Zurücksetzen“ mit destructive Button („Zurücksetzen – Distance/Countdown/Note“) + Bestätigungs-Alert (widgetResetTitle, widgetResetMessage); Aufruf von resetDistance/resetCountdown/resetNote. HomeView: WidgetToReset-Enum, showResetAlert, Reset-Menüeinträge und Reset-Alert entfernt.
- **Impressum-Vorlage:** Einstellungen → Rechtliches → Impressum mit vollständiger DE/EN-Vorlage (imprintContentDE/imprintContentEN in SettingsView); Platzhalter [NAME/FIRMA], [STRASSE], [PLZ ORT], [E-Mail], optional Register/USt-IdNr., Verantwortlicher, Hinweis auf Datenschutz in der App.
- **Build-Fix:** `.foregroundStyle(.accentColor)` → `.foregroundStyle(Color.accentColor)` in SettingsView/CitiesView (ShapeStyle-Kompatibilität).
- **Widget-Hintergrund:** Lock Screen (accessoryCircular/accessoryInline/accessoryRectangular): transparenter Container (`Color.clear`), nur weiße Linien und Text. Home Screen (systemSmall/systemMedium): dunkler Gradient (WidgetViewHelpers), damit weiße Schrift lesbar ist. `widgetContainerBackground(transparentForAccessory:)` je nach Familie.
- **Distance-Widget Lock Screen:** Inline = eine Zeile „JH • 8,642 km • DY“ (Initials • Distanz • Initials), Bullet-Separator. Rectangular = Initials links | Mitte: Zahl + „km apart“ | Initials rechts; nur Strokes (badgeView Circle.stroke), keine Füllflächen.
- **Note-Widget:** NoteEntry um authorInitials, noteText erweitert; accessoryCircular (Icon bubble.left.fill + Initials); Rectangular: Nachricht + „— JH“; Inline mit Bubble-Icon. Home small/medium: Emerald-Akzent (Icon, optional Rahmen), „— authorInitials“.
- **Divider entfernt:** Keine Trennlinien (Divider) mehr zwischen Zeilen in CONFIGURATION/DISPLAY OPTIONS/STATISTICS in NoteEditorView, CountdownEditorView, CitiesView.
- **Schriftgrößen:** IOSSection- und IOSWidgetPreview-Titel `.footnote` (statt .caption); IOSStatCard Label/Value `.body` (statt .subheadline).
- **App-Group-Anleitung:** docs/APP_GROUP_SETUP.md für Widget-Setup (ohne Cloud).

**Bekannte offene UI-Probleme (zu beheben):**
- **Distance-Screen – Schrift:** Falls auf einzelnen Geräten weiterhin nicht sichtbar, Kontrast/Container prüfen (`.foregroundStyle(.primary)` für Inhalte).
- **Einstellungs-Button:** Label und Zahnrad ggf. Kontrast erhöhen.
- **Chevrons auf Home-Karten:** Sichtbarkeit ggf. mit .primary oder Rahmen verbessern.

---

## 1) Ziel & Erfolgskriterien

**Ziel:** Eine iOS-App mit Lock-Screen-Widgets für Paare: Distanz, Countdown, Note + Streak. Daten werden zwischen zwei Geräten per iCloud (CloudKit) synchronisiert. Markenname in der App: **CoupleWidgets**.

**Fokus:** Lokaler Cache (App Group) + CloudKit-Sync für gepaarte Nutzer (Sign in with Apple); Widgets zeigen immer sinnvolle Inhalte/States.

**Erfolgskriterien:**
- App kompiliert und läuft im Simulator und auf Device (Deployment Target kompatibel mit iOS 16+).
- Pairing: Owner erstellt Code (mit Apple-Anmeldung), Partner löst ein; Sync (Push/Pull) über CloudKit; 1:1-Zuordnung über ownerAppleId/partnerAppleId.
- Setup: Cities (Land → Stadt oder „Standort verwenden“), Note/Countdown setzen; Änderungen werden beim Partner angezeigt (Pull bei App-Start / .active).
- Widgets zeigen Werte oder klare CTAs (nie „leer“); Distanz/Countdown/Note konsistent mit App.
- Optional: Partner erhält Push-Benachrichtigung, wenn die andere Person die Note aktualisiert.

---

## 2) Scope

**In Scope:**
- **Pairing:** Sign in with Apple; Owner erstellt/regeneriert Invite-Code, Partner löst ein. 1:1-Bindung über CloudKit (ownerAppleId/partnerAppleId). „Buy (simulate)“ für lokale Tests ohne IAP.
- **Sync:** CloudKit Public Database; Push bei Commit (Speichern), Pull bei App-Start und bei Wechsel in den Vordergrund (.active). Nur Owner/Partner mit passender Apple-ID können Daten lesen/schreiben.
- **2 Profile:** Me und Partner; Daten aus Cache (lokal + nach Pull); Namen in Einstellungen editierbar.
- **Locations:** Preset-Liste (Land → Stadt, alphabetisch) **plus** optional „Standort verwenden“ (einmalige Abfrage, Reverse-Geocoding); optional Hintergrund-Updates (significant location changes) für Widget.
- Distanz (km, Haversine), Countdown (days/h/min, Kalender-Tage konsistent), Single Note mit Autor (Me/Partner), Streak (rolling 24h).
- **Push-Benachrichtigung:** Bei Note-Update des Partners → CloudKit-Subscription → lokale Notification „Neue Notiz / From [Name]“.
- 3 Lock-Screen-Widgets: Distance, Countdown, Note; Home + Lock Screen; Deep Links (app://distance, countdown, note, pairing).
- UI: SwiftUI, Karten-Layout, Icons, 44pt-Touch-Targets, L10n (DE/EN/System), Empty States, Haptik beim Speichern.

**Out of Scope:**
- Echte IAP / Receipt-Verification.
- Eigenes Backend (nur CloudKit).

---

## 3) Kernentscheidungen (final)

- **Sync:** CloudKit Public Database; Record Type „Couple“, recordName = normalisierter Invite-Code (ohne Bindestrich). Owner/Partner-Apple-IDs im Record; Pull nur bei angemeldetem Nutzer.
- **Pairing:** Sign in with Apple erforderlich für Code-Erstellung und Einlösen; 1:1 pro Code; Regenerate löscht alten Record; Unlink (Partner) gibt Partner-Slot frei.
- **Location:** City-Presets (Land → Stadt) plus optional „Standort verwenden“ (CoreLocation, Reverse-Geocoding); optional Hintergrund-Updates (significant location changes) für Widget; MapKit `addressRepresentations` (kein deprecated `placemark`).
- **Widgets:** Lesen nur App-Group-Cache; nach Commit und nach Pull wird `WidgetCenter.reloadAllTimelines()` aufgerufen.
- **Mini-Label:** „A ↔ B“ (Initials). **Units:** Nur km.
- **Countdown:** Kalender-Tage für „X days“ (konsistent Editor/Widget); optionales `label`, leer → „Countdown“.
- **Note:** max 100 Zeichen, Autor als Rolle (Me/Partner); Anzeige mit aktuellen Profil-Initialen; Push-Benachrichtigung beim Partner bei Update.
- **Streak:** Rolling 24h. **Cities:** Land → Stadt alphabetisch; optional Standort. **Sprache:** DE/EN/System (L10n).

---

## 4) Datenmodell (lokal) – Implementierungsstand

**UserProfile / Cache-Profil:**  
`name`, `initials` (max 3, uppercase alphanumerisch, Fallback A/B), `cityLabel`, `lat`, `lon` (aus CityPreset).

**CoupleState:**  
`paired`, `role` (none | owner | partner), `entitlement` (locked | unlocked), `inviteCode?`.

**Countdown:**  
`eventAtUTC: Date?`, **`label: String?`** (optionaler Anzeigename, max 30 Zeichen; leer → „Countdown“).  
`displayTitle()`: label getrimmt oder „Countdown“. Cache-Key `cg.countdownLabel`.

**Note:**  
- `text: String`  
- `authorInitials: String` (weiter gespeichert für Kompatibilität)  
- **`authorIsMe: Bool?`** (true = Me, false = Partner, nil = Legacy; für Anzeige mit aktuellen Initialen)  
- `updatedAtUTC: Date?`  

**Streak:**  
`streakCount`, `longestStreak`, `lastNoteAtUTC?`.

**CityPreset:**  
- `name`, **`country: String`**, `lat`, `lon`.  
- **CountryPreset:** `name`, `cities: [CityPreset]`; `CountryPreset.all` länder- und städteweise alphabetisch sortiert.

**Abgeleitet:**  
`distanceKm` (Int, Haversine), `countdownDisplay` (String), **Note-Anzeige:** `displayAuthorInitials(meInitials:partnerInitials:)` nutzt `authorIsMe` und aktuelle Me/Partner-Initialen.

---

## 5) Pairing & Entitlement (mit CloudKit)

**Implementiert:**  
Sign in with Apple für Code-Erstellung und Einlösen. State Machine (unpaired_locked, owner_unlocked, partner_unlocked), Buy (simulate), Generate/Regenerate Code, Redeem Code, Unlink.  
- **CloudKit:** ownerAppleId/partnerAppleId im Record; nur dieses Paar kann pushen/pullen. Partner-Slot pro Code einmalig; bei Konflikt „Code bereits vergeben“ + Unlink. Regenerate löscht alten CloudKit-Record; Unlink (Partner) setzt partnerAppleId im Record auf nil.  
- Invite-Code-Format XXXX-XXXX, Base32 ohne 0,O,1,I; leerer Record-Name (z. B. „----“) wird abgefangen.  
- Persistenz: App-Group-Cache; Sync Push/Pull siehe **docs/CLOUDKIT.md**, **CoupleWidgets/docs/APPLE_SIGNIN_AND_PAIRING.md**.

---

## 6) Location – Implementierungsstand

- **Presets:** Beide Profile wählen **zuerst Land, dann Stadt** aus vordefinierten Listen (Koordinaten fix). Länder alphabetisch: China, Deutschland, Frankreich, Großbritannien, Italien, Niederlande, Österreich, Schweiz, Spanien, USA. Städte pro Land alphabetisch; Lookup `CityPreset.cityByName(_:)`, `CacheSnapshot.meCity`/`partnerCity`.
- **Optional „Standort verwenden“:** Button in Cities (YOUR LOCATION); einmalige When-In-Use-Berechtigung, `requestCurrentLocation()`, Reverse-Geocoding (MapKit `MKReverseGeocodingRequest`, `addressRepresentations` für cityName/regionName – kein deprecated `placemark`). Ergebnis → `setMyLocation(lat:lon:cityLabel:country:)`; optional Always-Berechtigung anfragen.
- **Optional Hintergrund:** Bei Always-Berechtigung `startMonitoringSignificantLocationChanges()`; bei Update Schreiben in Cache (`applyLocationToCache`) + `WidgetCenter.reloadAllTimelines()`; Notification `.locationCacheDidUpdate` für App-Refresh. Siehe **CoupleWidgets/docs/BACKGROUND_LOCATION.md**.

---

## 7) Distanz (km)

**Implementiert:** Haversine zwischen Me.city und Partner.city, Rundung auf ganze km, Anzeige „X km“. Mini-Label „A ↔ B“. Empty States: nicht gepaired/locked → „Connect“; Stadt fehlt → „Set city“.

---

## 8) Countdown (days/h/min)

**Implementiert:** Formatter mit **Kalender-Tagen** für „X days“ (konsistent mit Editor: `Calendar.current.startOfDay`), danach Stunden/Minuten mit CEIL; T ≤ 0 → „0 min“. Empty State: „Set date“.  
**Countdown-Label:** Optionaler Name (z. B. „Wiedersehen“, max 30 Zeichen) im Editor; Anzeige in Home-Kartentitel, Countdown-Widget (accessoryRectangular ggf. gekürzt). Leer → „Countdown“. Sync über CloudKit (eventAtUTC, countdownLabel).

---

## 9) Note (single) + Author – Implementierungsstand

- Eine Note pro Couple; Update überschreibt; Sync über CloudKit (Push bei Save, Pull bei App-Start/.active).
- Max 100 Zeichen, Trim Whitespace. Gespeichert: `authorInitials`, **`authorIsMe`** (optional für Legacy), `updatedAtUTC`.
- **Anzeige (App + Widget):** `displayAuthorInitials(meInitials:partnerInitials:)` → aktuelle Me/Partner-Initialen; Legacy-Notes ohne `authorIsMe`: Inferenz aus Initialen vs. Profilen. Widget-Text: „{displayInitials}: {noteText}“.
- **Push-Benachrichtigung:** Wenn der Partner die Note speichert, erhält das andere Gerät eine CloudKit-Notification → Pull → lokale Notification „Neue Notiz / From [PartnerName]“ (nur wenn noteUpdatedAt sich geändert hat). CloudKitSubscriptionService + AppDelegate; Option „Partner benachrichtigen“ im Note-Editor (UI vorhanden).
- Empty States: not paired/locked → „Connect“; Note leer → „Tap to write“.

---

## 10) Streak (rolling 24h)

**Implementiert:** Bei Note-Update: lastNoteAtUTC nil → streak=1, longest=1; 24h ≤ delta < 48h → streak += 1; ≥ 48h → streak = 1; longest = max(longest, streak). First-Launch-Default: streakCount=1, longestStreak=1 (nicht 0).

---

## 11) Widgets (WidgetKit) – Implementierungsstand

- **3 Widgets:** DistanceWidget, CountdownWidget, NoteWidget.
- **Unterstützte Familien:** `.accessoryCircular`, `.accessoryInline`, `.accessoryRectangular`, `.systemSmall`, `.systemMedium` (alle drei Widgets).
- **Darstellung:** **Lock Screen** (accessory*-Families): transparenter Container, nur weiße Linien und Text (clean). **Home Screen** (systemSmall/systemMedium): dunkler Gradient-Hintergrund (WidgetViewHelpers), weiße Schrift. `widgetContainerBackground(transparentForAccessory:)` je nach Familie.
- **Distance:** Lock Screen: Inline = „JH • 8,642 km • DY“; Rectangular = Initials links | Zahl + „km apart“ | Initials rechts; Circular = Kreis-Stroke + Mini-Label/Wert/km. Home: small/medium wie zuvor (paperplane, Distance, mainText).
- **Countdown:** Lock Screen: Circular/Inline/Rectangular mit white stroke + titleText/mainText; Home: small/medium mit Titel + Anzeige.
- **Note:** Lock Screen: Circular = bubble.left.fill + authorInitials; Rectangular = Icon + noteText + „— authorInitials“; Inline = Icon + mainText. NoteEntry: authorInitials, noteText. Home: small/medium mit Emerald-Akzent, „— authorInitials“.
- **Regeln:** Kein Timestamp im Widget; Lesen nur aus App-Group-Cache; Timeline alle 30 Min für 12h; nach Änderung Cache schreiben + `WidgetCenter.reloadAllTimelines()`.
- **Deep Links (widgetURL):** app://distance, app://countdown, app://note, app://pairing.

---

## 12) Cache (App Group) – Implementierungsstand

- **Suite:** `group.com.yourcompany.couplewidgets` (für Produktion ggf. ersetzen; siehe **docs/APP_GROUP_SETUP.md**).
- **Keys:** Profile (myName, partnerName, …), Countdown (eventAtUTC, countdownLabel), Note (noteText, noteAuthorIsMe, noteUpdatedAt), Streak, **`cg.pendingDeleteInviteCode`** (optional; alter Code zum Löschen nach Regenerate, wird bei .active retry gelöscht).
- **Sprache:** `appLanguage` („de“ | „en“ | „system“), nur App-intern.
- **First-Launch-Defaults:** paired=false, entitlement=locked, role=none; distanceKm=0, distanceLabel="A ↔ B"; countdownDisplay="Set date"; noteText="", noteAuthorInitials="A", noteAuthorIsMe=true; streakCount=1, longestStreak=1.

---

## 13) UI – Implementierungsstand

- **Home:** 3 Karten (Distance, Countdown, Note) mit Icons, große Typo, Chevron rechts. Status-Karte (Pairing + lastCacheWriteAt), Footer „By {me.initials} for {partner.initials}". Toolbar: NavigationTitle = App-Titel (für System-Back-Label); **Einstellungs-Menü** (ellipsis) mit nur **Pairing + Einstellungen** („Cities“ entfernt). L10n. Countdown-Kartentitel = displayTitle(). **Akzentfarbe:** Blau. **Offen:** Sichtbarkeit Einstellungs-Button und Chevrons auf allen Geräten.
- **Pairing:** Form mit **drei Sections:** (1) **Status** (Paired, Role, Entitlement), (2) **Aktionen** (Buy simulate, Invite code + Copy, Generate/Regenerate, Unlink), (3) **Code einlösen** (TextField mit Placeholder XXXX-XXXX, Button „Code einlösen“ in Akzentfarbe, Footer-Erklärung). Section-Header semibold, alle Pairing-Texte **lokalisiert** (L10n). Redeem-Button `.buttonStyle(.borderedProminent)`. onAppear → refreshFromCache().
- **Cities (Distance):** Namen nur aus Snapshot (editierbar in Einstellungen). **Zwei Stufen:** Picker Me/Partner – Land, dann Stadt. Save in Toolbar (L10n „Speichern“/„Save“), `.buttonStyle(.plain)`. Unten Section **„Zurücksetzen“** mit destructive Button + Bestätigungs-Alert (resetDistance). System-Back, weiße Nav-Bar.
- **Countdown Editor:** IOSSection (STATUS, CONFIGURATION, DATE & TIME, NOTIFICATIONS, STATISTICS, WIDGET PREVIEW, **Zurücksetzen**). Date/Time per Sheet. CountdownScreenPreviewView (orange→rot, 280pt). Bei deaktiviert: STATUS + IOSEmptyState. Toolbar Save (L10n), System-Back. Reset mit Bestätigungs-Alert (resetCountdown).
- **Note Editor:** IOSSection (CONFIGURATION, DISPLAY OPTIONS, NOTIFICATIONS, STATISTICS, WIDGET PREVIEW, **Zurücksetzen**). NoteScreenPreviewView (Emerald→Teal, 280pt). Save validiert leere Note. System-Back. Reset mit Bestätigungs-Alert (resetNote).
- **Distance View (CitiesView):** IOSSection YOUR/PARTNER LOCATION, DISPLAY OPTIONS, NOTIFICATIONS, STATISTICS, WIDGET PREVIEW, **Zurücksetzen**. DistanceScreenPreviewView (paperplane, Gradient). L10n. System-Back, weiße Nav-Bar.
- **Settings:** **Profil** (Dein Name, Partner-Name, Save). **Sprache** (Picker DE/EN/System). **App** (Version, Kurzbeschreibung). **Widgets** (Anleitung + Footer). **Rechtliches** (Datenschutz, **Impressum mit DE/EN-Vorlage + Platzhaltern**). **Support** (mailto, App bewerten). Alle lokalisiert.
- **Deep Links:** app://distance, app://countdown, app://note, app://pairing (in ContentView.onOpenURL → NavigationStack path).
- **Komponenten:** CardView, **SaveButtonBar** (Haptik, L10n). **IOSComponents:** IOSSection, IOSSelectRow, IOSToggleRow, IOSInputRow, **IOSDatePickerRow** (Sheet, grafischer Kalender), **IOSTextAreaRow** (maxLength, Zeichenzähler), **IOSEmptyState**, IOSStatCard, IOSWidgetPreview. Section-Überschriften und IOSWidgetPreview-Titel `.footnote`; IOSStatCard Label/Value `.body`. Keine Divider zwischen Zeilen in IOSSection-Inhalten (Note/Countdown/Cities). 44pt-Touch-Targets wo umgesetzt.

---

## 14) Tests (Unit Tests)

**Vorhanden:**  
- Streak-Grenzen (23:59 / 24:00 / 47:59 / 48:00).  
- Countdown-Grenzen (24h / 23h01m / 59m01s / past).  
- Distance-Sanity: Berlin ↔ New York City > 0 km (CityPreset.all).

**Nicht ergänzt (optional):**  
- Note `displayAuthorInitials` (authorIsMe + Legacy).  
- CountryPreset / CityPreset.country.

---

## 15) Was wurde gestrichen / geändert (inkl. letzte Updates)

- **Streak First Launch:** PRD ursprünglich streakCount=0; implementiert 1/1 (Widget zeigt sinnvoll „1“).
- **Cities:** Kein flacher Ein-Picker mehr; ersetzt durch Land → Stadt, alphabetisch.
- **Note-Anzeige:** Ursprünglich nur authorInitials; erweitert um authorIsMe + displayAuthorInitials, damit Namensänderungen in Cities sofort in der Note-Anzeige sichtbar sind.
- **Countdown:** Um optionales **label** (Anzeigename) ergänzt; Kartentitel und Widget zeigen eigenen Namen oder „Countdown“.
- **Settings:** Platzhalter durch echte Einstellungen ersetzt (Version, Widgets, Rechtliches, Support) plus **Sprachwahl** (DE/EN/System).
- **Lokalisierung:** In-App-Umsetzung mit **L10n** + **LanguageManager**; keine .lproj-Dateien, alle relevanten App-Strings DE/EN; **Pairing** vollständig lokalisiert (Status/Aktionen/Code einlösen, Button, Footer, Placeholder).
- **UX:** **Haptik** beim Speichern (SaveButtonBar); **Empty-State-Erklärungen** auf Distance-, Countdown- und Note-Screens unter den CTAs.
- **Navigation:** Zurück-Button oben links auf allen Detail-Views; Inline-NavigationBar + toolbarBackground; navigationDestination an HomeView (nicht am Stack) für funktionierende Links.
- **Akzentfarbe:** Von Peach/Orange auf **Blau** umgestellt (AccentColor.colorset); einheitliche blaue CTAs und Menü-Icons.
- **Home:** Einstellungs-Button als **„Einstellungen“ + Zahnrad** (Capsule) in Akzentfarbe; **Chevrons** auf Distance-/Countdown-/Note-Karten für erkennbare Klickbarkeit.
- **Pairing:** Redeem von safeAreaInset in **Form-Section „Code einlösen“** verschoben; Redeem-Button prominent (borderedProminent); bessere Kontrast-Texte (primary/secondaryLabel); L10n für alle Pairing-Texte.
- **iOS 16:** PairingView nutzt durchgängig `.foregroundColor` statt `.foregroundStyle` (Kompatibilität).
- **Countdown/Note-Editor:** Form durch ZStack + ScrollView + IOSSection ersetzt (Figma-Spec); Date/Time per Sheet, IOSTextAreaRow, Widget-Preview-Views (CountdownScreenPreviewView, NoteScreenPreviewView).
- **Distance (CitiesView):** „Use location“-Button aus YOUR LOCATION entfernt; Icons (ruler, globe, paperplane); toolbarBackground(systemBackground) für weiße Nav-Bar; Reset-Section unten.
- **Namen:** Nur in Einstellungen (Profil) editierbar; Distance/Pairing lesen nur aus Snapshot.
- **Navigation:** System-Back (kein Custom-Button); HomeView.navigationTitle = Back-Label; Save `.buttonStyle(.plain)`, `.tint(Color.blue)` zentral.
- **Menü:** „Cities“ aus Drei-Punkte-Menü entfernt; nur Pairing + Einstellungen.
- **Reset:** Von HomeView-Menü auf Konfig-Screens (Distance, Countdown, Note) verschoben; je Section „Zurücksetzen“ + Alert.
- **Impressum:** Vollständige DE/EN-Vorlage mit Platzhaltern in SettingsView.
- **Widget-UI:** Lock Screen: transparent + weiße Linien (Strokes, kein Fill); Home: dunkler Gradient. Distance Inline/Rectangular vereinfacht; Note mit Circular, bubble-Icon, noteText/authorInitials.
- **CloudKit & Sign in with Apple:** Pairing an Apple-ID gebunden; Sync (Push/Pull) über CloudKit Public Database; ownerAppleId/partnerAppleId; Regenerate löscht alten Record, Unlink (Partner) gibt Slot frei; Pull nur bei Anmeldung; Sync-Fehler bei .active als Alert; Redeem-Erfolg erst nach syncPull.
- **Push-Benachrichtigung:** CloudKit-Subscription auf Couple-Record; bei Note-Update lokale Notification „Neue Notiz / From [Name]“ (AppDelegate, CloudKitSubscriptionService); Capabilities: Push Notifications, Background Modes → Remote notifications.
- **Standort:** „Standort verwenden“ in Cities; Reverse-Geocoding mit addressRepresentations; optional Hintergrund-Updates; Notification für App-Refresh bei Cache-Update. Countdown: Kalender-Tage im Formatter.

---

## 16) App-Capabilities (aktueller Stand)

- **Sync:** CloudKit (Public Database), Sign in with Apple; 1:1-Pairing, Push/Pull bei Start und .active; Alerts bei Sync-Fehler und „Code bereits vergeben“.
- **Push:** CloudKit-Subscription, lokale Notification bei neuer Note; Push Notifications + Remote notifications Capability.
- **Lokal/Cache:** 2 Profile (Me/Partner), Namen in Einstellungen, Stadtwahl (Land → Stadt) oder „Standort verwenden“, Distanz (Haversine), Countdown (Kalender-Tage), Note mit Autor, Streak (24h); App-Group-Cache, pendingDeleteInviteCode für Regenerate-Retry.
- **Widgets:** 3 Widgets (Distance, Countdown, Note), Lock + Home Screen; Deep Links; Reload nach Commit und Pull.
- **Sprache:** DE/EN/System; gesamte UI inkl. App-Beschreibung (iCloud-Sync) lokalisiert.
- **Einstellungen:** Profil, Sprache, App-Info (inkl. Sync-Hinweis), Widget-Anleitung, Datenschutz, Impressum (Vorlage), Support, App bewerten. **Reset** pro Widget auf Konfig-Screen.
- **Design:** Karten-UI, systemGroupedBackground, blaues Akzent, IOSSection/IOSStatCard.

---

## 17) Next Steps (aus aktualisierter PRD)

1. **Impressum:** Platzhalter in `imprintContentDE` / `imprintContentEN` (SettingsView) mit echten Anbieterdaten ersetzen.
2. **Support/Review:** mailto und App-Store-Review-URL in Settings durch echte Werte ersetzen.
3. **App Group / iCloud:** Suite-Name und iCloud-Container (z. B. `com.yourcompany`) in Entitlements und Xcode an eigenes Team anpassen; siehe **docs/APP_GROUP_SETUP.md**, **CoupleWidgets/docs/APPLE_SIGNIN_AND_PAIRING.md**. CloudKit-Schema (Record Type „Couple“, Felder inkl. ownerAppleId/partnerAppleId) in CloudKit Console für Production deployen; siehe **docs/CLOUDKIT.md**.
4. **Xcode:** Apple-ID in Settings → Accounts; Signing & Capabilities → Team, iCloud, ggf. Push Notifications + Background Modes → Remote notifications.
5. **Distance-Screen / UI-Kontrast:** Falls Schrift oder Einstellungs-Button/Chevrons auf Geräten problematisch, .foregroundStyle(.primary) bzw. Kontrast prüfen.
6. **Tests:** Optional displayAuthorInitials, displayTitle/label, CountryPreset, CloudKit/Pairing-Edge-Cases.
7. **Accessibility:** VoiceOver-Labels/Hints, Dynamic Type prüfen.
8. **v1 (Backlog):** Echte IAP; weitere Länder/Städte optional.

---

## 18) To-Do-Liste (abgeleitet aus PRD, aktueller Stand)

| # | Aufgabe | Priorität | Status |
|---|--------|-----------|--------|
| 1 | **Impressum:** Platzhalter mit echten Anbieter-/Kontaktdaten ersetzen (SettingsView) | Hoch | Offen |
| 2 | **Support:** E-Mail und App-Store-Review-Link ersetzen | Hoch | Offen |
| 3 | **App Group / iCloud:** Suite und Container an eigenes Team anpassen (Entitlements + Xcode) | Hoch | Offen |
| 4 | **CloudKit Production:** Schema „Couple“ in Console deployen (docs/CLOUDKIT.md) | Hoch | Offen |
| 5 | **Xcode Signing:** Apple-ID + Team; iCloud/Push-Capabilities prüfen | Hoch | Offen |
| 6 | **Distance-Screen / Einstellungs-Button / Chevrons:** Kontrast prüfen (falls nötig) | Mittel | Offen |
| 7 | **Unit-Tests:** displayAuthorInitials, Countdown label, CountryPreset, Sync-Edge-Cases (optional) | Mittel | Offen |
| 8 | **Accessibility:** VoiceOver, Dynamic Type prüfen | Mittel | Offen |
| 9 | Weitere Länder/Städte in CountryPreset.all (optional) | Niedrig | Offen |
| 10 | **v1:** Echte IAP planen | Später | Backlog |
