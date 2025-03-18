import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var extractedColors: [(color: Color, hex: String, rgb: String)] = []

    let colorExtractor = ColorExtractor()

    var body: some View {
        // 使用 GeometryReader 获取屏幕尺寸，确保全屏显示
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 16) {
                    // ✅ 标题不换行、不省略
                    Text("Color Palette Extractor")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity)

                    // ✅ 显示用户选取的图片
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: min(300, geometry.size.height * 0.3))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    } else {
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            
                            Text("No image selected")
                                .foregroundColor(.gray)
                        }
                        .frame(height: min(250, geometry.size.height * 0.25))
                        .padding(.horizontal)
                    }

                    // ✅ 选择图片按钮
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images
                    ) {
                        Text("Select Image")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: geometry.size.width * 0.5)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedImage = uiImage
                                extractColors(from: uiImage)
                            }
                        }
                    }

                    // ✅ 颜色提取结果 - 现在包含在 ScrollView 中
                    if !extractedColors.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Extracted Colors")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
                            ForEach(0..<extractedColors.count, id: \.self) { index in
                                let colorInfo = extractedColors[index]
                                ColorSwatchView(
                                    color: colorInfo.color,
                                    hex: colorInfo.hex,
                                    rgb: colorInfo.rgb
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal, 8)
                        // 使用 frame 限制每个色卡的最大宽度
                        .frame(maxWidth: geometry.size.width)
                    }
                }
                .frame(
                    minWidth: geometry.size.width,
                    minHeight: geometry.size.height
                )
            }
            // 确保 ScrollView 利用全部可用空间
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.bottom) // 确保内容延伸到底部边缘
    }

    func extractColors(from image: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            let colors = colorExtractor.extractColors(from: image, count: 5)
            DispatchQueue.main.async {
                extractedColors = colors
            }
        }
    }
}

// 新组件: 颜色色卡视图组件，更好地控制每个色卡的布局
struct ColorSwatchView: View {
    let color: Color
    let hex: String
    let rgb: String
    
    var body: some View {
        HStack(spacing: 16) {
            // 颜色方块
            Rectangle()
                .fill(color)
                .frame(width: 60, height: 50)
                .cornerRadius(8)
            
            // 颜色信息
            VStack(alignment: .leading, spacing: 4) {
                Text(hex)
                    .font(.headline)
                Text(rgb)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}
