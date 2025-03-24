import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "**.mapbox.com",
      },
      {
        protocol: "https",
        hostname: "alpinitydev.blob.core.windows.net",
      },
    ],
  },
};

export default nextConfig;
