import SwiftUI

struct FilterSheetView: View {
    @Binding var filters: SearchFilters
    var onApply: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Price per night") {
                    TextField("Min", value: $filters.minPrice, format: .number)
                        .keyboardType(.decimalPad)
                    TextField("Max", value: $filters.maxPrice, format: .number)
                        .keyboardType(.decimalPad)
                }

                Section("Rooms & guests") {
                    Stepper("Bedrooms: \(filters.minBedrooms ?? 0)+", value: Binding(
                        get: { filters.minBedrooms ?? 0 },
                        set: { filters.minBedrooms = $0 == 0 ? nil : $0 }
                    ), in: 0...8)
                    Stepper("Bathrooms: \(filters.minBathrooms ?? 0)+", value: Binding(
                        get: { filters.minBathrooms ?? 0 },
                        set: { filters.minBathrooms = $0 == 0 ? nil : $0 }
                    ), in: 0...8)
                    Stepper("Guests: \(filters.minGuests ?? 1)+", value: Binding(
                        get: { filters.minGuests ?? 1 },
                        set: { filters.minGuests = $0 <= 1 ? nil : $0 }
                    ), in: 1...16)
                }

                Section("Neighborhood") {
                    TextField("e.g. Mission District", text: Binding(
                        get: { filters.neighborhood ?? "" },
                        set: { filters.neighborhood = $0.isEmpty ? nil : $0 }
                    ))
                }

                Section {
                    Toggle("Available only", isOn: $filters.availableOnly)
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        filters = SearchFilters()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onApply()
                        dismiss()
                    }
                }
            }
        }
    }
}
