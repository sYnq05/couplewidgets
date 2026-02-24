# CloudKit Sync – Setup

Die App synchronisiert Paar-Daten (Städte, Countdown, Note, Streak) über CloudKit (Public Database). Der Invite-Code dient als Record-Name.

**Ohne Apple Developer Program (kostenloser Account):** iCloud/CloudKit sind in den Entitlements deaktiviert, damit die App baut. Pairing (Code generieren / einlösen) funktioniert lokal auf jedem Gerät; echte Sync-Datenübertragung zwischen Geräten gibt es erst mit aktiviertem CloudKit. Zum Reaktivieren: iCloud-Capability in Xcode wieder hinzufügen, die beiden Einträge in `CoupleWidgets/CoupleWidgets.entitlements` (icloud-container-identifiers, icloud-services) wieder eintragen und im Developer Program anmelden.

## 1. Xcode (einmalig)

1. Projekt in **Xcode** öffnen.
2. App-Target **CoupleWidgets** auswählen → **Signing & Capabilities**.
3. **+ Capability** → **iCloud** hinzufügen.
4. Bei iCloud **CloudKit** anhaken.
5. Unter **Containers** den Container **iCloud.com.yourcompany.couplewidgets** anhaken (oder **+** klicken und diesen Namen anlegen).

Die Datei `CoupleWidgets/CoupleWidgets.entitlements` enthält die Einträge bereits; Xcode verknüpft damit den Container und das Profil.

Falls du eine andere Container-ID nutzt, in `CloudKitSyncService.swift` anpassen:

```swift
static let containerID = "iCloud.deine.container"
```

## 2. CloudKit-Schema (Development)

**In der Development-Umgebung musst du nichts anlegen:** Beim ersten **Push** (App starten → Pairing „Buy (simulate)“ → z.B. in Cities etwas speichern) erzeugt CloudKit den Record Type **Couple** und die Felder automatisch.

Für **Production** (Release): In der [CloudKit Console](https://icloud.developer.apple.com/) → dein Container → **Schema** → **Public Database** → **Production** den Record Type **Couple** anlegen und nach **Deploy to Production** ausführen. Feldliste (alle optional):

| Field Name         | Type    |
|--------------------|--------|
| inviteCode         | String |
| ownerName          | String |
| ownerInitials      | String |
| ownerCityLabel     | String |
| ownerCountry       | String |
| ownerLat           | Double |
| ownerLon           | Double |
| partnerName        | String |
| partnerInitials    | String |
| partnerCityLabel   | String |
| partnerCountry     | String |
| partnerLat         | Double |
| partnerLon         | Double |
| eventAtUTC         | Double |
| countdownLabel     | String |
| noteText           | String |
| noteAuthorInitials | String |
| noteAuthorIsMe     | Int(64) |
| noteUpdatedAt      | Double |
| streakCount        | Int(64) |
| longestStreak      | Int(64) |
| lastNoteAt         | Double |

## 3. Ablauf

- **Owner:** „Buy (simulate)“ → Invite-Code wird erzeugt. Beim nächsten **Commit** (z.B. Speichern in Cities) wird ein `Couple`-Record mit `recordName = Code ohne Bindestrich` (z.B. `ABCD1234`) in der Public Database angelegt/aktualisiert.
- **Partner:** Code einlösen (lokal) → gleicher Code. Beim **App-Start** und beim **Wechsel in den Vordergrund** wird `syncPull()` ausgeführt: Record wird anhand des Codes geladen und in den lokalen Cache geschrieben (Partner sieht Owner-Daten).
- Beide Geräte **pushen** bei jedem Speichern (Commit) und **pullen** beim Start und bei Aktivierung der App; so bleiben die Daten abgeglichen.
