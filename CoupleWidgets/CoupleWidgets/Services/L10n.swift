import Foundation

enum L10n {
	/// Pass LanguageManager.resolvedCode
	static func tr(_ key: Key, language code: String) -> String {
		table[key]?[code] ?? table[key]?["en"] ?? key.rawValue
	}

	enum Key: String, CaseIterable {
		// Settings & general
		case settingsTitle = "settings.title"
		case languageSection = "settings.language"
		case languageDe = "settings.language.de"
		case languageEn = "settings.language.en"
		case languageSystem = "settings.language.system"
		case appSection = "settings.app"
		case version = "settings.version"
		case appDescription = "settings.appDescription"
		case widgetsSection = "settings.widgets"
		case widgetsHowTo = "settings.widgetsHowTo"
		case widgetsFooter = "settings.widgetsFooter"
		case legal = "settings.legal"
		case privacy = "settings.privacy"
		case imprint = "settings.imprint"
		case support = "settings.support"
		case contact = "settings.contact"
		case rateApp = "settings.rateApp"
		case profileSection = "settings.profile"
		case accountSection = "settings.account"
		case yourName = "settings.yourName"
		case partnerNameLabel = "settings.partnerName"
		case editNamesInSettings = "settings.editNamesInSettings"
		case savedAlertTitle = "saved.alertTitle"
		case savedAlertMessage = "saved.alertMessage"
		case save = "save"

		// Empty state explanations
		case connectExplanation = "empty.connectExplanation"
		case setCityExplanation = "empty.setCityExplanation"
		case setDateExplanation = "empty.setDateExplanation"
		case tapToWriteExplanation = "empty.tapToWriteExplanation"

		// Distance
		case distance = "distance.title"
		case setCity = "distance.setCity"
		case connect = "distance.connect"

		// Countdown
		case countdown = "countdown.title"
		case setDate = "countdown.setDate"

		// Note
		case note = "note.title"
		case tapToWrite = "note.tapToWrite"

		// Home
		case home = "home.title"
		case appTitle = "home.appTitle"
		case yourWidgets = "home.yourWidgets"
		case pairing = "home.pairing"
		case cities = "home.cities"

		// Navigation
		case back = "nav.back"

		// Pairing
		case pairingStatusSection = "pairing.statusSection"
		case pairingActionsSection = "pairing.actionsSection"
		case pairingRedeemSection = "pairing.redeemSection"
		case pairingRedeemButton = "pairing.redeemButton"
		case pairingRedeemFooter = "pairing.redeemFooter"
		case pairingRedeemPlaceholder = "pairing.redeemPlaceholder"
		case pairingRedeemSuccessTitle = "pairing.redeemSuccessTitle"
		case pairingRedeemSuccessMessage = "pairing.redeemSuccessMessage"
		case pairingRedeemEmptyCode = "pairing.redeemEmptyCode"
		case pairingSignInRequired = "pairing.signInRequired"
		case pairingCodeAlreadyUsedTitle = "pairing.codeAlreadyUsedTitle"
		case pairingCodeAlreadyUsedMessage = "pairing.codeAlreadyUsedMessage"
		case signInWithApple = "auth.signInWithApple"
		case signOut = "auth.signOut"

		// Widget card
		case distanceDescription = "widget.distanceDescription"
		case countdownDescription = "widget.countdownDescription"
		case noteDescription = "widget.noteDescription"
		case widgetResetTitle = "widget.resetTitle"
		case widgetResetMessage = "widget.resetMessage"
		case reset = "widget.reset"
		case cancel = "general.cancel"
		case edit = "general.edit"
		case recommended = "general.recommended"

		// Location
		case useLocation = "location.useLocation"
		case locationDenied = "location.denied"
		case locationUnavailable = "location.unavailable"
		case locationSet = "location.set"
		case locationAlertTitle = "location.alertTitle"

		// Pairing (extra labels)
		case pairingSignInSection = "pairing.signInSection"
		case pairingAppleAccount = "pairing.appleAccount"
		case pairingSignedIn = "pairing.signedIn"
		case pairingPaired = "pairing.paired"
		case pairingRole = "pairing.role"
		case pairingYes = "pairing.yes"
		case pairingNo = "pairing.no"
		case pairingInviteCode = "pairing.inviteCode"
		case pairingRegenerateCode = "pairing.regenerateCode"
		case pairingUnlink = "pairing.unlink"
		case pairingUnlinkConfirmTitle = "pairing.unlinkConfirmTitle"
		case pairingUnlinkConfirmMessage = "pairing.unlinkConfirmMessage"
		case pairingSyncFailedTitle = "pairing.syncFailedTitle"
		case pairingSyncFailedMessage = "pairing.syncFailedMessage"
		case pairingNavTitle = "pairing.navTitle"
		case pairingRoleOwner = "pairing.roleOwner"
		case pairingRolePartner = "pairing.rolePartner"
		case pairingRoleNone = "pairing.roleNone"

		// Cities / Distance
		case citiesYourLocation = "cities.yourLocation"
		case citiesPartnerLocation = "cities.partnerLocation"
		case citiesCountry = "cities.country"
		case citiesCity = "cities.city"
		case citiesSelectCountry = "cities.selectCountry"
		case citiesSelectCity = "cities.selectCity"
		case citiesDisplayOptions = "cities.displayOptions"
		case citiesShowNames = "cities.showNames"
		case citiesNotifications = "cities.notifications"
		case citiesAutoUpdateLocation = "cities.autoUpdateLocation"
		case citiesStatistics = "cities.statistics"
		case citiesTimeDifference = "cities.timeDifference"
		case citiesConnection = "cities.connection"
		case citiesActive = "cities.active"
		case citiesInactive = "cities.inactive"
		case citiesSetBothCities = "cities.setBothCities"
		case citiesPleaseSetBothCities = "cities.pleaseSetBothCities"
		case citiesDistanceNavTitle = "cities.distanceNavTitle"

		// Home
		case homePairingLabel = "home.pairingLabel"
		case homeLastSync = "home.lastSync"
		case homePaired = "home.paired"
		case homeNotPaired = "home.notPaired"
		case homeAppGroupWarning = "home.appGroupWarning"
		case homeConnectNow = "home.connectNow"
		case homeByFor = "home.byFor"

		// Countdown editor
		case countdownStatus = "countdown.status"
		case countdownEnable = "countdown.enable"
		case countdownConfiguration = "countdown.configuration"
		case countdownTitleLabel = "countdown.titleLabel"
		case countdownDateLabel = "countdown.dateLabel"
		case countdownTimeLabel = "countdown.timeLabel"
		case countdownDateAndTime = "countdown.dateAndTime"
		case countdownDailyReminder = "countdown.dailyReminder"
		case countdownDaysRemaining = "countdown.daysRemaining"
		case countdownHoursRemaining = "countdown.hoursRemaining"
		case countdownEventDate = "countdown.eventDate"
		case countdownDisabled = "countdown.disabled"
		case countdownDisabledDescription = "countdown.disabledDescription"
		case countdownTitlePlaceholder = "countdown.titlePlaceholder"
		case countdownDaysRemainingFormat = "countdown.daysRemainingFormat"

		// Note editor
		case noteConfiguration = "note.configuration"
		case noteAuthor = "note.author"
		case noteShowAuthorInitials = "note.showAuthorInitials"
		case noteShowStreak = "note.showStreak"
		case noteNotifyPartner = "note.notifyPartner"
		case noteCurrentStreak = "note.currentStreak"
		case noteLongestStreak = "note.longestStreak"
		case noteLastUpdated = "note.lastUpdated"
		case notePlaceholder = "note.placeholder"
		case noteFromInitials = "note.fromInitials"
		case noteMe = "note.me"
		case notePartnerLabel = "note.partnerLabel"
		case noteNoMessageYet = "note.noMessageYet"
		case notePushNotificationTitle = "note.pushNotificationTitle"
		case notePushNotificationBody = "note.pushNotificationBody"

		// Settings placeholders
		case settingsNamePlaceholder = "settings.namePlaceholder"
		case settingsPartnerPlaceholder = "settings.partnerPlaceholder"

		// General
		case generalConfigure = "general.configure"
		case widgetPreview = "widget.preview"
	}

	private static let table: [Key: [String: String]] = [
		.settingsTitle: ["de": "Einstellungen", "en": "Settings"],
		.languageSection: ["de": "Sprache", "en": "Language"],
		.languageDe: ["de": "Deutsch", "en": "German"],
		.languageEn: ["de": "English", "en": "English"],
		.languageSystem: ["de": "System", "en": "System"],
		.appSection: ["de": "App", "en": "App"],
		.version: ["de": "Version", "en": "Version"],
		.appDescription: ["de": "Distanz, Countdown und Note für euch zwei. Daten werden zwischen euch per iCloud synchronisiert.", "en": "Distance, countdown and note for the two of you. Data syncs between you via iCloud."],
		.widgetsSection: ["de": "Widgets", "en": "Widgets"],
		.widgetsHowTo: ["de": "Widget-Bildschirm lange drücken → Bearbeiten → oben „CoupleWidgets“ wählen und ein Widget hinzufügen.", "en": "Long-press the widget screen → Edit → tap „CoupleWidgets“ at the top and add a widget."],
		.widgetsFooter: ["de": "Distance, Countdown und Note sind als Lock-Screen- und Home-Screen-Widgets verfügbar.", "en": "Distance, Countdown and Note are available as Lock Screen and Home Screen widgets."],
		.legal: ["de": "Rechtliches", "en": "Legal"],
		.privacy: ["de": "Datenschutz", "en": "Privacy"],
		.imprint: ["de": "Impressum", "en": "Imprint"],
		.support: ["de": "Support", "en": "Support"],
		.contact: ["de": "Kontakt", "en": "Contact"],
		.rateApp: ["de": "App bewerten", "en": "Rate app"],
		.profileSection: ["de": "Profil", "en": "Profile"],
		.accountSection: ["de": "Konto", "en": "Account"],
		.yourName: ["de": "Dein Name", "en": "Your name"],
		.partnerNameLabel: ["de": "Partner-Name", "en": "Partner name"],
		.editNamesInSettings: ["de": "Namen in Einstellungen bearbeiten.", "en": "Edit names in Settings."],
		.savedAlertTitle: ["de": "Gespeichert", "en": "Saved"],
		.savedAlertMessage: ["de": "Deine Änderungen wurden gespeichert.", "en": "Your changes have been saved."],
		.save: ["de": "Speichern", "en": "Save"],

		.connectExplanation: ["de": "Pairing aktivieren, um Distanz, Countdown und Note zu nutzen.", "en": "Enable pairing to use distance, countdown and note."],
		.setCityExplanation: ["de": "Wähle deine und die Stadt deines Partners, um die Distanz zu berechnen.", "en": "Choose your and your partner’s city to calculate the distance."],
		.setDateExplanation: ["de": "Wähle ein Datum, um den Countdown zu starten.", "en": "Pick a date to start the countdown."],
		.tapToWriteExplanation: ["de": "Schreib eine Nachricht für deinen Partner.", "en": "Write a note for your partner."],

		.distance: ["de": "Distance", "en": "Distance"],
		.setCity: ["de": "Stadt wählen", "en": "Set city"],
		.connect: ["de": "Verbinden", "en": "Connect"],

		.countdown: ["de": "Countdown", "en": "Countdown"],
		.setDate: ["de": "Datum setzen", "en": "Set date"],

		.note: ["de": "Note", "en": "Note"],
		.tapToWrite: ["de": "Tippen zum Schreiben", "en": "Tap to write"],

		.home: ["de": "Home", "en": "Home"],
		.appTitle: ["de": "CoupleWidgets", "en": "CoupleWidgets"],
		.yourWidgets: ["de": "Deine Widgets", "en": "Your Widgets"],
		.pairing: ["de": "Pairing", "en": "Pairing"],
		.cities: ["de": "Cities", "en": "Cities"],

		.back: ["de": "Zurück", "en": "Back"],

		.pairingStatusSection: ["de": "Status", "en": "Status"],
		.pairingActionsSection: ["de": "Aktionen", "en": "Actions"],
		.pairingRedeemSection: ["de": "Code einlösen", "en": "Redeem code"],
		.pairingRedeemButton: ["de": "Code einlösen", "en": "Redeem code"],
		.pairingRedeemFooter: ["de": "Einladungscode deines Partners eingeben.", "en": "Enter your partner’s invite code."],
		.pairingRedeemPlaceholder: ["de": "XXXX-XXXX", "en": "XXXX-XXXX"],
		.pairingRedeemSuccessTitle: ["de": "Verbunden", "en": "Connected"],
		.pairingRedeemSuccessMessage: ["de": "Du bist jetzt mit deinem Partner verbunden.", "en": "You are now connected with your partner."],
		.pairingRedeemEmptyCode: ["de": "Bitte Code eingeben.", "en": "Please enter the code."],
		.pairingSignInRequired: ["de": "Bitte melde dich mit deinem Apple‑Konto an, um dich zu verbinden oder einen Code zu erstellen.", "en": "Please sign in with your Apple account to connect or create a code."],
		.pairingCodeAlreadyUsedTitle: ["de": "Code bereits vergeben", "en": "Code already used"],
		.pairingCodeAlreadyUsedMessage: ["de": "Dieser Einladungscode ist bereits mit einem anderen Apple‑Konto verbunden. Jeder Code kann nur von einem Partner genutzt werden.", "en": "This invite code is already linked to another Apple account. Each code can only be used by one partner."],
		.signInWithApple: ["de": "Mit Apple anmelden", "en": "Sign in with Apple"],
		.signOut: ["de": "Abmelden", "en": "Sign out"],

		.distanceDescription: ["de": "Distanz zu deinem Partner", "en": "Distance to your partner"],
		.countdownDescription: ["de": "Tage bis zum Event", "en": "Days until the event"],
		.noteDescription: ["de": "Notizen für euch zwei", "en": "Notes for the two of you"],
		.widgetResetTitle: ["de": "Zurücksetzen?", "en": "Reset?"],
		.widgetResetMessage: ["de": "Alle Daten dieses Widgets werden gelöscht.", "en": "All data for this widget will be cleared."],
		.reset: ["de": "Zurücksetzen", "en": "Reset"],
		.cancel: ["de": "Abbrechen", "en": "Cancel"],
		.edit: ["de": "Bearbeiten", "en": "Edit"],
		.recommended: ["de": "empfohlen", "en": "recommended"],

		.useLocation: ["de": "Standort verwenden", "en": "Use location"],
		.locationDenied: ["de": "Standortzugriff wurde verweigert. Bitte in den Einstellungen erlauben.", "en": "Location access was denied. Please allow in Settings."],
		.locationUnavailable: ["de": "Standort konnte nicht ermittelt werden.", "en": "Location could not be determined."],
		.locationSet: ["de": "Meine Stadt wurde aus dem Standort gesetzt.", "en": "Your city was set from your location."],
		.locationAlertTitle: ["de": "Standort", "en": "Location"],

		.pairingSignInSection: ["de": "Anmeldung", "en": "Sign in"],
		.pairingAppleAccount: ["de": "Apple-Konto", "en": "Apple account"],
		.pairingSignedIn: ["de": "Angemeldet", "en": "Signed in"],
		.pairingPaired: ["de": "Verbunden", "en": "Paired"],
		.pairingRole: ["de": "Rolle", "en": "Role"],
		.pairingYes: ["de": "Ja", "en": "Yes"],
		.pairingNo: ["de": "Nein", "en": "No"],
		.pairingInviteCode: ["de": "Einladungscode", "en": "Invite code"],
		.pairingRegenerateCode: ["de": "Code erzeugen / erneuern", "en": "Generate / regenerate code"],
		.pairingUnlink: ["de": "Verbindung trennen", "en": "Unlink"],
		.pairingUnlinkConfirmTitle: ["de": "Verbindung trennen?", "en": "Unlink?"],
		.pairingUnlinkConfirmMessage: ["de": "Die Verbindung wird nur auf diesem Gerät getrennt. Du kannst dich später mit einem neuen Code wieder verbinden.", "en": "The connection will only be removed on this device. You can connect again later with a new code."],
		.pairingSyncFailedTitle: ["de": "Verbindung fehlgeschlagen", "en": "Connection failed"],
		.pairingSyncFailedMessage: ["de": "Die Verbindung konnte nicht hergestellt werden. Bitte prüfe deine Internetverbindung und versuche es erneut.", "en": "The connection could not be established. Please check your internet connection and try again."],
		.pairingNavTitle: ["de": "Pairing", "en": "Pairing"],
		.pairingRoleOwner: ["de": "Ersteller", "en": "Owner"],
		.pairingRolePartner: ["de": "Partner", "en": "Partner"],
		.pairingRoleNone: ["de": "—", "en": "—"],

		.citiesYourLocation: ["de": "Dein Standort", "en": "Your location"],
		.citiesPartnerLocation: ["de": "Partner-Standort", "en": "Partner location"],
		.citiesCountry: ["de": "Land", "en": "Country"],
		.citiesCity: ["de": "Stadt", "en": "City"],
		.citiesSelectCountry: ["de": "Land wählen", "en": "Select country"],
		.citiesSelectCity: ["de": "Stadt wählen", "en": "Select city"],
		.citiesDisplayOptions: ["de": "Anzeige", "en": "Display options"],
		.citiesShowNames: ["de": "Namen anzeigen", "en": "Show names"],
		.citiesNotifications: ["de": "Benachrichtigungen", "en": "Notifications"],
		.citiesAutoUpdateLocation: ["de": "Standort automatisch aktualisieren", "en": "Auto-update location"],
		.citiesStatistics: ["de": "Übersicht", "en": "Statistics"],
		.citiesTimeDifference: ["de": "Zeitdifferenz", "en": "Time difference"],
		.citiesConnection: ["de": "Verbindung", "en": "Connection"],
		.citiesActive: ["de": "Aktiv", "en": "Active"],
		.citiesInactive: ["de": "Inaktiv", "en": "Inactive"],
		.citiesSetBothCities: ["de": "Beide Städte setzen", "en": "Set both cities"],
		.citiesPleaseSetBothCities: ["de": "Bitte wähle beide Städte.", "en": "Please set both cities."],
		.citiesDistanceNavTitle: ["de": "Distanz", "en": "Distance"],

		.homePairingLabel: ["de": "Pairing", "en": "Pairing"],
		.homeLastSync: ["de": "Letzter Sync", "en": "Last sync"],
		.homePaired: ["de": "verbunden", "en": "paired"],
		.homeNotPaired: ["de": "nicht verbunden", "en": "not paired"],
		.homeAppGroupWarning: ["de": "App-Gruppe nicht verfügbar. Widgets werden ggf. nicht aktualisiert.", "en": "App Group not available. Widgets may not update."],
		.homeConnectNow: ["de": "Jetzt mit Partner verbinden", "en": "Connect with partner now"],
		.homeByFor: ["de": "Von %@ für %@", "en": "By %@ for %@"],

		.countdownStatus: ["de": "Status", "en": "Status"],
		.countdownEnable: ["de": "Countdown aktivieren", "en": "Enable countdown"],
		.countdownConfiguration: ["de": "Einstellungen", "en": "Configuration"],
		.countdownTitleLabel: ["de": "Titel", "en": "Title"],
		.countdownDateLabel: ["de": "Datum", "en": "Date"],
		.countdownTimeLabel: ["de": "Uhrzeit", "en": "Time"],
		.countdownDateAndTime: ["de": "Datum & Uhrzeit", "en": "Date & time"],
		.countdownDailyReminder: ["de": "Tägliche Erinnerung", "en": "Daily reminder"],
		.countdownDaysRemaining: ["de": "Tage verbleibend", "en": "Days remaining"],
		.countdownHoursRemaining: ["de": "Stunden verbleibend", "en": "Hours remaining"],
		.countdownEventDate: ["de": "Event-Datum", "en": "Event date"],
		.countdownDisabled: ["de": "Countdown deaktiviert", "en": "Countdown disabled"],
		.countdownDisabledDescription: ["de": "Aktiviere den Countdown oben und setze ein Datum, um die Widget-Vorschau und die Übersicht zu sehen.", "en": "Enable the countdown above and set a date to see your widget preview and statistics."],
		.countdownTitlePlaceholder: ["de": "z. B. Unser Wiedersehen", "en": "e.g. Our Reunion"],
		.countdownDaysRemainingFormat: ["de": "%d Tage", "en": "%d days"],

		.noteConfiguration: ["de": "Einstellungen", "en": "Configuration"],
		.noteAuthor: ["de": "Autor", "en": "Author"],
		.noteShowAuthorInitials: ["de": "Initialen des Autors anzeigen", "en": "Show author initials"],
		.noteShowStreak: ["de": "Streak-Zähler anzeigen", "en": "Show streak counter"],
		.noteNotifyPartner: ["de": "Partner benachrichtigen", "en": "Notify partner"],
		.noteCurrentStreak: ["de": "Aktuelle Serie", "en": "Current streak"],
		.noteLongestStreak: ["de": "Längste Serie", "en": "Longest streak"],
		.noteLastUpdated: ["de": "Zuletzt aktualisiert", "en": "Last updated"],
		.notePlaceholder: ["de": "Schreib eine süße Nachricht an deinen Partner …", "en": "Write a sweet note for your partner..."],
		.noteFromInitials: ["de": "Note von %@", "en": "Note from %@"],
		.noteMe: ["de": "Ich", "en": "Me"],
		.notePartnerLabel: ["de": "Partner", "en": "Partner"],
		.noteNoMessageYet: ["de": "Noch keine Nachricht …", "en": "No message yet..."],
		.notePushNotificationTitle: ["de": "Neue Notiz", "en": "New note"],
		.notePushNotificationBody: ["de": "Von %@", "en": "From %@"],

		.settingsNamePlaceholder: ["de": "Name", "en": "Name"],
		.settingsPartnerPlaceholder: ["de": "Partner", "en": "Partner"],

		.generalConfigure: ["de": "Konfigurieren", "en": "Configure"],
		.widgetPreview: ["de": "Widget-Vorschau", "en": "Widget preview"],
	]
}
