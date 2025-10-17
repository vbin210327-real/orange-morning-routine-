import SwiftUI

struct SplashView: View {
    @Environment(\.colorScheme) private var colorScheme

    private var palette: ThemePalette {
        ThemePalette(colorScheme: colorScheme)
    }

    var body: some View {
        ZStack {
            palette.splashBackground
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)

                VStack(spacing: 10) {
                    Text("开启高能量早晨")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(palette.splashTitle)

                    Text(Typography.bodyAttributed("start the morning with high energy"))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(palette.splashSubtitle)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(48)
        }
    }
}

#Preview {
    SplashView()
}
