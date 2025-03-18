import SwiftUI

struct ColorExtractorView: View {
    let colors: [(color: Color, hex: String, rgb: String)]

    var body: some View {
        VStack {
            Text("Extracted Colors")
                .font(.title2)
                .bold()
                .padding(.top)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(colors, id: \.hex) { colorInfo in
                        HStack {
                            Rectangle()
                                .fill(colorInfo.color)
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)

                            VStack(alignment: .leading) {
                                Text(colorInfo.hex)
                                    .font(.headline)
                                Text(colorInfo.rgb)
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
    }
}
