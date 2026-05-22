import AppKit

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let assets = root.appendingPathComponent("assets", isDirectory: true)
let iconset = assets.appendingPathComponent("AppIcon.iconset", isDirectory: true)
let icns = assets.appendingPathComponent("AppIcon.icns")

try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

let sizes: [(String, CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

func drawIcon(size: CGFloat) throws -> NSBitmapImageRep {
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size),
        pixelsHigh: Int(size),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw NSError(domain: "IconGenerator", code: 1)
    }

    let context = NSGraphicsContext(bitmapImageRep: bitmap)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let radius = size * 0.22
    let background = NSBezierPath(roundedRect: rect.insetBy(dx: size * 0.035, dy: size * 0.035), xRadius: radius, yRadius: radius)
    NSColor(calibratedRed: 0.02, green: 0.025, blue: 0.03, alpha: 1).setFill()
    background.fill()

    NSGraphicsContext.saveGraphicsState()
    background.addClip()
    let glow = NSGradient(colors: [
        NSColor(calibratedRed: 0.11, green: 0.95, blue: 0.54, alpha: 0.86),
        NSColor(calibratedRed: 0.04, green: 0.28, blue: 0.20, alpha: 0.18),
        NSColor.clear
    ])!
    let center = NSPoint(x: size * 0.50, y: size * 0.53)
    glow.draw(fromCenter: center, radius: 0, toCenter: center, radius: size * 0.48, options: [])
    NSGraphicsContext.restoreGraphicsState()

    let desktop = NSBezierPath(roundedRect: NSRect(x: size * 0.18, y: size * 0.20, width: size * 0.64, height: size * 0.50), xRadius: size * 0.055, yRadius: size * 0.055)
    NSColor(calibratedRed: 0.08, green: 0.095, blue: 0.11, alpha: 1).setFill()
    desktop.fill()
    NSColor(calibratedWhite: 1, alpha: 0.16).setStroke()
    desktop.lineWidth = max(1, size * 0.014)
    desktop.stroke()

    let splatColors = [
        NSColor(calibratedRed: 0.20, green: 0.95, blue: 0.46, alpha: 0.95),
        NSColor(calibratedRed: 0.85, green: 0.93, blue: 0.20, alpha: 0.85),
        NSColor(calibratedRed: 0.16, green: 0.68, blue: 0.96, alpha: 0.78),
        NSColor(calibratedRed: 0.98, green: 0.40, blue: 0.25, alpha: 0.72)
    ]

    let points: [(CGFloat, CGFloat, CGFloat, Int)] = [
        (0.35, 0.48, 0.115, 0), (0.45, 0.56, 0.145, 1), (0.55, 0.47, 0.125, 0),
        (0.61, 0.59, 0.085, 2), (0.40, 0.36, 0.095, 3), (0.52, 0.35, 0.115, 1),
        (0.64, 0.39, 0.080, 0), (0.49, 0.68, 0.070, 2), (0.30, 0.58, 0.072, 0)
    ]

    for (x, y, r, colorIndex) in points {
        splatColors[colorIndex].setFill()
        let dot = NSBezierPath(ovalIn: NSRect(
            x: size * x - size * r,
            y: size * y - size * r,
            width: size * r * 2,
            height: size * r * 2
        ))
        dot.fill()
    }

    NSColor(calibratedWhite: 1, alpha: 0.82).setStroke()
    let orbit = NSBezierPath(ovalIn: NSRect(x: size * 0.26, y: size * 0.30, width: size * 0.48, height: size * 0.34))
    orbit.lineWidth = max(1, size * 0.018)
    orbit.stroke()

    NSColor(calibratedRed: 0.74, green: 1.0, blue: 0.88, alpha: 1).setFill()
    NSBezierPath(ovalIn: NSRect(x: size * 0.70, y: size * 0.46, width: size * 0.075, height: size * 0.075)).fill()

    NSGraphicsContext.restoreGraphicsState()
    return bitmap
}

func writePNG(_ bitmap: NSBitmapImageRep, to url: URL) throws {
    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "IconGenerator", code: 2)
    }

    try data.write(to: url)
}

for (name, size) in sizes {
    try writePNG(drawIcon(size: size), to: iconset.appendingPathComponent(name))
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconset.path, "-o", icns.path]
try process.run()
process.waitUntilExit()

if process.terminationStatus != 0 {
    throw NSError(domain: "IconGenerator", code: Int(process.terminationStatus))
}

print(icns.path)
