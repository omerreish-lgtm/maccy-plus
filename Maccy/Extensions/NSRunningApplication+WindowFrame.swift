import AppKit.NSRunningApplication
import Carbon

extension NSRunningApplication {
  var windowFrame: NSRect? {
    let options = CGWindowListOption(arrayLiteral: [.excludeDesktopElements, .optionOnScreenOnly])
    let windowListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))
    if let windowInfoList = windowListInfo as NSArray? as? [[String: AnyObject]] {
      for info in windowInfoList {
        if let windowPID = info["kCGWindowOwnerPID"] as? UInt32, windowPID == processIdentifier {
          // Skip helper windows (non-normal layer or tiny strips, e.g. Electron apps'
          // 32pt bars above the screen) so the popup centers on the real window.
          guard info["kCGWindowLayer"] as? Int == 0,
                let width = info["kCGWindowBounds"]?["Width"] as? Double, width >= 100,
                let height = info["kCGWindowBounds"]?["Height"] as? Double, height >= 100 else {
            continue
          }

          if let screen = NSScreen.screens.first,
             let topLeftX = info["kCGWindowBounds"]?["X"] as? Double,
             let topLeftY = info["kCGWindowBounds"]?["Y"] as? Double {
            var rect = NSRect(x: topLeftX, y: topLeftY, width: width, height: height)
            // Convert CGWindowBounds to NSScreen coordinates
            // http://www.krizka.net/2010/04/20/converting-between-kcgwindowbounds-and-nswindowframe
            rect.origin.y = screen.frame.size.height - rect.origin.y - rect.size.height
            guard NSScreen.screens.contains(where: { $0.frame.intersects(rect) }) else {
              continue
            }
            return rect
          }
        }
      }
    }

    return nil
  }
}
