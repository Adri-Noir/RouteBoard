// Created with <3 on 06.03.2025.

class APICache<T: Hashable, R> {
  private var cache = [T: R]()

  func get(key: T) -> R? {
    return cache[key]
  }

  func set(key: T, value: R?) {
    if let value = value {
      cache[key] = value
    } else {
      cache.removeValue(forKey: key)
    }
  }

  func clear() {
    cache.removeAll()
  }
}
