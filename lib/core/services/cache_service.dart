import 'dart:async';

class CacheEntry<T> {
  final T data;
  final DateTime timestamp;

  CacheEntry({
    required this.data,
    required this.timestamp,
  });

  bool isValid(Duration maxAge) {
    return DateTime.now().difference(timestamp) <= maxAge;
  }
}

class CacheService {
  // Singleton pattern
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final Map<String, CacheEntry<dynamic>> _cache = {};
  
  // Default TTL: 5 minutes
  final Duration _defaultMaxAge = const Duration(minutes: 5);

  /// Zwraca zbuforowane dane jeśli istnieją i są wciąż ważne.
  T? get<T>(String key, {Duration? maxAge}) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isValid(maxAge ?? _defaultMaxAge)) {
      return entry.data as T;
    } else {
      _cache.remove(key); // Stale entry
      return null;
    }
  }

  /// Zapisuje dane w buforze.
  void set<T>(String key, T value) {
    _cache[key] = CacheEntry<T>(
      data: value,
      timestamp: DateTime.now(),
    );
  }

  /// Usuwa dany wpis z bufora.
  void invalidate(String key) {
    _cache.remove(key);
  }

  /// Czyści cały bufor (np. przy wylogowaniu).
  void clear() {
    _cache.clear();
  }

  /// Pattern stale-while-revalidate:
  /// Zwraca zbuforowane dane natychmiast, a w tle odpala fetchFuture, by zaktualizować cache.
  /// Jeśli brak cache'u, po prostu awaituje na fetchFuture.
  Future<T> fetchWithStaleWhileRevalidate<T>({
    required String key,
    required Future<T> Function() fetchFuture,
    Duration? maxAge,
  }) async {
    final cachedData = get<T>(key, maxAge: maxAge);
    
    if (cachedData != null) {
      // Zwróć od razu cache, a w tle odśwież
      unawaited(
        fetchFuture().then((freshData) {
          set(key, freshData);
        }).catchError((_) {
          // Zignoruj błędy tła
        }),
      );
      return cachedData;
    }

    // Brak cache – pobierz synchronicznie
    final freshData = await fetchFuture();
    set(key, freshData);
    return freshData;
  }
}
