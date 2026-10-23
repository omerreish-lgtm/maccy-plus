import Defaults
import Foundation

// What happens when several items are selected and Enter is pressed.
enum MultiPasteMode: String, CaseIterable, Identifiable, CustomStringConvertible, Defaults.Serializable {
  // Paste all selected items at once: texts joined by newlines, images one after another.
  case together
  // Original Maccy paste stack: every ⌘V pastes the next selected item.
  case oneByOne

  var id: Self { self }

  var description: String {
    switch self {
    case .together:
      return "All at once"
    case .oneByOne:
      return "One by one (⌘V each)"
    }
  }
}

enum PasteAllChunk<Element> {
  case text(String)
  case item(Element)
}

// Splits a multi-selection into the pastes needed to insert it in one go.
// Consecutive text items are merged into a single paste (one item per line),
// so in Notion every line becomes its own block and links stay clickable.
// Anything that is not plain text (images, files) is pasted on its own,
// because one paste can't carry both an image and text in a fixed order.
enum PasteAllPlanner {
  static func chunks<Element>(
    for items: [Element],
    text: (Element) -> String?
  ) -> [PasteAllChunk<Element>] {
    var chunks: [PasteAllChunk<Element>] = []
    var lines: [String] = []

    func flushLines() {
      guard !lines.isEmpty else { return }
      chunks.append(.text(lines.joined(separator: "\n")))
      lines = []
    }

    for item in items {
      if let string = text(item) {
        let trimmed = string.trimmingCharacters(in: .newlines)
        if !trimmed.isEmpty {
          lines.append(trimmed)
        }
      } else {
        flushLines()
        chunks.append(.item(item))
      }
    }
    flushLines()

    return chunks
  }
}
