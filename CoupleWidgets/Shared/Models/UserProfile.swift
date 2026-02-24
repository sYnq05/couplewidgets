import Foundation

struct UserProfile: Equatable {
	var name: String
	var initials: String
	var city: CityPreset?

	init(name: String, initials: String, city: CityPreset?) {
		self.name = name
		self.initials = initials
		self.city = city
	}
}

