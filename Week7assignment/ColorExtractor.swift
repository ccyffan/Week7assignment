import SwiftUI
import UIKit

class ColorExtractor {
    func extractColors(from image: UIImage, count: Int) -> [(color: Color, hex: String, rgb: String)] {
        guard let cgImage = image.cgImage else { return [] }

        let width = 50
        let height = 50
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        let context = CGContext(data: nil,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: width * 4,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo)

        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let pixelData = context?.data else { return [] }
        let data = pixelData.bindMemory(to: UInt8.self, capacity: width * height * 4)

        var colorCounts: [UIColor: Int] = [:]

        for x in 0..<width {
            for y in 0..<height {
                let offset = 4 * (y * width + x)
                let r = data[offset]
                let g = data[offset + 1]
                let b = data[offset + 2]

                let color = UIColor(red: CGFloat(r) / 255.0,
                                    green: CGFloat(g) / 255.0,
                                    blue: CGFloat(b) / 255.0,
                                    alpha: 1.0)
                colorCounts[color, default: 0] += 1
            }
        }

        let sortedColors = colorCounts.sorted { $0.value > $1.value }.prefix(count)

        return sortedColors.map { color, _ in
            let hex = color.toHexString()
            let components = color.cgColor.components ?? [0, 0, 0]
            let rgb = "RGB: \(Int(components[0] * 255)), \(Int(components[1] * 255)), \(Int(components[2] * 255))"
            return (Color(color), hex, rgb)
        }
    }
}

// 🔵 颜色转换
extension UIColor {
    func toHexString() -> String {
        guard let components = cgColor.components else { return "#000000" }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
