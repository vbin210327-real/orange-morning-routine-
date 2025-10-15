import type { Metadata } from "next";
import { ZCOOL_KuaiLe, Noto_Sans_SC } from "next/font/google";
import "./globals.css";

const headingFont = ZCOOL_KuaiLe({
  subsets: ["latin"],
  weight: "400",
  variable: "--font-heading",
  display: "swap",
});

const bodyFont = Noto_Sans_SC({
  subsets: ["latin"],
  weight: ["300", "400", "500", "700"],
  variable: "--font-body",
  display: "swap",
});

export const metadata: Metadata = {
  title: "晨间能量舱",
  description: "以复古卡通的温度开启沉浸式晨间启动仪式，写下能量与感恩。",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="zh-Hans">
      <body className={`${headingFont.variable} ${bodyFont.variable}`}>
        {children}
      </body>
    </html>
  );
}
