//
//  CragTopInfoContainerView.swift
//  RouteBoard
//
//  Created with <3 on 26.01.2025..
//

import GeneratedClient
import SwiftUI

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

  var body: some View {
    VStack(spacing: 16) {
      // Weather description and icon
      if let weather = currentWeather?.weather {
        HStack {
          Spacer()
          VStack(spacing: 8) {
            Text(weather.description?.capitalized ?? "Unknown")
              .font(.headline)
              .foregroundColor(Color.newTextColor)

            // You might want to use a custom weather icon here based on the icon code
            Image(systemName: getWeatherSystemIcon(for: weather.icon ?? ""))
              .font(.system(size: 50))
              .foregroundColor(Color.newTextColor)
          }
          Spacer()
        }
      }

      // Additional weather details in a grid
      LazyVGrid(
        columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16
      ) {
        // Feels like temperature
        if let feelsLike = currentWeather?.feelsLike {
          DetailWeatherInfoItem(
            icon: "thermometer.medium",
            title: "Feels Like",
            value:
              "\(Int(authViewModel.getTemperatureConverter().convertKelvinTemperature(temperature: feelsLike)))",
            unit: "°C"
          )
        }

        // UV Index
        if let uvIndex = currentWeather?.uvIndex {
          DetailWeatherInfoItem(
            icon: "sun.max.fill",
            title: "UV Index",
            value: "\(Int(uvIndex))",
            unit: ""
          )
        }

        // Pressure
        if let pressure = currentWeather?.pressure {
          DetailWeatherInfoItem(
            icon: "gauge",
            title: "Pressure",
            value: "\(pressure)",
            unit: "hPa"
          )
        }

        // Visibility
        if let visibility = currentWeather?.visibility {
          DetailWeatherInfoItem(
            icon: "eye",
            title: "Visibility",
            value: "\(visibility / 1000)",
            unit: "km"
          )
        }

        // Clouds
        if let clouds = currentWeather?.clouds {
          DetailWeatherInfoItem(
            icon: "cloud",
            title: "Cloudiness",
            value: "\(clouds)",
            unit: "%"
          )
        }

        // Wind gust if available
        if let windGust = currentWeather?.windGust, windGust > 0 {
          DetailWeatherInfoItem(
            icon: "wind",
            title: "Wind Gust",
            value: "\(Int(windGust))",
            unit: "km/h"
          )
        }

        // Wind direction
        if let windDegree = currentWeather?.windDegree {
          DetailWeatherInfoItem(
            icon: "arrow.up.left.and.arrow.down.right",
            title: "Wind Direction",
            value: "\(windDegree)",
            unit: ""
          )
        }
      }

      // Sunrise and sunset times
      if let sunrise = currentWeather?.sunrise, let sunset = currentWeather?.sunset {
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

          Spacer()
        }
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

  private func getWeatherSystemIcon(for iconCode: String) -> String {
    // TODO: maybe expand this to include all possible icon codes
    switch iconCode {
    case "01d": return "sun.max.fill"
    case "01n": return "moon.stars.fill"
    case "02d", "02n": return "cloud.sun.fill"
    case "03d", "03n": return "cloud.fill"
    case "04d", "04n": return "cloud.fill"
    case "09d", "09n": return "cloud.drizzle.fill"
    case "10d", "10n": return "cloud.rain.fill"
    case "11d", "11n": return "cloud.bolt.fill"
    case "13d", "13n": return "cloud.snow.fill"
    case "50d", "50n": return "cloud.fog.fill"
    default: return "cloud.fill"
    }
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
  var weatherIcon: String?
  var weatherDescription: String?
  var precipitation: Double?

  var precipitationIcon: String {
    if let precip = precipitation {
      if precip * 100 < 33 {
        return "drop"
      } else if precip * 100 < 66 {
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

      // Weather icon
      Image(systemName: getWeatherSystemIcon(for: weatherIcon ?? ""))
        .font(.title3)
        .foregroundColor(Color.newTextColor)
        .frame(height: 30)

      // Temperature
      HStack(alignment: .top, spacing: 1) {
        Text(
          "\(Int(authViewModel.getTemperatureConverter().convertKelvinTemperature(temperature: temperature)))"
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

          Text("\(Int(precip * 100))%")
            .font(.caption2)
            .foregroundColor(Color.newTextColor.opacity(0.75))
        }
      }
    }
    .frame(width: 70, height: 100)
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

  private func getWeatherSystemIcon(for iconCode: String) -> String {
    // Map OpenWeather icon codes to SF Symbols
    switch iconCode {
    case "01d": return "sun.max.fill"
    case "01n": return "moon.stars.fill"
    case "02d", "02n": return "cloud.sun.fill"
    case "03d", "03n": return "cloud.fill"
    case "04d", "04n": return "cloud.fill"
    case "09d", "09n": return "cloud.drizzle.fill"
    case "10d", "10n": return "cloud.rain.fill"
    case "11d", "11n": return "cloud.bolt.fill"
    case "13d", "13n": return "cloud.snow.fill"
    case "50d", "50n": return "cloud.fog.fill"
    default: return "cloud.fill"
    }
  }
}

struct CragTopInfoContainerView: View {
  @EnvironmentObject var cragWeatherCacheClient: CragWeatherCacheClient
  @EnvironmentObject var authViewModel: AuthViewModel

  var crag: CragDetails?

  @State private var isExpanded = false
  @State private var weather: CragWeather?
  @State private var isLoading = false

  func getCragWeather() async {
    if let crag = crag, let cragId = crag.id {
      isLoading = true
      weather = await cragWeatherCacheClient.call(
        CragWeatherInput(cragId: cragId), authViewModel.getAuthData(), nil)
      isLoading = false
    }
  }

  var body: some View {
    VStack(spacing: 20) {
      if isLoading {
        HStack {
          Spacer()
          ProgressView()
            .padding()
          Spacer()
        }
      } else if let weather = weather {
        HStack {
          CragWeatherInfoView(
            icon: "thermometer",
            value:
              "\(authViewModel.getTemperatureConverter().convertKelvinTemperature(temperature: weather.currentWeather?.temperature ?? 0))",
            unit: "°C",
            title: "Temperature")

          Spacer()

          CragWeatherInfoView(
            icon: "drop.halffull", value: "\(weather.currentWeather?.humidity ?? 0)", unit: "%",
            title: "Humidity")

          Spacer()

          CragWeatherInfoView(
            icon: "wind", value: "\(Int(floor(weather.currentWeather?.windSpeed ?? 0)))",
            unit: "km/h",
            title: "Wind Speed")
        }
      } else {
        HStack {
          Spacer()
          VStack(spacing: 8) {
            Image(systemName: "cloud.slash")
              .font(.title)
              .foregroundColor(Color.newTextColor.opacity(0.6))
            Text("No weather data available")
              .font(.subheadline)
              .foregroundColor(Color.newTextColor.opacity(0.75))
          }
          .padding()
          Spacer()
        }
      }

      if isExpanded, let weather = weather {
        VStack(spacing: 20) {
          // Detailed current weather
          DetailedCurrentWeatherView(currentWeather: weather.currentWeather)

          Divider()

          // Forecast section title
          HStack {
            Text("Forecast")
              .font(.headline)
              .fontWeight(.semibold)
              .foregroundColor(Color.newTextColor)
            Spacer()
          }
          .padding(.horizontal, 5)

          // Combined forecast scrollview
          ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10, pinnedViews: []) {
              // Hourly forecast items
              if let hourlyForecasts = weather.hourly {
                ForEach(0..<min(24, hourlyForecasts.count), id: \.self) { index in
                  let hourly = hourlyForecasts[index]
                  if let dateTime = hourly.dateTime, let temperature = hourly.temperature {
                    ForecastItemView(
                      isHourly: true,
                      dateTime: dateTime,
                      temperature: temperature,
                      weatherIcon: hourly.weather?.icon,
                      weatherDescription: hourly.weather?.description,
                      precipitation: hourly.probabilityOfPrecipitation
                    )
                  }
                }
              }

              // Daily forecast items
              if let dailyForecasts = weather.daily {
                ForEach(0..<min(7, dailyForecasts.count), id: \.self) { index in
                  let daily = dailyForecasts[index]
                  if let date = daily.date, let temperature = daily.temperature?.day {
                    ForecastItemView(
                      isHourly: false,
                      dateTime: date,
                      temperature: temperature,
                      weatherIcon: daily.weather?.icon,
                      weatherDescription: daily.weather?.description,
                      precipitation: daily.probabilityOfPrecipitation
                    )
                  }
                }
              }
            }
            .padding(.horizontal, 5)
          }
          .frame(height: 150)
        }
      }

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
    }
    .padding(20)
    .background(.white)
    .clipShape(RoundedRectangle(cornerRadius: 20))
    .task {
      await getCragWeather()
    }

    // GradesGraphView(gradesModel: GradesGraphModel(crag: crag))
    // .frame(height: 200)
  }
}
