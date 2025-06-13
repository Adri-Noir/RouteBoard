import Header from "@/components/ui/library/Header/Header";
import type { Metadata } from "next";
import "./globals.css";
import Providers from "./providers";

export const metadata: Metadata = {
  title: "Alpinity",
  description: "Alpinity",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        {/* Inline script to apply the saved theme before React hydration to avoid FOUC */}
        <script
          dangerouslySetInnerHTML={{
            __html: `(() => {
              try {
                const theme = localStorage.getItem('theme');
                if (theme === 'dark') {
                  document.documentElement.classList.add('dark');
                }
              } catch (_) {}
            })();`,
          }}
        />
      </head>
      <body className="antialiased">
        <Providers>
          <Header />
          <main className="relative">{children}</main>
        </Providers>
      </body>
    </html>
  );
}
