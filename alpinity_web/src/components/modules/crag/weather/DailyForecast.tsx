import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { DailyWeatherDto, HourlyWeatherDto } from "@/lib/api/types.gen";
import DailyDetails from "./DailyDetails";
import DaySelector from "./DaySelector";
import HourlyForecast from "./HourlyForecast";

interface DailyForecastProps {
  dailyData: DailyWeatherDto[];
  hourlyData: HourlyWeatherDto[];
  selectedDayIndex: number;
  onSelectDay: (index: number) => void;
}

const DailyForecast = ({ dailyData, hourlyData, selectedDayIndex, onSelectDay }: DailyForecastProps) => {
  if (!dailyData || dailyData.length === 0) return null;

  const selectedDay = dailyData[selectedDayIndex];

  return (
    <Card className="mt-[-1px] pt-2">
      <CardHeader className="pb-2">
        <CardTitle className="text-lg font-medium">Daily Forecast</CardTitle>
      </CardHeader>
      <CardContent>
        <DaySelector dailyData={dailyData} selectedDayIndex={selectedDayIndex} onSelectDay={onSelectDay} />

        {selectedDay && <DailyDetails day={selectedDay} />}

        <HourlyForecast hourlyData={hourlyData} />
      </CardContent>
    </Card>
  );
};

export default DailyForecast;
