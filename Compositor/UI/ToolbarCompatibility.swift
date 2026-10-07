import SwiftUI

// The editor toolbar is laid out for macOS 26, where `ToolbarSpacer` sets the gaps between glass groups and
// `sharedBackgroundVisibility` lifts the tab strip out of its group. Neither exists on macOS 15, whose toolbar
// has no groups: a spacer there is an ordinary item holding a `Spacer`, and the visibility modifier does nothing.

/// `ToolbarSpacer` on macOS 26; on macOS 15, a toolbar item that only takes up space.
struct CompatibleToolbarSpacer: ToolbarContent {
    enum Sizing { case fixed, flexible }

    private let sizing: Sizing
    private let placement: ToolbarItemPlacement

    init(_ sizing: Sizing = .flexible, placement: ToolbarItemPlacement = .automatic) {
        self.sizing = sizing
        self.placement = placement
    }

    var body: some ToolbarContent {
        if #available(macOS 26, *) {
            ToolbarSpacer(sizing == .fixed ? .fixed : .flexible, placement: placement)
        } else {
            ToolbarItem(placement: placement) {
                if sizing == .fixed { Spacer().frame(width: 8) } else { Spacer() }
            }
        }
    }
}

extension ToolbarContent {
    /// `sharedBackgroundVisibility(_:)` on macOS 26; unchanged on macOS 15, which draws no shared background.
    @ToolbarContentBuilder
    func compatibleSharedBackgroundVisibility(_ visibility: Visibility) -> some ToolbarContent {
        if #available(macOS 26, *) {
            sharedBackgroundVisibility(visibility)
        } else {
            self
        }
    }
}
