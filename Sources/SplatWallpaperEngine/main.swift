import AppKit
import WebKit

func diagnosticLog(_ message: String) {
    let line = "\(Date()) \(message)\n"
    let url = URL(fileURLWithPath: "/tmp/splat-wallpaper-engine.log")
    if let data = line.data(using: .utf8) {
        if FileManager.default.fileExists(atPath: url.path),
           let handle = try? FileHandle(forWritingTo: url) {
            try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
            try? handle.close()
        } else {
            try? data.write(to: url)
        }
    }
    print(message)
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var wallpaperController: WallpaperWindowController?
    private var interactionMenuItem: NSMenuItem?
    private var rotationMenuItem: NSMenuItem?
    private var aboutWindowController: AboutWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupMenu()
        promptForInitialSceneIfNeeded()
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

        let rotationItem = NSMenuItem(title: "Rotate", action: #selector(toggleRotation), keyEquivalent: "r")
        rotationItem.state = .off
        menu.addItem(rotationItem)
        rotationMenuItem = rotationItem

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "About Splat Wallpaper Engine", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        item.menu = menu
        statusItem = item
    }

    private func showWallpaper() {
        diagnosticLog("[SplatWallpaper] show wallpaper")
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
        installSceneFromPicker()
    }

    @discardableResult
    private func installSceneFromPicker() -> Bool {
        let panel = NSOpenPanel()
        panel.title = "Choose a Gaussian Splat SOG Scene"
        panel.message = "Pick a .sog file to use as your interactive desktop wallpaper."
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.init(filenameExtension: "sog")!]

        guard panel.runModal() == .OK, let selectedURL = panel.url else {
            return false
        }

        do {
            let managedSceneURL = try SceneStore.installScene(from: selectedURL)
            if wallpaperController == nil {
                showWallpaper()
            }
            wallpaperController?.loadScene(managedSceneURL)
            return true
        } catch {
            NSApp.presentError(error)
            return false
        }
    }

    private func promptForInitialSceneIfNeeded() {
        guard !SceneStore.hasInstalledScene else {
            return
        }

        NSApp.activate(ignoringOtherApps: true)
        _ = installSceneFromPicker()
    }

    @objc private func toggleInteractionMode() {
        guard let wallpaperController else {
            return
        }

        let isInteractive = wallpaperController.toggleInteractionMode()
        interactionMenuItem?.state = isInteractive ? .on : .off
    }

    @objc private func toggleRotation() {
        guard let wallpaperController else {
            return
        }

        let isRotating = wallpaperController.toggleRotation()
        rotationMenuItem?.state = isRotating ? .on : .off
    }

    @objc private func showAbout() {
        if aboutWindowController == nil {
            aboutWindowController = AboutWindowController()
        }

        NSApp.activate(ignoringOtherApps: true)
        aboutWindowController?.showWindow(nil)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}

@MainActor
final class AboutWindowController: NSWindowController {
    init() {
        let viewController = AboutViewController()
        let window = NSWindow(contentViewController: viewController)
        window.title = "About Splat Wallpaper Engine"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.setContentSize(NSSize(width: 420, height: 240))
        window.center()
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        nil
    }
}

@MainActor
final class AboutViewController: NSViewController {
    override func loadView() {
        let root = NSView(frame: NSRect(x: 0, y: 0, width: 420, height: 240))
        root.wantsLayer = true
        root.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

        let title = label("Splat Wallpaper Engine", font: .boldSystemFont(ofSize: 20))
        let subtitle = label("Interactive macOS desktop wallpaper for Gaussian splats.", font: .systemFont(ofSize: 13))
        let license = label("Licensed under Apache-2.0. Renderer includes MIT-licensed PlayCanvas/SuperSplat code.", font: .systemFont(ofSize: 12))
        let githubButton = linkButton("GitHub: StoneHub", url: "https://github.com/StoneHub")
        let siteButton = linkButton("monroes.tech", url: "https://monroes.tech")

        let stack = NSStackView(views: [title, subtitle, githubButton, siteButton, license])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        root.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: root.centerYAnchor)
        ])

        view = root
    }

    private func label(_ text: String, font: NSFont) -> NSTextField {
        let field = NSTextField(labelWithString: text)
        field.font = font
        field.lineBreakMode = .byWordWrapping
        field.maximumNumberOfLines = 0
        return field
    }

    private func linkButton(_ title: String, url: String) -> NSButton {
        let button = NSButton(title: title, target: self, action: #selector(openLink(_:)))
        button.isBordered = false
        button.alignment = .left
        button.contentTintColor = .linkColor
        button.identifier = NSUserInterfaceItemIdentifier(url)
        return button
    }

    @objc private func openLink(_ sender: NSButton) {
        guard let value = sender.identifier?.rawValue, let url = URL(string: value) else {
            return
        }

        NSWorkspace.shared.open(url)
    }
}

@MainActor
final class WallpaperWindowController: NSObject {
    private var window: WallpaperWindow?
    private weak var rendererView: RendererView?
    private var isInteractive = false
    private var isRotating = false
    private let passiveLevel = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) + 1)
    private let interactiveLevel = NSWindow.Level.floating

    func show() {
        if let existingWindow = window {
            existingWindow.orderFrontRegardless()
            return
        }

        guard let screen = NSScreen.main else {
            diagnosticLog("[SplatWallpaper] no main screen")
            return
        }

        let contentRect = screen.frame
        let contentBounds = NSRect(origin: .zero, size: contentRect.size)
        diagnosticLog("[SplatWallpaper] screen frame=\(contentRect) contentBounds=\(contentBounds)")
        let wallpaperWindow = WallpaperWindow(
            contentRect: contentRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false,
            screen: screen
        )

        wallpaperWindow.title = "Splat Wallpaper Engine"
        wallpaperWindow.isOpaque = true
        wallpaperWindow.backgroundColor = .black
        wallpaperWindow.acceptsMouseMovedEvents = true
        wallpaperWindow.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        wallpaperWindow.level = passiveLevel
        wallpaperWindow.ignoresMouseEvents = !isInteractive
        wallpaperWindow.hasShadow = false
        let rendererView = RendererView(frame: contentBounds, sceneURL: SceneStore.currentSceneURL)
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
        window?.acceptsMouseMovedEvents = isInteractive
        if isInteractive {
            NSApp.activate(ignoringOtherApps: true)
            window?.level = interactiveLevel
            window?.makeKeyAndOrderFront(nil)
            window?.makeFirstResponder(rendererView)
        } else {
            window?.level = passiveLevel
            window?.orderFrontRegardless()
        }
        return isInteractive
    }

    func loadScene(_ sceneURL: URL) {
        rendererView?.loadRenderer(sceneURL: sceneURL)
        if isRotating {
            rendererView?.setRotationEnabled(true)
        }
    }

    func toggleRotation() -> Bool {
        isRotating.toggle()
        rendererView?.setRotationEnabled(isRotating)
        return isRotating
    }
}

final class WallpaperWindow: NSWindow {
    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }
}

@MainActor
final class RendererView: WKWebView, WKScriptMessageHandler, WKNavigationDelegate {
    init(frame: NSRect, sceneURL: URL?) {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        if let rendererDirectory = try? SceneStore.rendererDirectory {
            config.setURLSchemeHandler(RendererSchemeHandler(rootDirectory: rendererDirectory), forURLScheme: "splatwallpaper")
        }
        let userContentController = WKUserContentController()
        userContentController.addUserScript(WKUserScript(
            source: """
            window.addEventListener('error', event => {
              window.webkit.messageHandlers.splatLog.postMessage('error: ' + event.message + ' at ' + event.filename + ':' + event.lineno + ':' + event.colno);
            });
            window.addEventListener('unhandledrejection', event => {
              window.webkit.messageHandlers.splatLog.postMessage('unhandledrejection: ' + (event.reason && (event.reason.stack || event.reason.message) || event.reason));
            });
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        ))
        config.userContentController = userContentController
        super.init(frame: frame, configuration: config)
        userContentController.add(self, name: "splatLog")
        navigationDelegate = self
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        loadRenderer(sceneURL: sceneURL)
    }

    required init?(coder: NSCoder) {
        nil
    }

    func loadRenderer(sceneURL: URL?) {
        var components = URLComponents()
        components.scheme = "splatwallpaper"
        components.host = "renderer"
        components.path = "/index.html"

        if let sceneURL {
            diagnosticLog("[SplatRenderer] scene url=\(sceneURL.absoluteString)")
            components.queryItems = [
                URLQueryItem(name: "content", value: "./\(sceneURL.lastPathComponent)")
            ]
        }

        guard let url = components.url else {
            diagnosticLog("[SplatRenderer] unable to build renderer url")
            return
        }

        diagnosticLog("[SplatRenderer] renderer url=\(url.absoluteString)")
        load(URLRequest(url: url))
    }

    func setRotationEnabled(_ isEnabled: Bool) {
        let value = isEnabled ? "true" : "false"
        evaluateJavaScript("window.splatWallpaperSetRotate?.(\(value));") { _, error in
            if let error {
                diagnosticLog("[SplatRenderer] rotate bridge failed: \(error.localizedDescription)")
            }
        }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        diagnosticLog("[SplatRenderer] \(message.body)")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        diagnosticLog("[SplatRenderer] navigation finished")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        diagnosticLog("[SplatRenderer] navigation failed: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        diagnosticLog("[SplatRenderer] provisional navigation failed: \(error.localizedDescription)")
    }
}

final class RendererSchemeHandler: NSObject, WKURLSchemeHandler {
    private let rootDirectory: URL

    init(rootDirectory: URL) {
        self.rootDirectory = rootDirectory
    }

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else {
            urlSchemeTask.didFailWithError(SceneStoreError.invalidRendererRequest)
            return
        }

        let relativePath = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let fileURL = rootDirectory.appendingPathComponent(relativePath.isEmpty ? "index.html" : relativePath)
        diagnosticLog("[SplatScheme] \(url.absoluteString) -> \(fileURL.path)")

        do {
            let data = try Data(contentsOf: fileURL)
            let response = URLResponse(
                url: url,
                mimeType: mimeType(for: fileURL.pathExtension),
                expectedContentLength: data.count,
                textEncodingName: nil
            )
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        } catch {
            urlSchemeTask.didFailWithError(error)
        }
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}

    private func mimeType(for pathExtension: String) -> String {
        switch pathExtension.lowercased() {
        case "html": "text/html"
        case "css": "text/css"
        case "js": "text/javascript"
        case "json": "application/json"
        case "sog": "application/octet-stream"
        default: "application/octet-stream"
        }
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

    static var hasInstalledScene: Bool {
        guard let directory = try? rendererDirectory else {
            return false
        }

        return FileManager.default.fileExists(atPath: directory.appendingPathComponent("current-scene.sog").path)
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
    case invalidRendererRequest

    var errorDescription: String? {
        switch self {
        case .missingRenderer:
            "The bundled renderer directory could not be found."
        case .invalidRendererRequest:
            "The renderer requested an invalid resource."
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
