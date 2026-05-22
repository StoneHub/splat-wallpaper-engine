import AppKit
import WebKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var wallpaperController: WallpaperWindowController?
    private var interactionMenuItem: NSMenuItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupMenu()
        showWallpaper()
    }

    private func setupMenu() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "Splat"

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open SOG Scene...", action: #selector(openScene), keyEquivalent: "o"))
        menu.addItem(NSMenuItem(title: "Show Wallpaper", action: #selector(showWallpaperAction), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Hide Wallpaper", action: #selector(hideWallpaperAction), keyEquivalent: ""))
        menu.addItem(.separator())

        let interactionItem = NSMenuItem(title: "Interaction Mode", action: #selector(toggleInteractionMode), keyEquivalent: "i")
        interactionItem.state = .off
        menu.addItem(interactionItem)
        interactionMenuItem = interactionItem

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

    @objc private func openScene() {
        let panel = NSOpenPanel()
        panel.title = "Choose a Gaussian Splat SOG Scene"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.init(filenameExtension: "sog")!]

        guard panel.runModal() == .OK, let selectedURL = panel.url else {
            return
        }

        do {
            let managedSceneURL = try SceneStore.installScene(from: selectedURL)
            if wallpaperController == nil {
                showWallpaper()
            }
            wallpaperController?.loadScene(managedSceneURL)
        } catch {
            NSApp.presentError(error)
        }
    }

    @objc private func toggleInteractionMode() {
        guard let wallpaperController else {
            return
        }

        let isInteractive = wallpaperController.toggleInteractionMode()
        interactionMenuItem?.state = isInteractive ? .on : .off
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}

@MainActor
final class WallpaperWindowController: NSObject {
    private var window: NSWindow?
    private weak var rendererView: RendererView?
    private var isInteractive = false

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
        wallpaperWindow.ignoresMouseEvents = !isInteractive
        wallpaperWindow.hasShadow = false
        let rendererView = RendererView(frame: contentRect, sceneURL: SceneStore.currentSceneURL)
        wallpaperWindow.contentView = rendererView
        wallpaperWindow.orderFrontRegardless()

        self.rendererView = rendererView
        window = wallpaperWindow
    }

    func hide() {
        window?.orderOut(nil)
    }

    func toggleInteractionMode() -> Bool {
        isInteractive.toggle()
        window?.ignoresMouseEvents = !isInteractive
        return isInteractive
    }

    func loadScene(_ sceneURL: URL) {
        rendererView?.loadRenderer(sceneURL: sceneURL)
    }
}

@MainActor
final class RendererView: WKWebView {
    init(frame: NSRect, sceneURL: URL?) {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        super.init(frame: frame, configuration: config)
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        loadRenderer(sceneURL: sceneURL)
    }

    required init?(coder: NSCoder) {
        nil
    }

    func loadRenderer(sceneURL: URL?) {
        guard var components = Bundle.module.url(forResource: "index", withExtension: "html", subdirectory: "Renderer")
            .flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false) }) else {
            loadHTMLString("<html><body style='background:#050505;color:white'>Renderer missing</body></html>", baseURL: nil)
            return
        }

        if let sceneURL {
            components.queryItems = [
                URLQueryItem(name: "content", value: sceneURL.absoluteString)
            ]
        }

        guard let url = components.url else {
            return
        }

        loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }
}

enum SceneStore {
    static var rendererDirectory: URL {
        get throws {
            guard let rendererURL = Bundle.module.url(forResource: "index", withExtension: "html", subdirectory: "Renderer") else {
                throw SceneStoreError.missingRenderer
            }
            return rendererURL.deletingLastPathComponent()
        }
    }

    static var currentSceneURL: URL? {
        guard let directory = try? rendererDirectory else {
            return nil
        }

        let selectedSceneURL = directory.appendingPathComponent("current-scene.sog")
        if FileManager.default.fileExists(atPath: selectedSceneURL.path) {
            return selectedSceneURL
        }

        return directory.appendingPathComponent("scene.sog")
    }

    static func installScene(from sourceURL: URL) throws -> URL {
        let destinationURL = try rendererDirectory.appendingPathComponent("current-scene.sog")
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        return destinationURL
    }
}

enum SceneStoreError: LocalizedError {
    case missingRenderer

    var errorDescription: String? {
        "The bundled renderer directory could not be found."
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
