#if os(iOS) || targetEnvironment(macCatalyst)
    import XCTest
    @testable import STTextViewUIKit

    class STTextViewDelegateTests: XCTestCase {

        func testInitialState() {
            let textView = STTextView()
            // A newly created STTextView has a zero-length selection (caret) at the document start
            XCTAssertNotNil(textView.selectedTextRange)
            XCTAssertTrue(textView.selectedTextRange?.isEmpty == true)
        }

        func testTextDelegate1() {
            let textView = STTextView()
            let willChangeTextExpecation = expectation(description: "willChangeText")
            let didChangeSelectionExpecation = expectation(description: "didChangeSelection")
            didChangeSelectionExpecation.expectedFulfillmentCount = 3
            let didChangeTextExpecation = expectation(description: "didChangeText")

            let textViewDelegate = TextViewDelegate(
                willChangeText: { _ in
                    willChangeTextExpecation.fulfill()
                }, didChangeText: { _ in
                    didChangeTextExpecation.fulfill()
                }, didChangeSelection: { _ in
                    didChangeSelectionExpecation.fulfill()
                }
            )

            textView.textDelegate = textViewDelegate
            textView.text = "0123456789"

            waitForExpectations(timeout: 1)
        }

        // UIKit can hand back a UITextRange the library did not create (for example, UITextInteraction
        // passes a private range class when a user taps a misspelled word with autocorrection on).
        // Each of these entry points must fall back gracefully instead of trapping.
        func testForeignTextRangeFallsBackGracefully() {
            let textView = STTextView()
            textView.text = "0123456789"
            let foreign = ForeignTextRange()

            XCTAssertNil(textView.text(in: foreign))
            XCTAssertEqual(textView.firstRect(for: foreign), .zero)
            XCTAssertTrue(textView.selectionRects(for: foreign).isEmpty)

            // No-ops that must not crash.
            textView.replace(foreign, withText: "x")
            textView.setBaseWritingDirection(.leftToRight, for: foreign)
            XCTAssertEqual(textView.text, "0123456789")

            // A foreign range leaves the existing selection untouched.
            let selectionBefore = textView.selectedTextRange
            textView.selectedTextRange = foreign
            XCTAssertEqual(textView.selectedTextRange?.isEmpty, selectionBefore?.isEmpty)
        }

    }

    /// A `UITextRange` subclass that is not the library's own `STTextLocationRange`, standing in for the
    /// private range classes UIKit passes back in some interactions.
    private final class ForeignTextRange: UITextRange {
        override var start: UITextPosition { UITextPosition() }
        override var end: UITextPosition { UITextPosition() }
        override var isEmpty: Bool { true }
    }


    private class TextViewDelegate: STTextViewDelegate {
        var willChangeText: (Notification) -> Void
        var didChangeText: (Notification) -> Void
        var didChangeSelection: (Notification) -> Void
        var shouldChangeTextIn: (_ affectedCharRange: NSTextRange, _ replacementString: String?) -> Bool
        var willChangeTextIn: (_ affectedCharRange: NSTextRange, _ replacementString: String) -> Void
        var didChangeTextIn: (_ affectedCharRange: NSTextRange, _ replacementString: String) -> Void

        init(
            willChangeText: @escaping (Notification) -> Void = { _ in },
            didChangeText: @escaping (Notification) -> Void = { _ in },
            didChangeSelection: @escaping (Notification) -> Void = { _ in },
            shouldChangeTextIn: @escaping (_ affectedCharRange: NSTextRange, _ replacementString: String?) -> Bool = { _, _ in true },
            willChangeTextIn: @escaping (_ affectedCharRange: NSTextRange, _ replacementString: String) -> Void = { _, _ in },
            didChangeTextIn: @escaping (_ affectedCharRange: NSTextRange, _ replacementString: String) -> Void = { _, _ in }
        ) {
            self.willChangeText = willChangeText
            self.didChangeText = didChangeText
            self.didChangeSelection = didChangeSelection
            self.shouldChangeTextIn = shouldChangeTextIn
            self.willChangeTextIn = willChangeTextIn
            self.didChangeTextIn = didChangeTextIn
        }

        func textViewWillChangeText(_ notification: Notification) {
            willChangeText(notification)
        }

        func textViewDidChangeText(_ notification: Notification) {
            didChangeText(notification)
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            didChangeSelection(notification)
        }

        func textView(_: STTextView, willChangeTextIn affectedCharRange: NSTextRange, replacementString: String) {
            willChangeTextIn(affectedCharRange, replacementString)
        }

        func textView(_: STTextView, shouldChangeTextIn affectedCharRange: NSTextRange, replacementString: String?) -> Bool {
            shouldChangeTextIn(affectedCharRange, replacementString)
        }

        func textView(_: STTextView, didChangeTextIn affectedCharRange: NSTextRange, replacementString: String) {
            didChangeTextIn(affectedCharRange, replacementString)
        }
    }

#endif
