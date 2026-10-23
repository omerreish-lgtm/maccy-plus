import XCTest
@testable import Maccy

@MainActor
class PasteAllPlannerTests: XCTestCase {
  // Strings stand for text items; nil stands for an image.
  private func plan(_ items: [String?]) -> [String] {
    let indexed = Array(items.enumerated())
    return PasteAllPlanner.chunks(for: indexed, text: { $0.element }).map { chunk in
      switch chunk {
      case .text(let string):
        return string
      case .item(let item):
        return "<image \(item.offset)>"
      }
    }
  }

  func testJoinsTextsWithNewlines() {
    XCTAssertEqual(
      plan(["https://a.com", "https://b.com", "https://c.com"]),
      ["https://a.com\nhttps://b.com\nhttps://c.com"]
    )
  }

  func testKeepsImagesSeparateAndInOrder() {
    XCTAssertEqual(
      plan(["https://a.com", nil, "https://b.com", "note"]),
      ["https://a.com", "<image 1>", "https://b.com\nnote"]
    )
  }

  func testConsecutiveImages() {
    XCTAssertEqual(plan([nil, nil]), ["<image 0>", "<image 1>"])
  }

  func testTrimsSurroundingNewlinesAndSkipsEmptyTexts() {
    XCTAssertEqual(plan(["first\n", "\n", "\nsecond"]), ["first\nsecond"])
  }

  func testEmptySelection() {
    XCTAssertEqual(plan([]), [])
  }
}
