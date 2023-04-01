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

    let controller = self.contentViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "target-mate", binaryMessenger: controller.engine.binaryMessenger)
    channel.setMethodCallHandler(handleMessage)

    super.awakeFromNib()
  }

  private func handleMessage(call: FlutterMethodCall, result: FlutterResult) {
    if call.method == "setAppIcon" {
      let uintInt8List =  call.arguments as! FlutterStandardTypedData
      let byte = [UInt8](uintInt8List.data)
      let imageView = NSImageView()
      imageView.image = NSImage(data: Data(byte))
      NSApp.dockTile.contentView = imageView
      NSApp.dockTile.display()
    }
  }

}
