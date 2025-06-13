import { useEffect, useState } from "react";

export type Theme = "light" | "dark";

/**
 * useTheme – lightweight dark/light mode toggler that stores the preference in localStorage
 * and toggles the `dark` class on the document root. Designed to work with TailwindCSS `dark` variant.
 */
export default function useTheme() {
  const [theme, setTheme] = useState<Theme>(() => {
    if (typeof window === "undefined") {
      // During SSR we can't know, default to light
      return "light";
    }
    return (localStorage.getItem("theme") as Theme) ?? "light";
  });

  useEffect(() => {
    if (typeof document === "undefined") return;

    const root = document.documentElement;

    if (theme === "dark") {
      root.classList.add("dark");
    } else {
      root.classList.remove("dark");
    }

    localStorage.setItem("theme", theme);
  }, [theme]);

  const toggleTheme = () => setTheme((prev) => (prev === "dark" ? "light" : "dark"));

  const setDark = () => setTheme("dark");
  const setLight = () => setTheme("light");

  return { theme, toggleTheme, setDark, setLight } as const;
}
