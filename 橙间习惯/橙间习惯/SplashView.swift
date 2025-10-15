import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "FFE0B5"), Color(hex: "FFC2E1")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)

                VStack(spacing: 10) {
                    Text("开启高能量早晨")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "4C2A1C"))

                    Text("start the morning with high energy")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "845131").opacity(0.75))
                }
            }
            .padding(48)
        }
    }
}

#Preview {
    SplashView()
}
