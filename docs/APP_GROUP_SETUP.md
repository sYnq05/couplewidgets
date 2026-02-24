# App Group einrichten – damit die Widgets funktionieren

Die Widgets (Distance, Countdown, Note) lesen ihre Daten aus dem **App Group**-UserDefaults. Ohne eingerichtete App Group können App und Widget-Extension die Daten nicht teilen – die Widgets zeigen dann nur Platzhalter.

**Diese Schritte musst du einmal im Apple Developer Account und in Xcode erledigen.** Danach funktionieren die Widgets mit den lokalen Daten (ohne Cloud).

---

## Wichtige Werte aus dem Projekt

| Was | Wert |
|-----|------|
| App Group ID (überall gleich verwenden) | `group.com.yourcompany.couplewidgets` |
| Haupt-App Bundle ID | `CoupleWidgets.CoupleWidgets` |
| Widget-Extension Bundle ID | `CoupleWidgets.CoupleWidgets.widgets` |

Die Entitlements und `AppGroupKeys.suiteName` im Code nutzen bereits diese App Group ID. Du musst sie nur im Developer Portal anlegen und den App-IDs zuweisen.

---

## Schritt 1: App Group im Developer Portal anlegen

1. Öffne [developer.apple.com](https://developer.apple.com) und melde dich an.
2. Gehe zu **Account** → **Certificates, Identifiers & Profiles**.
3. Links: **Identifiers** → oben **App Groups** auswählen → **+** (Neu).
4. **Description:** z. B. `CoupleWidgets Shared`.
5. **Identifier:** exakt eintragen:  
   `group.com.yourcompany.couplewidgets`  
   (Kein Leerzeichen, genau so wie oben.)
6. **Continue** → **Register**.

---

## Schritt 2: App-IDs die App Group zuweisen

### Haupt-App

1. Unter **Identifiers** zu **App IDs** wechseln.
2. Deine **Haupt-App** auswählen (Bundle ID: `CoupleWidgets.CoupleWidgets`).
3. **Edit** (oder **Configure** bei App Groups).
4. **App Groups** aktivieren (Haken setzen).
5. **Edit** bei App Groups → die Gruppe **group.com.yourcompany.couplewidgets** auswählen → **Continue** → **Save**.

### Widget-Extension

1. Ebenfalls unter **Identifiers** → **App IDs** die **Widget-Extension** auswählen (Bundle ID: `CoupleWidgets.CoupleWidgets.widgets`).
2. **Edit** → **App Groups** aktivieren.
3. **Edit** bei App Groups → **dieselbe** Gruppe **group.com.yourcompany.couplewidgets** auswählen → **Continue** → **Save**.

---

## Schritt 3: Provisioning in Xcode aktualisieren

1. Xcode öffnen → Projekt **CoupleWidgets**.
2. **Haupt-App-Target** (CoupleWidgets) auswählen → **Signing & Capabilities**.
   - Wenn unter **App Groups** noch keine Gruppe steht: **+ Capability** → **App Groups** → Gruppe **group.com.yourcompany.couplewidgets** hinzufügen (oder den Haken setzen).
   - Die Datei `CoupleWidgets.entitlements` enthält die Gruppe bereits – Xcode sollte sie hier anzeigen.
3. **Widget-Target** (CoupleWidgetsWidgets) auswählen → **Signing & Capabilities**.
   - Ebenfalls **App Groups** prüfen und **group.com.yourcompany.couplewidgets** auswählen.
4. Bei **Signing** „Automatically manage signing“ aktiviert lassen, damit Xcode die neuen Profile lädt.

---

## Schritt 4: App neu installieren und testen

1. App auf dem **Gerät** (oder Simulator) **deinstallieren** (lange drücken → App entfernen).
2. In Xcode: **Product** → **Clean Build Folder** (Shift+Cmd+K).
3. **Product** → **Run** (Cmd+R) – App wird neu gebaut und installiert.
4. App öffnen, z. B. unter **Distance** Städte wählen, unter **Note** etwas eintragen, unter **Countdown** Datum setzen.
5. Auf dem Home Screen **Widget hinzufügen**: lange auf den Hintergrund tippen → **+** → „CoupleWidgets“ / Distance, Countdown oder Note auswählen.
6. Die Widgets sollten jetzt die **lokalen** Daten anzeigen (ohne Cloud).

---

## Wenn du eine eigene App Group ID verwenden willst

Wenn du z. B. `group.de.jakobhartmann.CoupleWidgets` nutzen möchtest:

1. Diese ID im Developer Portal als **neue** App Group anlegen und wie oben beiden App-IDs zuweisen.
2. Im Projekt **drei Stellen** anpassen (identische ID):
   - **AppGroupKeys.swift:**  
     `static let suiteName = "group.de.jakobhartmann.CoupleWidgets"`
   - **CoupleWidgets/CoupleWidgets.entitlements:**  
     im Array `<string>group.de.jakobhartmann.CoupleWidgets</string>`
   - **CoupleWidgetsWidgets/CoupleWidgetsWidgets.entitlements:**  
     dasselbe `<string>...</string>`
3. In Xcode unter **Signing & Capabilities** bei beiden Targets die neue Gruppe auswählen.
4. App neu bauen und installieren (Schritt 4 oben).

---

## Kurzfassung

- **Ursache:** Die App Group `group.com.yourcompany.couplewidgets` ist im Developer Account nicht angelegt bzw. nicht den App-IDs zugewiesen → App und Widgets nutzen unterschiedliche Speicher.
- **Lösung:** App Group im Portal anlegen, beiden App-IDs (Haupt-App + Widget) zuweisen, in Xcode App Groups prüfen, App neu installieren. Danach funktionieren die Widgets mit den lokalen Daten.
