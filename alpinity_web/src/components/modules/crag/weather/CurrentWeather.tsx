import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { CurrentWeatherDto } from "@/lib/api/types.gen";
import { Droplets, Wind } from "lucide-react";
import ChevronIcon from "./ChevronIcon";
import { getWeatherDescription, getWeatherIcon } from "./WeatherUtils";

interface CurrentWeatherProps {
  currentWeather: CurrentWeatherDto;
  isOpen: boolean;
  onToggle: () => void;
}

const CurrentWeather = ({ currentWeather, isOpen, onToggle }: CurrentWeatherProps) => {
  return (
    <Card
      className={`w-full cursor-pointer transition-all ${isOpen ? "bg-secondary/10" : "hover:bg-secondary/5"}`}
      onClick={onToggle}
    >
      <CardHeader className="pb-2">
        <CardTitle className="flex items-center justify-between text-lg font-medium">
          Current Weather
          <ChevronIcon open={isOpen} />
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <div className="text-4xl">{getWeatherIcon(currentWeather.weatherCode)}</div>
            <div>
              <p className="text-2xl font-bold">{currentWeather.temperature2m}°C</p>
              <p className="text-muted-foreground text-sm">{getWeatherDescription(currentWeather.weatherCode)}</p>
            </div>
          </div>
          <div className="space-y-2">
            <div className="flex items-center space-x-2 text-sm">
              <Wind className="h-4 w-4" />
              <span>{currentWeather.windSpeed10m} km/h</span>
            </div>
            <div className="flex items-center space-x-2 text-sm">
              <Droplets className="h-4 w-4" />
              <span>{currentWeather.relativeHumidity2m}%</span>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};

export default CurrentWeather;
