//
//  CragTopInfoContainerView.swift
//  RouteBoard
//
//  Created with <3 on 26.01.2025..
//

import GeneratedClient
import SwiftUI

func getWeatherSystemIcon(for weatherCode: Int32) -> String {
  // Map weather codes to SF Symbols
  switch weatherCode {
  case 0: return "sun.max.fill"  // Clear sky
  case 1, 2, 3: return "cloud.sun.fill"  // Mainly clear, partly cloudy, and overcast
  case 45, 48: return "cloud.fog.fill"  // Fog and depositing rime fog
  case 51, 53, 55: return "cloud.drizzle.fill"  // Drizzle: Light, moderate, and dense intensity
  case 56, 57: return "cloud.sleet.fill"  // Freezing Drizzle: Light and dense intensity
  case 61, 63, 65: return "cloud.rain.fill"  // Rain: Slight, moderate and heavy intensity
  case 66, 67: return "cloud.sleet.fill"  // Freezing Rain: Light and heavy intensity
  case 71, 73, 75: return "cloud.snow.fill"  // Snow fall: Slight, moderate, and heavy intensity
  case 77: return "cloud.snow.fill"  // Snow grains
  case 80, 81, 82: return "cloud.heavyrain.fill"  // Rain showers: Slight, moderate, and violent
  case 85, 86: return "cloud.snow.fill"  // Snow showers slight and heavy
  case 95: return "cloud.bolt.fill"  // Thunderstorm: Slight or moderate
  case 96, 99: return "cloud.bolt.rain.fill"  // Thunderstorm with slight and heavy hail
  default: return "cloud.fill"
  }
}

func getWeatherDescription(for weatherCode: Int32) -> String {
  switch weatherCode {
  case 0: return "Clear sky"
  case 1: return "Mainly clear"
  case 2: return "Partly cloudy"
  case 3: return "Overcast"
  case 45: return "Fog"
  case 48: return "Depositing rime fog"
  case 51: return "Light drizzle"
  case 53: return "Moderate drizzle"
  case 55: return "Dense drizzle"
  case 56: return "Light freezing drizzle"
  case 57: return "Dense freezing drizzle"
  case 61: return "Slight rain"
  case 63: return "Moderate rain"
  case 65: return "Heavy rain"
  case 66: return "Light freezing rain"
  case 67: return "Heavy freezing rain"
  case 71: return "Slight snow fall"
  case 73: return "Moderate snow fall"
  case 75: return "Heavy snow fall"
  case 77: return "Snow grains"
  case 80: return "Slight rain showers"
  case 81: return "Moderate rain showers"
  case 82: return "Violent rain showers"
  case 85: return "Slight snow showers"
  case 86: return "Heavy snow showers"
  case 95: return "Thunderstorm"
  case 96: return "Thunderstorm with slight hail"
  case 99: return "Thunderstorm with heavy hail"
  default: return "Unknown weather"
  }
}

private struct CragWeatherInfoView: View {
  var icon: String
  var value: String
  var unit: String
  var title: String

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Image(systemName: icon)
          .foregroundColor(Color.newTextColor)
          .font(.title3)

        HStack(alignment: .top, spacing: 2) {
          Text(value)
            .foregroundColor(Color.newTextColor)
            .font(.title2)
            .fontWeight(.semibold)
          Text(unit)
            .foregroundColor(Color.newTextColor.opacity(0.75))
            .font(.caption)
            .padding(.top, 5)

        }
      }
      Text(title)
        .foregroundColor(Color.newTextColor.opacity(0.75))
        .font(.caption)
        .fontWeight(.semibold)
    }
  }
}

// Detailed weather components
private struct DetailedCurrentWeatherView: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  var currentWeather: Components.Schemas.CurrentWeatherDto?
  var selectedDailyWeather: Components.Schemas.DailyWeatherDto?
  var uniqueDays: [Date]
  var selectedDayIndex: Int
  var onDaySelected: (Int) -> Void
  var formatDayForSelector: (Date) -> String

  @State private var isDaySelectorOpen = false

  var weatherCode: Int32 {
    selectedDailyWeather?.weatherCode ?? currentWeather?.weatherCode ?? 0
  }

  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Spacer()
        VStack(spacing: 8) {
          if !uniqueDays.isEmpty {
            Button {
              isDaySelectorOpen.toggle()
            } label: {
              HStack(spacing: 4) {
                Text(formatDayForSelector(uniqueDays[selectedDayIndex]))
                  .font(.subheadline)
                  .foregroundColor(Color.newTextColor)

                Image(systemName: "chevron.down")
                  .font(.caption)
                  .foregroundColor(Color.newTextColor)
              }
              .padding(.vertical, 4)
              .padding(.horizontal, 8)
              .background(Color.newBackgroundGray)
              .cornerRadius(20)
            }
            .popover(
              isPresented: $isDaySelectorOpen,
              attachmentAnchor: .point(.bottom),
              arrowEdge: .top
            ) {
              ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                  ForEach(0..<uniqueDays.count, id: \.self) { index in
                    Button(action: {
                      onDaySelected(index)
                      isDaySelectorOpen = false
                    }) {
                      HStack {
                        Text(formatDayForSelector(uniqueDays[index]))
                        Spacer()
                        if selectedDayIndex == index {
                          Image(systemName: "checkmark")
                        }
                      }
                      .padding(.vertical, 6)
                      .padding(.horizontal, 12)
                      .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(Color.newTextColor)

                    if index < uniqueDays.count - 1 {
                      Divider()
                    }
                  }
                }
                .padding(.vertical, 12)
                .frame(width: 200)
              }
              .frame(maxHeight: 200)
              .preferredColorScheme(.light)
              .presentationCompactAdaptation(.popover)
            }
          }

          Text(getWeatherDescription(for: weatherCode))
            .font(.headline)
            .foregroundColor(Color.newTextColor)

          Image(systemName: getWeatherSystemIcon(for: weatherCode))
            .font(.system(size: 50))
            .foregroundColor(Color.newTextColor)
        }
        Spacer()
      }

      // Additional weather details in a grid
      LazyVGrid(
        columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16
      ) {
        // Temperature - use selected day's max temperature if available
        if let temperature = selectedDailyWeather?.temperature2mMax ?? currentWeather?.temperature2m
        {
          DetailWeatherInfoItem(
            icon: "thermometer.medium",
            title: "Max Temp",
            value:
              "\(Int(authViewModel.getTemperatureConverter().convertCelsiusTemperature(temperature: temperature)))",
            unit: "°C"
          )
        }

        // Apparent (feels like) temperature max
        if let apparentTempMax = selectedDailyWeather?.apparentTemperatureMax {
          DetailWeatherInfoItem(
            icon: "thermometer.sun",
            title: "Feels Like Max",
            value:
              "\(Int(authViewModel.getTemperatureConverter().convertCelsiusTemperature(temperature: apparentTempMax)))",
            unit: "°C"
          )
        }

        // Precipitation - only available in daily forecast
        if let precipitation = selectedDailyWeather?.precipitationSum {
          DetailWeatherInfoItem(
            icon: "cloud.rain",
            title: "Precipitation",
            value: "\(precipitation)",
            unit: "mm"
          )
        }

        // Min Temperature - only available in daily forecast
        if let minTemperature = selectedDailyWeather?.temperature2mMin {
          DetailWeatherInfoItem(
            icon: "thermometer.low",
            title: "Min Temp",
            value:
              "\(Int(authViewModel.getTemperatureConverter().convertCelsiusTemperature(temperature: minTemperature)))",
            unit: "°C"
          )
        }

        // Apparent (feels like) temperature min
        if let apparentTempMin = selectedDailyWeather?.apparentTemperatureMin {
          DetailWeatherInfoItem(
            icon: "thermometer.snowflake",
            title: "Feels Like Min",
            value:
              "\(Int(authViewModel.getTemperatureConverter().convertCelsiusTemperature(temperature: apparentTempMin)))",
            unit: "°C"
          )
        }

        // Precipitation probability
        if let precipProb = selectedDailyWeather?.precipitationProbabilityMax {
          DetailWeatherInfoItem(
            icon: "drop.fill",
            title: "Chance of Rain",
            value: "\(precipProb)",
            unit: "%"
          )
        }
      }

      // Sunrise, sunset and UV index in a row
      if let sunrise = selectedDailyWeather?.sunrise, let sunset = selectedDailyWeather?.sunset {
        HStack(spacing: 30) {
          Spacer()

          VStack(spacing: 8) {
            Image(systemName: "sunrise.fill")
              .font(.title2)
              .foregroundColor(.orange)
            Text(formatTimeString(sunrise))
              .font(.subheadline)
              .foregroundColor(Color.newTextColor)
            Text("Sunrise")
              .font(.caption)
              .foregroundColor(Color.newTextColor.opacity(0.75))
          }

          VStack(spacing: 8) {
            Image(systemName: "sunset.fill")
              .font(.title2)
              .foregroundColor(.orange)
            Text(formatTimeString(sunset))
              .font(.subheadline)
              .foregroundColor(Color.newTextColor)
            Text("Sunset")
              .font(.caption)
              .foregroundColor(Color.newTextColor.opacity(0.75))
          }

          if let uvIndex = selectedDailyWeather?.uvIndexMax {
            VStack(spacing: 8) {
              Image(systemName: "sun.max.fill")
                .font(.title2)
                .foregroundColor(.yellow)
              Text("\(Int(uvIndex))")
                .font(.subheadline)
                .foregroundColor(Color.newTextColor)
              Text("UV Index")
                .font(.caption)
                .foregroundColor(Color.newTextColor.opacity(0.75))
            }
          }

          Spacer()
        }
        .padding(.top, 10)
      }

      // Wind information in a row
      if let windSpeed = selectedDailyWeather?.windSpeed10mMax,
        let windDirection = selectedDailyWeather?.windDirection10mDominant
      {
        HStack(spacing: 30) {
          Spacer()

          VStack(spacing: 8) {
            Image(systemName: "wind")
              .font(.title2)
              .foregroundColor(.blue)
            HStack(alignment: .top, spacing: 2) {
              Text("\(Int(windSpeed))")
                .font(.subheadline)
                .foregroundColor(Color.newTextColor)
              Text("km/h")
                .font(.caption2)
                .foregroundColor(Color.newTextColor.opacity(0.75))
                .padding(.top, 2)
            }
            Text("Max Wind")
              .font(.caption)
              .foregroundColor(Color.newTextColor.opacity(0.75))
          }

          VStack(spacing: 8) {
            Image(systemName: "arrow.up.left.and.arrow.down.right")
              .font(.title2)
              .foregroundColor(.blue)
            Text("\(windDirection)°")
              .font(.subheadline)
              .foregroundColor(Color.newTextColor)
            Text("Direction")
              .font(.caption)
              .foregroundColor(Color.newTextColor.opacity(0.75))
          }

          Spacer()
        }
        .padding(.top, 10)
      }
    }
    .padding(.vertical, 10)
  }

  private func formatTimeString(_ timeString: String) -> String {
    guard let date = DateTimeConverter.convertDateTimeStringToDate(dateTimeString: timeString)
    else {
      return "N/A"
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
  }
}

private struct DetailWeatherInfoItem: View {
  var icon: String
  var title: String
  var value: String
  var unit: String

  var body: some View {
    VStack(spacing: 4) {
      Image(systemName: icon)
        .font(.title3)
        .foregroundColor(Color.newTextColor)

      Text(title)
        .font(.caption)
        .foregroundColor(Color.newTextColor.opacity(0.75))

      HStack(alignment: .top, spacing: 2) {
        Text(value)
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundColor(Color.newTextColor)

        if !unit.isEmpty {
          Text(unit)
            .font(.caption2)
            .foregroundColor(Color.newTextColor.opacity(0.75))
            .padding(.top, 2)
        }
      }
    }
    .frame(maxWidth: .infinity)
  }
}

private struct ForecastItemView: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  var isHourly: Bool
  var dateTime: String
  var temperature: Double
  var weatherCode: Int32?
  var precipitation: Int32?
  var windSpeed: Double?

  var precipitationIcon: String {
    if let precip = precipitation {
      if precip < 33 {
        return "drop"
      } else if precip < 66 {
        return "drop.halffull"
      } else {
        return "drop.fill"
      }
    } else {
      return "drop"
    }
  }

  var body: some View {
    VStack(spacing: 8) {
      // Time or date
      Text(formatDateTime(dateTime, isHourly: isHourly))
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(Color.newTextColor)

      // Weather icon based on weather code
      Image(systemName: getWeatherSystemIcon(for: weatherCode ?? 0))
        .font(.title3)
        .foregroundColor(Color.newTextColor)
        .frame(height: 30)

      // Temperature
      HStack(alignment: .top, spacing: 1) {
        Text(
          "\(Int(authViewModel.getTemperatureConverter().convertCelsiusTemperature(temperature: temperature)))"
        )
        .font(.subheadline)
        .fontWeight(.semibold)
        .foregroundColor(Color.newTextColor)

        Text("°C")
          .font(.caption2)
          .foregroundColor(Color.newTextColor.opacity(0.75))
          .padding(.top, 1)
      }

      // Precipitation chance if available
      if let precip = precipitation {
        HStack(spacing: 2) {
          Image(systemName: precipitationIcon)
            .font(.caption2)
            .foregroundColor(.blue)

          Text("\(precip)%")
            .font(.caption2)
            .foregroundColor(Color.newTextColor.opacity(0.75))
        }
      }

      // Wind speed if available
      if let wind = windSpeed {
        HStack(spacing: 2) {
          Image(systemName: "wind")
            .font(.caption2)
            .foregroundColor(.blue)

          Text("\(Int(wind)) km/h")
            .font(.caption2)
            .foregroundColor(Color.newTextColor.opacity(0.75))
        }
      }
    }
    .frame(width: 70, height: 120)
    .padding(.vertical, 10)
    .padding(.horizontal, 5)
    .background(Color.newBackgroundGray)
    .cornerRadius(10)
    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
  }

  private func formatDateTime(_ dateTimeString: String, isHourly: Bool) -> String {
    guard
      let date = isHourly
        ? DateTimeConverter.convertDateTimeStringToDate(dateTimeString: dateTimeString)
        : DateTimeConverter.convertDateStringToDate(dateString: dateTimeString)
    else {
      return "N/A"
    }

    let formatter = DateFormatter()

    if isHourly {
      formatter.dateFormat = "E HH:mm"
      return formatter.string(from: date)
    } else {
      formatter.dateFormat = "E d"  // e.g., "Mon 15"
      return formatter.string(from: date)
    }
  }
}

struct CragTopInfoContainerView: View {
  @EnvironmentObject var authViewModel: AuthViewModel

  var crag: CragDetails?

  @State private var isExpanded = false
  @State private var weather: CragWeather?
  @State private var isLoading = true
  @State private var selectedDayIndex = 0

  private let cragWeatherClient = GetCragWeatherClient()

  func getCragWeather() async {
    defer {
      isLoading = false
    }

    if let crag = crag, let cragId = crag.id {
      weather = await cragWeatherClient.call(
        CragWeatherInput(cragId: cragId), authViewModel.getAuthData(), nil)
    }
  }

  // Get unique days from hourly forecasts
  private func getUniqueDays() -> [Date] {
    guard let hourlyForecasts = weather?.hourly else { return [] }

    var uniqueDays: [Date] = []
    let calendar = Calendar.current

    for hourly in hourlyForecasts {
      if let timeString = hourly.time,
        let date = DateTimeConverter.convertDateTimeStringToDate(dateTimeString: timeString)
      {
        let startOfDay = calendar.startOfDay(for: date)
        if !uniqueDays.contains(where: { calendar.isDate($0, inSameDayAs: startOfDay) }) {
          uniqueDays.append(startOfDay)
        }
      }
    }

    return uniqueDays
  }

  // Filter hourly forecasts for selected day
  private func hourlyForecastsForSelectedDay() -> [Components.Schemas.HourlyWeatherDto] {
    guard let hourlyForecasts = weather?.hourly else { return [] }
    let uniqueDays = getUniqueDays()

    if uniqueDays.isEmpty || selectedDayIndex >= uniqueDays.count {
      return []
    }

    let selectedDay = uniqueDays[selectedDayIndex]
    let calendar = Calendar.current

    return hourlyForecasts.compactMap { hourly in
      guard let timeString = hourly.time,
        let date = DateTimeConverter.convertDateTimeStringToDate(dateTimeString: timeString)
      else {
        return nil
      }
      return calendar.isDate(date, inSameDayAs: selectedDay) ? hourly : nil
    }
  }

  // Format date for day selector
  private func formatDayForSelector(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, MMM d"  // e.g. "Mon, Jan 15"
    return formatter.string(from: date)
  }

  // Get selected daily weather based on selected day index
  private func getSelectedDailyWeather() -> Components.Schemas.DailyWeatherDto? {
    guard let dailyForecasts = weather?.daily else { return nil }

    let uniqueDays = getUniqueDays()
    if uniqueDays.isEmpty || selectedDayIndex >= uniqueDays.count {
      return nil
    }

    // For the first day (today), we have a corresponding daily forecast
    // We can directly use the selectedDayIndex to access the forecast
    if selectedDayIndex < dailyForecasts.count {
      return dailyForecasts[selectedDayIndex]
    }

    return nil
  }

  var body: some View {
    VStack(spacing: 20) {
      if isLoading {
        HStack {
          Spacer()
          ProgressView()
            .foregroundColor(Color.newTextColor)
            .padding()
          Spacer()
        }
      } else if let weather = weather {
        Text("Current Weather")
          .font(.headline)
          .foregroundColor(Color.newTextColor)
          .padding(.horizontal, ThemeExtension.horizontalPadding)

        HStack {
          CragWeatherInfoView(
            icon: "thermometer",
            value:
              "\(authViewModel.getTemperatureConverter().convertCelsiusTemperature(temperature: weather.current?.temperature2m ?? 0))",
            unit: "°C",
            title: "Temperature")

          Spacer()

          CragWeatherInfoView(
            icon: "drop.halffull", value: "\(weather.current?.relativeHumidity2m ?? 0)", unit: "%",
            title: "Humidity")

          Spacer()

          CragWeatherInfoView(
            icon: "wind", value: "\(Int(floor(weather.current?.windSpeed10m ?? 0)))",
            unit: "km/h",
            title: "Wind Speed")
        }
        .padding(.horizontal, ThemeExtension.horizontalPadding)
      } else {
        HStack {
          Spacer()
          VStack(spacing: 8) {
            Image(systemName: "icloud.slash")
              .font(.title)
              .foregroundColor(Color.newTextColor.opacity(0.6))
            Text("No weather data available")
              .font(.subheadline)
              .foregroundColor(Color.newTextColor.opacity(0.75))
          }
          .padding()
          Spacer()
        }
        .padding(.horizontal, ThemeExtension.horizontalPadding)
      }

      if isExpanded, let weather = weather {
        Divider()

        VStack(spacing: 20) {
          // Detailed current weather - pass selected daily weather
          DetailedCurrentWeatherView(
            currentWeather: weather.current,
            selectedDailyWeather: getSelectedDailyWeather(),
            uniqueDays: getUniqueDays(),
            selectedDayIndex: selectedDayIndex,
            onDaySelected: { index in
              selectedDayIndex = index
            },
            formatDayForSelector: formatDayForSelector
          )

          Divider()

          // Forecast section title
          VStack(spacing: 10) {
            HStack {
              Text("Forecast")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color.newTextColor)

              Spacer()
            }
          }
          .padding(.horizontal, ThemeExtension.horizontalPadding)

          // Combined forecast scrollview
          ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10, pinnedViews: []) {
              // Hourly forecast items for selected day
              let filteredHourlyForecasts = hourlyForecastsForSelectedDay()
              if !filteredHourlyForecasts.isEmpty {
                ForEach(0..<filteredHourlyForecasts.count, id: \.self) { index in
                  let hourly = filteredHourlyForecasts[index]
                  if let time = hourly.time,
                    let temperature = hourly.temperature2m
                  {
                    ForecastItemView(
                      isHourly: true,
                      dateTime: time,
                      temperature: temperature,
                      weatherCode: hourly.weatherCode,
                      precipitation: hourly.precipitationProbability,
                      windSpeed: hourly.windSpeed10m
                    )
                    .environmentObject(authViewModel)
                  }
                }
              }
            }
            .padding(.horizontal, ThemeExtension.horizontalPadding)
          }
          .frame(height: 170)
        }
      }

      if weather != nil {
        Button(action: {
          withAnimation {
            isExpanded.toggle()
          }
        }) {
          HStack {
            Spacer()

            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
              .font(.title3)
              .foregroundColor(Color.newTextColor)

            Spacer()
          }
          .padding(5)
          .background(Color.newBackgroundGray)
          .cornerRadius(10)
          .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, ThemeExtension.horizontalPadding)
        .background(Color.white)
      }
    }
    .padding(.vertical, 20)
    .background(.white)
    .clipShape(RoundedRectangle(cornerRadius: 20))
    .task {
      await getCragWeather()
    }
  }
}
