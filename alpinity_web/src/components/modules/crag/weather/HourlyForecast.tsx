import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion";
import { HourlyWeatherDto } from "@/lib/api/types.gen";
import { Droplets, Wind } from "lucide-react";
import { getWeatherIcon } from "./WeatherUtils";

interface HourlyForecastProps {
  hourlyData: HourlyWeatherDto[];
}

const HourlyForecast = ({ hourlyData }: HourlyForecastProps) => {
  if (!hourlyData || hourlyData.length === 0) return null;

  return (
    <div className="mt-4">
      <Accordion type="single" collapsible className="w-full">
        <AccordionItem value="hourly-forecast" className="border-none">
          <AccordionTrigger className="bg-secondary/50 w-full rounded-md px-4 py-2">
            <span className="text-base font-medium">Hourly Forecast</span>
          </AccordionTrigger>
          <AccordionContent className="pt-4">
            <div className="flex space-x-4 overflow-x-auto pb-2">
              {hourlyData.map((hourly, index) => {
                const hourlyTime = new Date(hourly.time || "");
                return (
                  <div key={index} className="flex min-w-[60px] flex-col items-center">
                    <p className="text-xs font-medium">{hourlyTime.getHours().toString().padStart(2, "0")}:00</p>
                    <div className="my-1 text-xl">{getWeatherIcon(hourly.weatherCode)}</div>
                    <p className="text-sm font-bold">{hourly.temperature2m}°</p>
                    <div className="mt-1 flex items-center">
                      <Droplets className="mr-1 h-3 w-3" />
                      <span className="text-xs">{hourly.relativeHumidity2m}%</span>
                    </div>
                    <div className="mt-1 flex items-center">
                      <Wind className="mr-1 h-3 w-3" />
                      <span className="text-xs">{hourly.windSpeed10m}km/h</span>
                    </div>
                    {hourly.precipitationProbability !== undefined && (
                      <p className="mt-1 text-xs">{hourly.precipitationProbability}%</p>
                    )}
                  </div>
                );
              })}
            </div>
          </AccordionContent>
        </AccordionItem>
      </Accordion>
    </div>
  );
};

export default HourlyForecast;
