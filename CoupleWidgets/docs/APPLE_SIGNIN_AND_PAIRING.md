# Sign in with Apple und 1:1-Pairing

Die App nutzt **Sign in with Apple**, um das Pairing an ein Apple-Konto zu binden. So kann jeder Nutzer nur mit **einem** Partner verbunden sein, und ein Einladungscode kann nur von **einem** Partner eingelöst werden.

## Xcode

- **Sign in with Apple:** Beim App-Target unter **Signing & Capabilities** → **+ Capability** → **Sign in with Apple** hinzufügen.
- **iCloud:** Die Capability **iCloud** ist in den Entitlements eingetragen (Container: `iCloud.com.yourcompany.couplewidgets`). Falls Xcode „Provisioning profile doesn't include the iCloud capability“ meldet: **Xcode → Settings → Accounts** öffnen, Apple-ID hinzufügen bzw. anmelden, dann im Projekt unter **Signing & Capabilities** das richtige Team wählen. Xcode erzeugt dann ein neues Profil inkl. iCloud.
- **„No Account for Team …“:** In **Xcode → Settings → Accounts** (⌘,) die verwendete Apple-ID prüfen bzw. hinzufügen und das gleiche Team unter **Signing & Capabilities** für das App-Target auswählen.

## Ablauf

1. **Owner** meldet sich mit Apple an, erstellt/regeneriert einen Code. Beim ersten Push wird `ownerAppleId` (stabile User-ID von Apple) im CloudKit-Record gespeichert.
2. **Partner** meldet sich mit Apple an und gibt den Code ein. Beim ersten Push prüft die App, ob `partnerAppleId` im Record schon gesetzt ist:
   - **Noch frei:** Die Apple-ID des Partners wird als `partnerAppleId` gespeichert – Verbindung steht.
   - **Bereits vergeben** (anderes Apple-Konto): Der Code wird lokal zurückgesetzt, Alert „Code bereits vergeben“.
3. **Sync (Pull):** Nur wenn die aktuelle Apple-ID entweder `ownerAppleId` oder `partnerAppleId` im Record ist, werden Daten geladen. So haben nur die beiden verbundenen Konten Zugriff.

## CloudKit-Schema (Record Type „Couple“)

Zusätzlich zu den bestehenden Feldern (ownerName, partnerName, …) werden verwendet:

| Feld              | Typ    | Beschreibung |
|-------------------|--------|--------------|
| `ownerAppleId`    | String | Apple User Identifier des Erstellers (Owners). |
| `partnerAppleId`  | String | Apple User Identifier des Partners (wird beim ersten Einlösen gesetzt). |

Diese Felder im CloudKit Dashboard anlegen, falls sie nicht per Code-Create automatisch entstehen.

## Technik

- **AppleAuthService:** Speichert die User-ID nach Sign in with Apple im Keychain, stellt `currentUserIdentifier` und `isSignedIn` bereit.
- **CloudKitSyncService.push:** Owner setzt `ownerAppleId`; Partner holt den Record, prüft `partnerAppleId` und setzt die eigene ID nur, wenn der Slot frei ist (Rückgabe `.partnerSlotAlreadyTaken` bei Konflikt).
- **CloudKitSyncService.pull:** Liefert nur dann Daten, wenn die aktuelle Apple-ID mit `ownerAppleId` oder `partnerAppleId` übereinstimmt.
