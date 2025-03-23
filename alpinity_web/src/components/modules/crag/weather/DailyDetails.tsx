import { DailyWeatherDto } from "@/lib/api/types.gen";
import { getWeatherDescription, getWeatherIcon } from "./WeatherUtils";

interface DailyDetailsProps {
  day: DailyWeatherDto;
}

const DailyDetails = ({ day }: DailyDetailsProps) => {
  return (
    <div className="mt-2">
      <div className="flex flex-col md:flex-row md:gap-8">
        {/* Weather icon and main temperatures */}
        <div className="mb-6 flex flex-col items-center justify-center text-center md:mb-0 md:w-1/3">
          <div className="mb-3 text-6xl">{getWeatherIcon(day.weatherCode)}</div>
          <p className="mb-3 text-xl font-medium">{getWeatherDescription(day.weatherCode)}</p>
          <p className="text-3xl font-bold">
            {day.temperature2mMax}°C / {day.temperature2mMin}°C
          </p>
        </div>

        {/* Weather details in 3x3 grid */}
        <div className="grid grid-cols-3 gap-3 md:w-2/3">
          <div className="space-y-1">
            <p className="text-muted-foreground text-sm">Feels Like Max</p>
            <p className="font-medium">{day.apparentTemperatureMax}°C</p>
          </div>
          <div className="space-y-1">
            <p className="text-muted-foreground text-sm">Feels Like Min</p>
            <p className="font-medium">{day.apparentTemperatureMin}°C</p>
          </div>
          <div className="space-y-1">
            <p className="text-muted-foreground text-sm">UV Index</p>
            <p className="font-medium">{day.uvIndexMax}</p>
          </div>

          <div className="space-y-1">
            <p className="text-muted-foreground text-sm">Precipitation</p>
            <p className="font-medium">{day.precipitationSum} mm</p>
          </div>
          <div className="space-y-1">
            <p className="text-muted-foreground text-sm">Chance of Rain</p>
            <p className="font-medium">{day.precipitationProbabilityMax}%</p>
          </div>
          <div className="space-y-1">
            <p className="text-muted-foreground text-sm">Humidity</p>
            <p className="font-medium">{day.precipitationProbabilityMax}%</p>
          </div>

          <div className="space-y-1">
            <p className="text-muted-foreground text-sm">Wind Speed</p>
            <p className="font-medium">{day.windSpeed10mMax} km/h</p>
          </div>
          <div className="space-y-1">
            <p className="text-muted-foreground text-sm">Wind Direction</p>
            <p className="font-medium">{day.windDirection10mDominant}°</p>
          </div>
          <div className="space-y-1">
            <p className="text-muted-foreground text-sm">Sunrise/Sunset</p>
            <p className="font-medium">
              {day.sunrise
                ? new Date(day.sunrise).toLocaleTimeString([], {
                    hour: "2-digit",
                    minute: "2-digit",
                  })
                : "N/A"}
              {" / "}
              {day.sunset
                ? new Date(day.sunset).toLocaleTimeString([], {
                    hour: "2-digit",
                    minute: "2-digit",
                  })
                : "N/A"}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DailyDetails;
