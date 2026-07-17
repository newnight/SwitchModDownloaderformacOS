import SwiftUI
import AppKit

struct AppIconCanvas: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            backgroundLayer
            circuitLayer
            downloadArrowLayer
            glowLayer
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2237, style: .continuous))
    }

    var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.06, blue: 0.14),
                    Color(red: 0.08, green: 0.12, blue: 0.24),
                    Color(red: 0.02, green: 0.04, blue: 0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.15),
                    Color.clear
                ],
                center: .init(x: 0.45, y: 0.4),
                startRadius: 0,
                endRadius: size * 0.6
            )
        }
    }

    var circuitLayer: some View {
        Canvas { context, canvasSize in
            let cx = canvasSize.width * 0.5
            let cy = canvasSize.height * 0.5
            let unit = canvasSize.width / 1024

            let cyan = Color(red: 0.0, green: 0.85, blue: 1.0)
            let amber = Color(red: 1.0, green: 0.72, blue: 0.2)
            let dimCyan = cyan.opacity(0.3)
            let dimAmber = amber.opacity(0.25)

            var trace1 = Path()
            trace1.move(to: CGPoint(x: cx - 200*unit, y: cy - 60*unit))
            trace1.addLine(to: CGPoint(x: cx - 100*unit, y: cy - 60*unit))
            trace1.addLine(to: CGPoint(x: cx - 80*unit, y: cy - 40*unit))
            trace1.addLine(to: CGPoint(x: cx + 80*unit, y: cy - 40*unit))
            trace1.addLine(to: CGPoint(x: cx + 100*unit, y: cy - 60*unit))
            trace1.addLine(to: CGPoint(x: cx + 200*unit, y: cy - 60*unit))
            context.stroke(trace1, with: .color(dimCyan), lineWidth: 2.5*unit)

            var trace2 = Path()
            trace2.move(to: CGPoint(x: cx - 200*unit, y: cy + 60*unit))
            trace2.addLine(to: CGPoint(x: cx - 100*unit, y: cy + 60*unit))
            trace2.addLine(to: CGPoint(x: cx - 80*unit, y: cy + 40*unit))
            trace2.addLine(to: CGPoint(x: cx + 80*unit, y: cy + 40*unit))
            trace2.addLine(to: CGPoint(x: cx + 100*unit, y: cy + 60*unit))
            trace2.addLine(to: CGPoint(x: cx + 200*unit, y: cy + 60*unit))
            context.stroke(trace2, with: .color(dimCyan), lineWidth: 2.5*unit)

            var trace3 = Path()
            trace3.move(to: CGPoint(x: cx - 160*unit, y: cy - 120*unit))
            trace3.addLine(to: CGPoint(x: cx - 160*unit, y: cy - 60*unit))
            context.stroke(trace3, with: .color(dimAmber), lineWidth: 2*unit)

            var trace4 = Path()
            trace4.move(to: CGPoint(x: cx + 160*unit, y: cy - 120*unit))
            trace4.addLine(to: CGPoint(x: cx + 160*unit, y: cy - 60*unit))
            context.stroke(trace4, with: .color(dimAmber), lineWidth: 2*unit)

            var trace5 = Path()
            trace5.move(to: CGPoint(x: cx - 160*unit, y: cy + 60*unit))
            trace5.addLine(to: CGPoint(x: cx - 160*unit, y: cy + 120*unit))
            context.stroke(trace5, with: .color(dimAmber), lineWidth: 2*unit)

            var trace6 = Path()
            trace6.move(to: CGPoint(x: cx + 160*unit, y: cy + 60*unit))
            trace6.addLine(to: CGPoint(x: cx + 160*unit, y: cy + 120*unit))
            context.stroke(trace6, with: .color(dimAmber), lineWidth: 2*unit)

            let nodePositions: [(CGPoint, CGFloat, Color)] = [
                (CGPoint(x: cx - 200*unit, y: cy - 60*unit), 4*unit, dimCyan),
                (CGPoint(x: cx + 200*unit, y: cy - 60*unit), 4*unit, dimCyan),
                (CGPoint(x: cx - 200*unit, y: cy + 60*unit), 4*unit, dimCyan),
                (CGPoint(x: cx + 200*unit, y: cy + 60*unit), 4*unit, dimCyan),
                (CGPoint(x: cx - 160*unit, y: cy - 120*unit), 3*unit, dimAmber),
                (CGPoint(x: cx + 160*unit, y: cy - 120*unit), 3*unit, dimAmber),
                (CGPoint(x: cx - 160*unit, y: cy + 120*unit), 3*unit, dimAmber),
                (CGPoint(x: cx + 160*unit, y: cy + 120*unit), 3*unit, dimAmber),
            ]
            for (pos, r, color) in nodePositions {
                context.fill(Circle().path(in: CGRect(x: pos.x - r, y: pos.y - r, width: r*2, height: r*2)), with: .color(color))
            }

            for i in 0..<8 {
                let angle = Double(i) * .pi / 4.0 - .pi / 2.0
                let innerR = 180 * unit
                let outerR = 220 * unit
                let x1 = cx + cos(angle) * innerR
                let y1 = cy + sin(angle) * innerR
                let x2 = cx + cos(angle) * outerR
                let y2 = cy + sin(angle) * outerR
                var tick = Path()
                tick.move(to: CGPoint(x: x1, y: y1))
                tick.addLine(to: CGPoint(x: x2, y: y2))
                context.stroke(tick, with: .color(dimCyan.opacity(0.5)), lineWidth: 1.5*unit)
            }
        }
    }

    var downloadArrowLayer: some View {
        let unit = size / 1024
        let cx = size * 0.5
        let cy = size * 0.48

        return ZStack {
            Path { path in
                path.move(to: CGPoint(x: cx, y: cy - 100*unit))
                path.addLine(to: CGPoint(x: cx, y: cy + 50*unit))
            }
            .stroke(
                LinearGradient(
                    colors: [
                        Color(red: 0.0, green: 0.9, blue: 1.0).opacity(0.6),
                        Color(red: 0.0, green: 0.9, blue: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                style: StrokeStyle(lineWidth: 8*unit, lineCap: .round)
            )

            Path { path in
                path.move(to: CGPoint(x: cx - 50*unit, y: cy + 10*unit))
                path.addLine(to: CGPoint(x: cx, y: cy + 60*unit))
                path.addLine(to: CGPoint(x: cx + 50*unit, y: cy + 10*unit))
            }
            .stroke(Color(red: 0.0, green: 0.9, blue: 1.0), style: StrokeStyle(lineWidth: 8*unit, lineCap: .round, lineJoin: .round))

            Path { path in
                path.move(to: CGPoint(x: cx - 120*unit, y: cy + 80*unit))
                path.addLine(to: CGPoint(x: cx + 120*unit, y: cy + 80*unit))
            }
            .stroke(Color(red: 1.0, green: 0.72, blue: 0.2), style: StrokeStyle(lineWidth: 6*unit, lineCap: .round))

            Circle()
                .fill(Color(red: 0.0, green: 0.9, blue: 1.0).opacity(0.25))
                .frame(width: 24*unit, height: 24*unit)
                .offset(x: cx - size*0.5, y: cy - 100*unit - size*0.5)
        }
    }

    var glowLayer: some View {
        RadialGradient(
            colors: [
                Color(red: 0.0, green: 0.85, blue: 1.0).opacity(0.12),
                Color.clear
            ],
            center: .center,
            startRadius: 0,
            endRadius: size * 0.45
        )
        .mask(
            RoundedRectangle(cornerRadius: size * 0.2237, style: .continuous)
        )
    }
}

@MainActor
func renderIcon(size: CGFloat) -> NSImage {
    let view = AppIconCanvas(size: size)
    let renderer = ImageRenderer(content: view)
    renderer.scale = 2.0
    return renderer.nsImage!
}

@main
struct IconMain {
    static func main() async {
        let sizes: [(String, CGFloat)] = [
            ("icon_16x16", 16),
            ("icon_32x32", 32),
            ("icon_64x64", 64),
            ("icon_128x128", 128),
            ("icon_256x256", 256),
            ("icon_512x512", 512),
        ]

        let outputDir = "/Volumes/tke/trce/mods/SwitchModDownloader/AppIcon.appiconset"
        try? FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

        for (name, size) in sizes {
            let image = renderIcon(size: size)
            guard let tiffData = image.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: tiffData),
                  let pngData = bitmap.representation(using: .png, properties: [:]) else {
                continue
            }
            let url = URL(fileURLWithPath: "\(outputDir)/\(name).png")
            try? pngData.write(to: url)
            print("Generated: \(name).png (\(Int(size))x\(Int(size)))")
        }

        var contents = """
        {
          "images" : [
        """
        for (name, size) in sizes {
            let scale = size >= 128 ? "2x" : (size >= 32 ? "2x" : "1x")
            let logicalSize = Int(size) / (scale == "2x" ? 2 : 1)
            let comma = name == sizes.last?.0 ? "" : ","
            contents += """
            
            {
              "filename" : "\(name).png",
              "idiom" : "mac",
              "scale" : "\(scale)",
              "size" : "\(logicalSize)x\(logicalSize)"
            }\(comma)
        """
        }
        contents += """
          ],
          "info" : {
            "author" : "xcode",
            "version" : 1
          }
        }
        """
        try? contents.write(toFile: "\(outputDir)/Contents.json", atomically: true, encoding: .utf8)
        print("Generated: Contents.json")
        print("Icon set complete at: \(outputDir)")
    }
}
