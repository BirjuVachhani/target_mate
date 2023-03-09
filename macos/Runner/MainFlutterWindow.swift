import Cocoa
import FlutterMacOS
 import bitsdojo_window_macos

class MainFlutterWindow: BitsdojoWindow {
   override func bitsdojo_window_configure() -> UInt {
     return BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP
   }
    
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

      if #available(macOS 10.13, *) {
        // set default tool bar for better spacing.
        self.toolbar = NSToolbar()
        self.toolbar?.displayMode = NSToolbar.DisplayMode.iconOnly
        // self.toolbar?.isVisible = false

        var localStyle = self.styleMask;
        localStyle.insert(.fullSizeContentView)
        self.styleMask = localStyle;
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        self.isOpaque = false
        self.isMovable = true
        self.setIsZoomed(true)

        // Disable full screen button.
        let button = self.standardWindowButton(NSWindow.ButtonType.zoomButton)
        button?.isEnabled = false
      }
    super.awakeFromNib()
  }

}
