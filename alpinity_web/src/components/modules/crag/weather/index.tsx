import { getApiMapWeatherByCragIdOptions } from "@/lib/api/@tanstack/react-query.gen";
import { useQuery } from "@tanstack/react-query";
import { useState } from "react";

import CurrentWeather from "./CurrentWeather";
import DailyForecast from "./DailyForecast";
import WeatherSkeleton from "./WeatherSkeleton";

interface CragWeatherProps {
  cragId: string;
}

const CragWeather = ({ cragId }: CragWeatherProps) => {
  const { data: weatherData, isLoading } = useQuery({
    ...getApiMapWeatherByCragIdOptions({
      path: {
        cragId,
      },
    }),
  });

  const [selectedDayIndex, setSelectedDayIndex] = useState(0);
  const [isOpen, setIsOpen] = useState(false);

  if (isLoading) {
    return <WeatherSkeleton />;
  }

  if (!weatherData) {
    return null;
  }

  const selectedDay = weatherData.daily?.[selectedDayIndex];

  // Filter hourly data for the selected day
  const hourlyForSelectedDay = weatherData.hourly?.filter((hourly) => {
    if (!selectedDay?.date || !hourly.time) return false;

    const hourlyDate = new Date(hourly.time);
    const selectedDate = new Date(selectedDay.date);

    return (
      hourlyDate.getDate() === selectedDate.getDate() &&
      hourlyDate.getMonth() === selectedDate.getMonth() &&
      hourlyDate.getFullYear() === selectedDate.getFullYear()
    );
  });

  return (
    <div className="space-y-4">
      {weatherData.current && (
        <>
          <CurrentWeather currentWeather={weatherData.current} isOpen={isOpen} onToggle={() => setIsOpen(!isOpen)} />

          {isOpen && weatherData.daily && weatherData.daily.length > 0 && (
            <DailyForecast
              dailyData={weatherData.daily}
              hourlyData={hourlyForSelectedDay || []}
              selectedDayIndex={selectedDayIndex}
              onSelectDay={setSelectedDayIndex}
            />
          )}
        </>
      )}
    </div>
  );
};

export default CragWeather;
