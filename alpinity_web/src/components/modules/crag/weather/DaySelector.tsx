import { DailyWeatherDto } from "@/lib/api/types.gen";
import { getWeatherIcon } from "./WeatherUtils";

interface DaySelectorProps {
  dailyData: DailyWeatherDto[];
  selectedDayIndex: number;
  onSelectDay: (index: number) => void;
}

const DaySelector = ({ dailyData, selectedDayIndex, onSelectDay }: DaySelectorProps) => {
  return (
    <div className="flex space-x-2 overflow-x-auto pb-4">
      {dailyData.map((day, index) => (
        <button
          key={index}
          onClick={() => onSelectDay(index)}
          className={`flex min-w-[80px] flex-col items-center rounded-lg p-2 transition-colors ${
          selectedDayIndex === index ? "bg-primary text-primary-foreground" : "bg-secondary hover:bg-secondary/80" }`}
        >
          <span className="text-xs font-medium">
            {index === 0
              ? "Today"
              : index === 1
                ? "Tomorrow"
                : new Date(day.date || "").toLocaleDateString(undefined, { weekday: "short" })}
          </span>
          <span className="my-1 text-xl">{getWeatherIcon(day.weatherCode)}</span>
          <span className="text-xs">
            {day.temperature2mMax}° / {day.temperature2mMin}°
          </span>
        </button>
      ))}
    </div>
  );
};

export default DaySelector;
