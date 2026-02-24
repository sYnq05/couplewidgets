# Hintergrund-Standort

Die App kann den Standort im Hintergrund nutzen, damit sich die Distanz im Widget aktualisiert, wenn du unterwegs bist.

## Was ist umgesetzt

- **Berechtigung:** Zusätzlich zu „Beim Verwenden“ wird „Immer“ angeboten (`NSLocationAlwaysAndWhenInUseUsageDescription` in `Config/App-Info.plist`). Nach dem ersten „Mein Standort“ in den Städten kannst du in den Systemeinstellungen auf „Immer“ wechseln (oder die App fragt mit `requestAlwaysAuthorization()`).
- **Hintergrund-Updates:** Sobald „Immer“ erteilt ist, startet `LocationService.startBackgroundMonitoringIfAuthorized()` die Überwachung per **Signifikante Standortänderungen** (`startMonitoringSignificantLocationChanges()`). Das ist batterieschonend.
- **Bei neuer Position:** Der Cache wird mit den neuen Koordinaten für „me“ aktualisiert und alle Widget-Timelines werden neu geladen.
- **Beim Öffnen der App:** Beim Wechsel in den Vordergrund (`.active`) werden Cache und ggf. CloudKit-Sync aktualisiert (`refreshFromCache()`, `syncPull()`).

## Xcode

- **Background Modes:** Im App-Target unter **Signing & Capabilities** → **+ Capability** → **Background Modes** → **Location updates** aktivieren. Alternativ ist `UIBackgroundModes` mit `location` bereits in `Config/App-Info.plist` gesetzt; bei Bedarf reicht die Capability.
- Der `LocationService` lebt in der `ContentView` (`@StateObject`) und wird als `environmentObject` an z. B. `CitiesView` weitergegeben, damit er auch im Hintergrund aktiv bleibt.

## Ablauf für Nutzer

1. In **Städte** auf „Mein Standort“ tippen und Berechtigung „Beim Verwenden“ oder „Immer“ erteilen.
2. Optional: In **Einstellungen → Standort** auf „Immer“ wechseln (oder die App fragt später nach „Immer“).
3. Bei „Immer“: Die App wertet signifikante Standortänderungen aus und aktualisiert Cache und Widgets im Hintergrund.
