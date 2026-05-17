import SwiftUI

struct ListingPhotoGallery: View {
    let sources: [ListingImageSource]
    var height: CGFloat = 260

    @State private var selectedIndex = 0

    init(listing: Listing, height: CGFloat = 260) {
        sources = listing.imageSources
        self.height = height
    }

    init(imageURLs: [URL]) {
        sources = imageURLs.map { .remote($0) }
    }

    var body: some View {
        Group {
            if sources.isEmpty {
                ListingImageView(source: nil)
            } else {
                gallery
            }
        }
        .frame(height: height)
        .clipped()
    }

    private var gallery: some View {
        ZStack {
            ListingImageView(source: sources[selectedIndex])
                .id(selectedIndex)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: selectedIndex)

            if sources.count > 1 {
                HStack {
                    galleryArrow(direction: .previous) {
                        selectPrevious()
                    }
                    Spacer()
                    galleryArrow(direction: .next) {
                        selectNext()
                    }
                }
                .padding(.horizontal, 8)

                VStack {
                    Spacer()
                    HStack(spacing: 6) {
                        ForEach(sources.indices, id: \.self) { index in
                            Circle()
                                .fill(index == selectedIndex ? Color.white : Color.white.opacity(0.45))
                                .frame(width: index == selectedIndex ? 8 : 6, height: index == selectedIndex ? 8 : 6)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.35), in: Capsule())
                    .padding(.bottom, 10)
                }

                VStack {
                    HStack {
                        Spacer()
                        Text("\(selectedIndex + 1) / \(sources.count)")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.black.opacity(0.45), in: Capsule())
                    }
                    Spacer()
                }
                .padding(10)
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 24)
                .onEnded { value in
                    if value.translation.width < -40 {
                        selectNext()
                    } else if value.translation.width > 40 {
                        selectPrevious()
                    }
                }
        )
    }

    private enum ArrowDirection {
        case previous
        case next
    }

    private func galleryArrow(direction: ArrowDirection, action: @escaping () -> Void) -> some View {
        let isPrevious = direction == .previous
        let isDisabled = isPrevious ? selectedIndex == 0 : selectedIndex >= sources.count - 1

        return Button(action: action) {
            Image(systemName: isPrevious ? "chevron.left" : "chevron.right")
                .font(.title3.bold())
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(.black.opacity(0.45), in: Circle())
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.35 : 1)
        .accessibilityLabel(isPrevious ? "Previous photo" : "Next photo")
    }

    private func selectPrevious() {
        guard selectedIndex > 0 else { return }
        Haptics.selection()
        selectedIndex -= 1
    }

    private func selectNext() {
        guard selectedIndex < sources.count - 1 else { return }
        Haptics.selection()
        selectedIndex += 1
    }
}
