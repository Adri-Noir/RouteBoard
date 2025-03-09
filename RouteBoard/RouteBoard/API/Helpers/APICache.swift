// Created with <3 on 06.03.2025.

class APICache<T: Hashable, R> {
  private var cache = [T: R]()
  private var cacheTimeMap = [T: Date]()
  private var cacheTime: TimeInterval = 3600  // 1 hour

  init() {}

  init(cacheTime: TimeInterval) {
    self.cacheTime = cacheTime
  }

  func get(key: T) -> R? {
    if let cached = cache[key] {
      if let cachedTime = cacheTimeMap[key], Date().timeIntervalSince(cachedTime) < cacheTime {
        return cached
      }
    }
    return nil
  }

  func set(key: T, value: R?) {
    if let value = value {
      cache[key] = value
      cacheTimeMap[key] = Date()
    } else {
      cache.removeValue(forKey: key)
      cacheTimeMap.removeValue(forKey: key)
    }
  }

  func clear() {
    cache.removeAll()
    cacheTimeMap.removeAll()
  }
}
