//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import UIKit

class STTextLocationRange: UITextRange {
    let textRange: NSTextRange

    init(textRange: NSTextRange) {
        self.textRange = textRange
    }

    override var debugDescription: String {
        textRange.description
    }

    override var start: UITextPosition {
        textRange.location.uiTextPosition
    }

    override var end: UITextPosition {
        textRange.endLocation.uiTextPosition
    }

    override var isEmpty: Bool {
        textRange.isEmpty
    }
}

extension NSTextRange {
    var uiTextRange: STTextLocationRange {
        STTextLocationRange(textRange: self)
    }
}

extension UITextRange {
    /// The backing `NSTextRange`, or `nil` when UIKit supplies a range the library did not create.
    ///
    /// UIKit does not guarantee every `UITextRange` came from us. `UITextInteraction`, for example,
    /// passes a private UIKit range class when a user taps a misspelled word with autocorrection on.
    /// Callers must treat a `nil` result as "do nothing" and use their existing empty fallback.
    var nsTextRange: NSTextRange? {
        (self as? STTextLocationRange)?.textRange
    }
}
