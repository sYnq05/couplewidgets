import SwiftUI

// MARK: - IOSSection

struct IOSSection<Content: View>: View {
	let title: String
	@ViewBuilder let content: () -> Content

	init(title: String, @ViewBuilder content: @escaping () -> Content) {
		self.title = title
		self.content = content
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text(title)
				.font(.footnote)
				.fontWeight(.medium)
				.foregroundStyle(.secondary)
				.textCase(.uppercase)
			content()
				.padding(16)
				.frame(maxWidth: .infinity, alignment: .leading)
				.background(
					RoundedRectangle(cornerRadius: 12, style: .continuous)
						.fill(Color(.systemBackground))
				)
				.shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
				.overlay(
					RoundedRectangle(cornerRadius: 12, style: .continuous)
						.stroke(Color(.systemGray5).opacity(0.5), lineWidth: 0.5)
				)
		}
	}
}

// MARK: - IOSSelectRow

struct IOSSelectRow: View {
	let label: String
	@Binding var selection: String
	let options: [String]
	var placeholder: String = "Select"

	var body: some View {
		Menu {
			ForEach(options, id: \.self) { option in
				Button(option) { selection = option }
			}
		} label: {
			HStack {
				Text(label)
					.foregroundStyle(.primary)
				Spacer()
				Text(selection.isEmpty ? placeholder : selection)
					.foregroundStyle(selection.isEmpty ? .secondary : .primary)
				Image(systemName: "chevron.right")
					.font(.caption)
					.foregroundStyle(.tertiary)
			}
			.frame(height: 44)
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
	}
}

// MARK: - IOSToggleRow

struct IOSToggleRow: View {
	let label: String
	@Binding var isOn: Bool

	var body: some View {
		HStack {
			Text(label)
				.foregroundStyle(.primary)
			Spacer()
			Toggle("", isOn: $isOn)
				.labelsHidden()
				.tint(.accentColor)
		}
		.frame(height: 44)
	}
}

// MARK: - IOSInputRow

struct IOSInputRow: View {
	let label: String
	@Binding var text: String
	var placeholder: String = ""

	var body: some View {
		HStack(alignment: .center) {
			Text(label)
				.foregroundStyle(.primary)
			TextField(placeholder, text: $text)
				.multilineTextAlignment(.trailing)
				.foregroundStyle(.primary)
		}
		.frame(height: 44)
	}
}

// MARK: - IOSTextAreaRow

struct IOSTextAreaRow: View {
	@Binding var text: String
	var placeholder: String = ""
	var maxLength: Int = 100

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			ZStack(alignment: .topLeading) {
				if text.isEmpty {
					Text(placeholder)
						.font(.system(size: 17))
						.foregroundStyle(Color(.placeholderText))
						.padding(.horizontal, 5)
						.padding(.vertical, 8)
				}
				TextEditor(text: $text)
					.font(.system(size: 17))
					.scrollContentBackground(.hidden)
					.padding(.horizontal, 2)
					.padding(.vertical, 4)
					.onChange(of: text) { _, newValue in
						if newValue.count > maxLength {
							text = String(newValue.prefix(maxLength))
						}
					}
			}
			.frame(minHeight: 120)
			HStack {
				Text("\(text.count)/\(maxLength)")
					.font(.subheadline)
					.foregroundStyle(.secondary)
				Spacer()
			}
		}
	}
}

// MARK: - IOSDatePickerRow (opens sheet: calendar or time, dismisses after selection)

struct IOSDatePickerRow: View {
	let label: String
	@Binding var selection: Date
	var displayedComponents: DatePickerComponents

	@State private var showSheet = false

	private var formattedValue: String {
		let f = DateFormatter()
		if displayedComponents == .date {
			f.dateStyle = .short
			f.timeStyle = .none
		} else {
			f.dateStyle = .none
			f.timeStyle = .short
		}
		return f.string(from: selection)
	}

	var body: some View {
		Button {
			showSheet = true
		} label: {
			HStack {
				Text(label)
					.foregroundStyle(.primary)
				Spacer()
				Text(formattedValue)
					.foregroundStyle(.blue)
				Image(systemName: "chevron.right")
					.font(.caption)
					.foregroundStyle(.tertiary)
			}
			.frame(height: 44)
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
		.sheet(isPresented: $showSheet) {
			NavigationStack {
				if displayedComponents == .date {
					DatePicker(label, selection: $selection, displayedComponents: .date)
						.datePickerStyle(.graphical)
						.onChange(of: selection) { _, _ in
							showSheet = false
						}
				} else {
					DatePicker(label, selection: $selection, displayedComponents: .hourAndMinute)
						.onChange(of: selection) { _, _ in
							showSheet = false
						}
				}
			}
			.presentationDetents([.medium, .large])
		}
	}
}

// MARK: - IOSEmptyState

struct IOSEmptyState: View {
	let icon: String
	let title: String
	let description: String

	var body: some View {
		VStack(spacing: 12) {
			Image(systemName: icon)
				.font(.system(size: 48))
				.foregroundStyle(.secondary)
			Text(title)
				.font(.headline)
				.foregroundStyle(.primary)
			Text(description)
				.font(.subheadline)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.center)
		}
		.frame(maxWidth: .infinity)
		.padding(32)
	}
}

// MARK: - IOSStatCard

struct IOSStatCard: View {
	let icon: String
	let iconColor: Color
	let label: String
	let value: String
	let valueColor: Color

	var body: some View {
		HStack(spacing: 12) {
			ZStack {
				Circle()
					.fill(iconColor)
					.frame(width: 36, height: 36)
				Image(systemName: icon)
					.font(.system(size: 16, weight: .medium))
					.foregroundStyle(.primary)
			}
			Text(label)
				.font(.body)
				.foregroundStyle(.secondary)
			Spacer(minLength: 0)
			Text(value)
				.font(.body.weight(.semibold))
				.foregroundStyle(valueColor)
		}
		.padding(.vertical, 10)
	}
}

// MARK: - IOSWidgetPreview

struct IOSWidgetPreview<Content: View>: View {
	@EnvironmentObject private var languageManager: LanguageManager
	@ViewBuilder let content: () -> Content

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(L10n.tr(.widgetPreview, language: languageManager.resolvedCode))
				.font(.footnote)
				.fontWeight(.medium)
				.foregroundStyle(.secondary)
				.textCase(.uppercase)
			content()
				.clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
				.shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
		}
	}
}
