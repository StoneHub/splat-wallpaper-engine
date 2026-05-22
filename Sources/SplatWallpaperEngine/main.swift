import AppKit
import WebKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var wallpaperController: WallpaperWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupMenu()
        showWallpaper()
    }

    private func setupMenu() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "Splat"

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show Wallpaper", action: #selector(showWallpaperAction), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Hide Wallpaper", action: #selector(hideWallpaperAction), keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        item.menu = menu
        statusItem = item
    }

    private func showWallpaper() {
        let controller = WallpaperWindowController()
        controller.show()
        wallpaperController = controller
    }

    @objc private func showWallpaperAction() {
        if wallpaperController == nil {
            showWallpaper()
        } else {
            wallpaperController?.show()
        }
    }

    @objc private func hideWallpaperAction() {
        wallpaperController?.hide()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}

@MainActor
final class WallpaperWindowController: NSObject {
    private var window: NSWindow?

    func show() {
        if let existingWindow = window {
            existingWindow.orderFrontRegardless()
            return
        }

        guard let screen = NSScreen.main else {
            return
        }

        let contentRect = screen.frame
        let wallpaperWindow = NSWindow(
            contentRect: contentRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false,
            screen: screen
        )

        wallpaperWindow.title = "Splat Wallpaper Engine"
        wallpaperWindow.isOpaque = true
        wallpaperWindow.backgroundColor = .black
        wallpaperWindow.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        wallpaperWindow.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) + 1)
        wallpaperWindow.ignoresMouseEvents = true
        wallpaperWindow.hasShadow = false
        wallpaperWindow.contentView = RendererView(frame: contentRect, loadsBundledRenderer: true)
        wallpaperWindow.orderFrontRegardless()

        window = wallpaperWindow
    }

    func hide() {
        window?.orderOut(nil)
    }
}

@MainActor
final class RendererView: WKWebView {
    init(frame: NSRect, loadsBundledRenderer: Bool) {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        super.init(frame: frame, configuration: config)
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        if loadsBundledRenderer {
            loadRenderer()
        }
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func loadRenderer() {
        guard let url = Bundle.module.url(forResource: "index", withExtension: "html", subdirectory: "Renderer") else {
            loadHTMLString("<html><body style='background:#050505;color:white'>Renderer missing</body></html>", baseURL: nil)
            return
        }

        loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
