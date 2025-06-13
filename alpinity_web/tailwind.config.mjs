import animatePlugin from "tailwindcss-animate";

/** @type {import('tailwindcss').Config} */
const config = {
  darkMode: "class",
  content: ["./src/**/*.{ts,tsx}"],
  theme: {
    extend: {},
  },
  plugins: [animatePlugin],
};

export default config;
