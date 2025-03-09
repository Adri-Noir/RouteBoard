// Created with <3 on 09.03.2025.

public protocol TemperatureConverterProtocol {
  func convertKelvinTemperature(temperature: Double) -> Double
}

public class CelsiusTemperatureConverter: TemperatureConverterProtocol {
  public func convertKelvinTemperature(temperature: Double) -> Double {
    return round((temperature - 273.15) * 10) / 10
  }
}

public class FahrenheitTemperatureConverter: TemperatureConverterProtocol {
  public func convertKelvinTemperature(temperature: Double) -> Double {
    return round(((temperature - 273.15) * 9 / 5 + 32) * 10) / 10
  }
}
