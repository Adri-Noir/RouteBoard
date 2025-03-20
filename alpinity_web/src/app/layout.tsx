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
    <html lang="en">
      <body className="antialiased">
        <Providers>
          <Header />
          <main className="relative">{children}</main>
        </Providers>
      </body>
    </html>
  );
}
