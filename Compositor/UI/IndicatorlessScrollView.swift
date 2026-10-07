import AppKit
import SwiftUI

/// The tool rail scrolls when it overflows without showing or reserving space
/// for a macOS scroller, even when the system setting always shows scroll bars.
struct IndicatorlessScrollView<Content: View>: NSViewRepresentable {
    @ViewBuilder let content: () -> Content

    func makeNSView(context: Context) -> IndicatorlessScrollContainer {
        IndicatorlessScrollContainer(host: NSHostingView(rootView: content()))
    }

    func updateNSView(_ view: IndicatorlessScrollContainer, context: Context) {
        guard let host = view.host as? NSHostingView<Content> else { return }
        host.rootView = content()
        host.invalidateIntrinsicContentSize()
        view.updateDocumentSize()
    }
}

/// The scroll view around the rail. Not generic over the content, on purpose: Swift 6.3's optimizer
/// (Xcode 26.6) crashes on the deinit of a generic NSScrollView subclass in Release builds.
final class IndicatorlessScrollContainer: NSScrollView {
    /// An `NSHostingView` of the rail's content; only `IndicatorlessScrollView` knows the content type.
    let host: NSView

    init(host: NSView) {
        self.host = host
        super.init(frame: .zero)
        drawsBackground = false
        borderType = .noBorder
        hasVerticalScroller = false
        hasHorizontalScroller = false
        horizontalScrollElasticity = .none
        documentView = host
        updateDocumentSize()
    }

    required init?(coder: NSCoder) { nil }

    override func layout() {
        super.layout()
        updateDocumentSize()
    }

    func updateDocumentSize() {
        let height = host.fittingSize.height
        let size = NSSize(width: 56, height: height)
        if host.frame.size != size { host.setFrameSize(size) }
        verticalScrollElasticity = height > contentView.bounds.height + 1 ? .allowed : .none
    }
}
