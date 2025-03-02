// Created with <3 on 01.03.2025.

public class DateTimeConverter {
  public static func convertDateStringToDate(dateString: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.date(from: dateString)
  }
}
