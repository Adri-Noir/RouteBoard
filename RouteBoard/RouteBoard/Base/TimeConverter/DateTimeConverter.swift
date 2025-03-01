// Created with <3 on 01.03.2025.

public class DateTimeConverter {
  public static func convertToDate(dateString: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy."
    return dateFormatter.date(from: dateString)
  }
}
