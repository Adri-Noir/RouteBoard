// Created with <3 on 09.03.2025.

public protocol TemperatureConverterProtocol {
  func convertCelsiusTemperature(temperature: Double) -> Double
}

public class CelsiusTemperatureConverter: TemperatureConverterProtocol {
  public func convertCelsiusTemperature(temperature: Double) -> Double {
    return round(temperature * 10) / 10
  }
}

public class FahrenheitTemperatureConverter: TemperatureConverterProtocol {
  public func convertCelsiusTemperature(temperature: Double) -> Double {
    return round((temperature * 9 / 5 + 32) * 10) / 10
  }
}
