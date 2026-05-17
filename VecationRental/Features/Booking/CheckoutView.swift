import SwiftUI

struct CheckoutView: View {
    let draft: BookingDraft

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var booking: Booking
    @State private var statusMessage: String?
    @State private var isProcessing = false

    private let bookingRepository: BookingRepositoryProtocol

    @MainActor
    init(draft: BookingDraft, bookingRepository: BookingRepositoryProtocol = BookingRepository.shared) {
        self.draft = draft
        self.bookingRepository = bookingRepository
        _booking = State(initialValue: draft.makeBooking())
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Stay") {
                    LabeledContent("Listing", value: draft.listing.title)
                    LabeledContent("Check-in", value: draft.checkIn.formatted(date: .abbreviated, time: .omitted))
                    LabeledContent("Check-out", value: draft.checkOut.formatted(date: .abbreviated, time: .omitted))
                    LabeledContent("Guests", value: "\(draft.guestCount)")
                }

                Section("Price breakdown") {
                    LabeledContent("Subtotal", value: currency(booking.subtotal))
                    LabeledContent("Service fee", value: currency(booking.serviceFee))
                    LabeledContent("Taxes", value: currency(booking.taxes))
                    LabeledContent("Total", value: currency(booking.total))
                        .font(.headline)
                }

                if let statusMessage {
                    Section {
                        Text(statusMessage)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Checkout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    Task { await confirmBooking() }
                } label: {
                    if isProcessing {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Confirm booking · \(currency(booking.total))")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isProcessing)
                .padding()
            }
        }
    }

    private func currency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = booking.currencyCode
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }

    private func confirmBooking() async {
        isProcessing = true
        defer { isProcessing = false }
        AnalyticsService.shared.track(.checkoutStarted)

        do {
            try await bookingRepository.confirmBooking(booking)
            Haptics.success()
            AnalyticsService.shared.track(.checkoutCompleted)
            dismiss()
            appState.selectedTab = .trips
        } catch {
            Haptics.warning()
            AnalyticsService.shared.track(.bookingFailed)
            statusMessage = error.localizedDescription
        }
    }
}
