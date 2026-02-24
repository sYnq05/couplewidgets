import SwiftUI

struct CitiesView: View {
	@EnvironmentObject private var model: AppModel
	@EnvironmentObject private var languageManager: LanguageManager

	@State private var myCountryName: String = ""
	@State private var partnerCountryName: String = ""
	@State private var myCityName: String = ""
	@State private var partnerCityName: String = ""
	@State private var showSavedAlert: Bool = false
	@State private var showSaveError: Bool = false
	@State private var locationLoading: Bool = false
	@State private var locationAlertMessage: String?
	@State private var showLocationAlert: Bool = false
	@State private var showNames: Bool = true
	@State private var autoUpdate: Bool = true
	@State private var showResetAlert: Bool = false
	@EnvironmentObject private var locationService: LocationService

	private var snapshot: CacheSnapshot { model.snapshot }
	private var lang: String { languageManager.resolvedCode }

	private var hasChanges: Bool {
		myCityName != (snapshot.me.cityLabel ?? "")
			|| partnerCityName != (snapshot.partner.cityLabel ?? "")
	}

	/// Country options for "Me": preset countries plus snapshot country if not in presets.
	private var myCountryOptions: [String] {
		let presetNames = CountryPreset.all.map(\.name)
		guard let custom = snapshot.me.country, !custom.isEmpty, !presetNames.contains(custom) else { return presetNames }
		return (presetNames + [custom]).sorted { $0.localizedStandardCompare($1) == .orderedAscending }
	}

	/// Country options for "Partner": preset countries plus snapshot country if not in presets.
	private var partnerCountryOptions: [String] {
		let presetNames = CountryPreset.all.map(\.name)
		guard let custom = snapshot.partner.country, !custom.isEmpty, !presetNames.contains(custom) else { return presetNames }
		return (presetNames + [custom]).sorted { $0.localizedStandardCompare($1) == .orderedAscending }
	}

	private var myCities: [CityPreset] {
		guard !myCountryName.isEmpty else { return [] }
		if let country = CountryPreset.all.first(where: { $0.name == myCountryName }) {
			return country.cities
		}
		// Custom/geocoded country: show snapshot city as single option if it matches.
		if snapshot.me.country == myCountryName, let meCity = snapshot.meCity {
			return [meCity]
		}
		return []
	}

	private var partnerCities: [CityPreset] {
		guard !partnerCountryName.isEmpty else { return [] }
		if let country = CountryPreset.all.first(where: { $0.name == partnerCountryName }) {
			return country.cities
		}
		if snapshot.partner.country == partnerCountryName, let partnerCity = snapshot.partnerCity {
			return [partnerCity]
		}
		return []
	}

	private func requestAndSetMyLocation() {
		locationLoading = true
		locationService.requestAuthorizationIfNeeded()
		Task {
			do {
				let (lat, lon) = try await locationService.requestCurrentLocation()
				let (geocodeCity, geocodeCountry) = await locationService.reverseGeocode(lat: lat, lon: lon)
				let nearest = CityPreset.nearest(toLat: lat, lon: lon)
				let cityLabel = geocodeCity ?? nearest?.name
				let country = geocodeCountry ?? nearest?.country
				await MainActor.run {
					model.setMyLocation(lat: lat, lon: lon, cityLabel: cityLabel, country: country)
					myCityName = cityLabel ?? ""
					myCountryName = country ?? ""
					locationAlertMessage = L10n.tr(.locationSet, language: lang)
					locationLoading = false
					showLocationAlert = true
					locationService.requestAlwaysAuthorizationIfNeeded()
				}
			} catch is LocationError {
				await MainActor.run {
					locationAlertMessage = L10n.tr(.locationDenied, language: lang)
					locationLoading = false
					showLocationAlert = true
				}
			} catch {
				await MainActor.run {
					locationAlertMessage = L10n.tr(.locationUnavailable, language: lang)
					locationLoading = false
					showLocationAlert = true
				}
			}
		}
	}

	/// Distance in km using exact device coordinates when available; otherwise preset cities. Shows distance for any city (preset or geocoded).
	private var distanceKmFormatted: String? {
		let meLat = snapshot.me.lat ?? CityPreset.cityByName(myCityName)?.lat
		let meLon = snapshot.me.lon ?? CityPreset.cityByName(myCityName)?.lon
		let partnerLat = snapshot.partner.lat ?? CityPreset.cityByName(partnerCityName)?.lat
		let partnerLon = snapshot.partner.lon ?? CityPreset.cityByName(partnerCityName)?.lon
		guard let km = DistanceCalculator.haversineKm(lat1: meLat, lon1: meLon, lat2: partnerLat, lon2: partnerLon) else { return nil }
		return NumberFormatter.localizedString(from: NSNumber(value: km), number: .decimal)
	}

	private var timeDiffHoursFormatted: String? {
		let meName = myCityName.isEmpty ? snapshot.me.cityLabel : myCityName
		let partnerName = partnerCityName.isEmpty ? snapshot.partner.cityLabel : partnerCityName
		let meLat = CityPreset.cityByName(myCityName)?.lat ?? snapshot.me.lat
		let meLon = CityPreset.cityByName(myCityName)?.lon ?? snapshot.me.lon
		let partnerLat = CityPreset.cityByName(partnerCityName)?.lat ?? snapshot.partner.lat
		let partnerLon = CityPreset.cityByName(partnerCityName)?.lon ?? snapshot.partner.lon
		guard let diff = TimeZoneDifference.hoursDifference(
			meCityName: meName, meLat: meLat, meLon: meLon,
			partnerCityName: partnerName, partnerLat: partnerLat, partnerLon: partnerLon
		) else { return nil }
		return "\(diff)h"
	}

	private var isConnected: Bool {
		!myCityName.isEmpty && !partnerCityName.isEmpty
	}

	private var distancePreviewData: DistancePreviewData {
		let meInits = snapshot.me.initials
		let partnerInits = snapshot.partner.initials
		let meCityLabel = myCityName.isEmpty ? (snapshot.me.cityLabel ?? "") : myCityName
		let partnerCityLabel = partnerCityName.isEmpty ? (snapshot.partner.cityLabel ?? "") : partnerCityName
		let meLat = snapshot.me.lat ?? CityPreset.cityByName(myCityName)?.lat
		let meLon = snapshot.me.lon ?? CityPreset.cityByName(myCityName)?.lon
		let partnerLat = snapshot.partner.lat ?? CityPreset.cityByName(partnerCityName)?.lat
		let partnerLon = snapshot.partner.lon ?? CityPreset.cityByName(partnerCityName)?.lon
		let mainText: String
		if let km = DistanceCalculator.haversineKm(lat1: meLat, lon1: meLon, lat2: partnerLat, lon2: partnerLon) {
			mainText = "\(km) km"
		} else {
			mainText = L10n.tr(.citiesSetBothCities, language: lang)
		}
		let timeDiff = TimeZoneDifference.hoursDifference(
			meCityName: meCityLabel.isEmpty ? nil : meCityLabel, meLat: meLat, meLon: meLon,
			partnerCityName: partnerCityLabel.isEmpty ? nil : partnerCityLabel, partnerLat: partnerLat, partnerLon: partnerLon
		)
		return DistancePreviewData(
			meInitials: meInits,
			partnerInitials: partnerInits,
			meCityLabel: meCityLabel.isEmpty ? nil : meCityLabel,
			partnerCityLabel: partnerCityLabel.isEmpty ? nil : partnerCityLabel,
			mainText: mainText,
			meCountryCode: myCountryName.isEmpty ? nil : DistancePreviewData.countryCode(for: myCountryName),
			partnerCountryCode: partnerCountryName.isEmpty ? nil : DistancePreviewData.countryCode(for: partnerCountryName),
			timeDifferenceHours: timeDiff
		)
	}

	var body: some View {
		ZStack {
			Color(UIColor.systemGroupedBackground)
				.ignoresSafeArea()
			ScrollView {
				VStack(spacing: 20) {
					IOSSection(title: L10n.tr(.citiesYourLocation, language: lang)) {
						Button {
							requestAndSetMyLocation()
						} label: {
							HStack {
								Text(L10n.tr(.useLocation, language: lang))
									.foregroundColor(.primary)
								Spacer()
								if locationLoading {
									ProgressView()
										.scaleEffect(0.9)
								}
							}
						}
						.disabled(locationLoading)
						IOSSelectRow(
							label: L10n.tr(.citiesCountry, language: lang),
							selection: $myCountryName,
							options: myCountryOptions,
							placeholder: L10n.tr(.citiesSelectCountry, language: lang)
						)
						.onChange(of: myCountryName) { _, newCountry in
							let citiesInCountry = newCountry.isEmpty ? [] : myCities
							if !myCityName.isEmpty, !citiesInCountry.contains(where: { $0.name == myCityName }) {
								myCityName = ""
							}
						}

						IOSSelectRow(
							label: L10n.tr(.citiesCity, language: lang),
							selection: $myCityName,
							options: myCities.map(\.name),
							placeholder: L10n.tr(.citiesSelectCity, language: lang)
						)
					}

					IOSSection(title: L10n.tr(.citiesPartnerLocation, language: lang)) {
						IOSSelectRow(
							label: L10n.tr(.citiesCountry, language: lang),
							selection: $partnerCountryName,
							options: partnerCountryOptions,
							placeholder: L10n.tr(.citiesSelectCountry, language: lang)
						)
						.onChange(of: partnerCountryName) { _, newCountry in
							let citiesInCountry = newCountry.isEmpty ? [] : partnerCities
							if !partnerCityName.isEmpty, !citiesInCountry.contains(where: { $0.name == partnerCityName }) {
								partnerCityName = ""
							}
						}

						IOSSelectRow(
							label: L10n.tr(.citiesCity, language: lang),
							selection: $partnerCityName,
							options: partnerCities.map(\.name),
							placeholder: L10n.tr(.citiesSelectCity, language: lang)
						)
					}

					IOSSection(title: L10n.tr(.citiesDisplayOptions, language: lang)) {
						IOSToggleRow(label: L10n.tr(.citiesShowNames, language: lang), isOn: $showNames)
					}

					IOSSection(title: L10n.tr(.citiesNotifications, language: lang)) {
						IOSToggleRow(label: L10n.tr(.citiesAutoUpdateLocation, language: lang), isOn: $autoUpdate)
					}

					IOSSection(title: L10n.tr(.citiesStatistics, language: lang)) {
						VStack(spacing: 0) {
							IOSStatCard(
								icon: "ruler",
								iconColor: Color.orange.opacity(0.15),
								label: L10n.tr(.distance, language: lang),
								value: distanceKmFormatted != nil ? "\(distanceKmFormatted!) km" : "—",
								valueColor: .orange
							)
							IOSStatCard(
								icon: "globe",
								iconColor: Color.purple.opacity(0.15),
								label: L10n.tr(.citiesTimeDifference, language: lang),
								value: timeDiffHoursFormatted != nil ? "\(timeDiffHoursFormatted!)h" : "—",
								valueColor: .purple
							)
							IOSStatCard(
								icon: "paperplane",
								iconColor: Color.blue.opacity(0.15),
								label: L10n.tr(.citiesConnection, language: lang),
								value: isConnected ? L10n.tr(.citiesActive, language: lang) : L10n.tr(.citiesInactive, language: lang),
								valueColor: .primary
							)
						}
					}

					IOSWidgetPreview {
						DistancePreviewContentView(data: distancePreviewData)
							.background(
								LinearGradient(
									colors: [Color(white: 0.18), Color(white: 0.10)],
									startPoint: .topLeading,
									endPoint: .bottomTrailing
								)
							)
							.frame(height: 160)
					}

					IOSSection(title: L10n.tr(.reset, language: lang)) {
						Button(role: .destructive) {
							showResetAlert = true
						} label: {
							Text(L10n.tr(.reset, language: lang) + " – " + L10n.tr(.distance, language: lang))
								.frame(maxWidth: .infinity, alignment: .leading)
						}
					}
				}
				.padding(.horizontal, 20)
				.padding(.vertical, 16)
				.foregroundStyle(.primary)
			}
			.scrollContentBackground(.hidden)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.navigationTitle(L10n.tr(.citiesDistanceNavTitle, language: lang))
		.navigationBarTitleDisplayMode(.inline)
		.toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button(L10n.tr(.save, language: lang)) {
					handleSave()
				}
				.font(.system(size: 17, weight: .semibold))
				.foregroundStyle(Color.blue)
				.buttonStyle(.plain)
			}
		}
		.alert(L10n.tr(.savedAlertTitle, language: lang), isPresented: $showSavedAlert) {
			Button("OK", role: .cancel) {}
		} message: {
			Text(L10n.tr(.savedAlertMessage, language: lang))
		}
		.alert(L10n.tr(.citiesDistanceNavTitle, language: lang), isPresented: $showSaveError) {
			Button("OK", role: .cancel) {}
		} message: {
			Text(L10n.tr(.citiesPleaseSetBothCities, language: lang))
		}
		.alert(L10n.tr(.locationAlertTitle, language: lang), isPresented: $showLocationAlert) {
			Button("OK", role: .cancel) {}
		} message: {
			Text(locationAlertMessage ?? "")
		}
		.alert(L10n.tr(.widgetResetTitle, language: lang), isPresented: $showResetAlert) {
			Button(L10n.tr(.cancel, language: lang), role: .cancel) {}
			Button(L10n.tr(.reset, language: lang), role: .destructive) {
				model.resetDistance()
			}
		} message: {
			Text(L10n.tr(.widgetResetMessage, language: lang))
		}
		.onAppear {
			myCityName = snapshot.me.cityLabel ?? ""
			partnerCityName = snapshot.partner.cityLabel ?? ""
			myCountryName = snapshot.me.country ?? CityPreset.cityByName(myCityName)?.country ?? ""
			partnerCountryName = snapshot.partner.country ?? CityPreset.cityByName(partnerCityName)?.country ?? ""
		}
	}

	private func handleSave() {
		guard !myCityName.isEmpty, !partnerCityName.isEmpty else {
			showSaveError = true
			return
		}
		model.setMyCity(CityPreset.cityByName(myCityName) ?? snapshot.meCity)
		model.setPartnerCity(CityPreset.cityByName(partnerCityName) ?? snapshot.partnerCity)
		showSavedAlert = true
	}
}
