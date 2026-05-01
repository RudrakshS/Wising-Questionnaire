import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Wising Tax Engine — US·India Cross-Border Tax Wizard",
  description:
    "Deterministic, rules-based tax wizard for NRIs and US persons with India income. Calculates residency, jurisdiction, and cross-border compliance obligations.",
  keywords: ["NRI tax", "US India tax", "RNOR", "DTAA", "FBAR", "PFIC", "cross-border tax"],
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
      </head>
      <body>{children}</body>
    </html>
  );
}
