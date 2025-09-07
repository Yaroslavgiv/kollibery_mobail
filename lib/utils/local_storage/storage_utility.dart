import 'package:get_storage/get_storage.dart';

class KLocalStorage {
  static final KLocalStorage _instance = KLocalStorage._internal();

  factory KLocalStorage() {
    return _instance;
  }

  KLocalStorage._internal();

  final _storage = GetStorage();

  // Сохранение данных в локальное хранилище с проверкой типа
  Future<void> saveData<T>(String key, T value) async {
    try {
      await _storage.write(key, value);
    } catch (e) {
      print('Ошибка при сохранении данных для ключа $key: $e');
    }
  }

  // Чтение данных из локального хранилища с возможностью указания значения по умолчанию
  T? readData<T>(String key, {T? defaultValue}) {
    try {
      return _storage.read<T>(key) ?? defaultValue;
    } catch (e) {
      print('Ошибка при чтении данных для ключа $key: $e');
      return defaultValue;
    }
  }

  // Удаление конкретных данных по ключу
  Future<void> removeData(String key) async {
    try {
      await _storage.remove(key);
    } catch (e) {
      print('Ошибка при удалении данных для ключа $key: $e');
    }
  }

  // Очистка всех сохранённых данных
  Future<void> clearAll() async {
    try {
      await _storage.erase();
    } catch (e) {
      print('Ошибка при очистке всех данных: $e');
    }
  }

  // Проверка существования ключа в хранилище
  bool containsKey(String key) {
    try {
      return _storage.hasData(key);
    } catch (e) {
      print('Ошибка при проверке существования ключа $key: $e');
      return false;
    }
  }
}
