import { Cloud, CloudDrizzle, CloudFog, CloudLightning, CloudRain, CloudSnow, Sun } from "lucide-react";

export const getWeatherIcon = (weatherCode?: number) => {
  if (weatherCode === undefined || weatherCode === null) return <Sun />;

  // Weather codes based on WMO standards
  // 0: Clear sky
  // 1, 2, 3: Mainly clear, partly cloudy, and overcast
  // 45, 48: Fog and depositing rime fog
  // 51, 53, 55: Drizzle (light, moderate, dense)
  // 56, 57: Freezing drizzle
  // 61, 63, 65: Rain (slight, moderate, heavy)
  // 66, 67: Freezing rain
  // 71, 73, 75: Snow fall (slight, moderate, heavy)
  // 77: Snow grains
  // 80, 81, 82: Rain showers (slight, moderate, violent)
  // 85, 86: Snow showers (slight, heavy)
  // 95: Thunderstorm (slight or moderate)
  // 96, 99: Thunderstorm with hail

  if (weatherCode === 0) return <Sun />;
  if (weatherCode >= 1 && weatherCode <= 3) return <Cloud />;
  if (weatherCode === 45 || weatherCode === 48) return <CloudFog />;
  if (weatherCode >= 51 && weatherCode <= 57) return <CloudDrizzle />;
  if ((weatherCode >= 61 && weatherCode <= 67) || (weatherCode >= 80 && weatherCode <= 82)) return <CloudRain />;
  if ((weatherCode >= 71 && weatherCode <= 77) || weatherCode === 85 || weatherCode === 86) return <CloudSnow />;
  if (weatherCode === 95 || weatherCode === 96 || weatherCode === 99) return <CloudLightning />;

  return <Cloud />;
};

export const getWeatherDescription = (weatherCode?: number) => {
  if (weatherCode === undefined || weatherCode === null) return "Unknown";

  if (weatherCode === 0) return "Clear sky";
  if (weatherCode === 1) return "Mainly clear";
  if (weatherCode === 2) return "Partly cloudy";
  if (weatherCode === 3) return "Overcast";
  if (weatherCode === 45 || weatherCode === 48) return "Foggy";
  if (weatherCode >= 51 && weatherCode <= 55) return "Drizzle";
  if (weatherCode === 56 || weatherCode === 57) return "Freezing drizzle";
  if (weatherCode >= 61 && weatherCode <= 65) return "Rain";
  if (weatherCode === 66 || weatherCode === 67) return "Freezing rain";
  if (weatherCode >= 71 && weatherCode <= 75) return "Snow";
  if (weatherCode === 77) return "Snow grains";
  if (weatherCode >= 80 && weatherCode <= 82) return "Rain showers";
  if (weatherCode === 85 || weatherCode === 86) return "Snow showers";
  if (weatherCode === 95) return "Thunderstorm";
  if (weatherCode === 96 || weatherCode === 99) return "Thunderstorm with hail";

  return "Unknown";
};
