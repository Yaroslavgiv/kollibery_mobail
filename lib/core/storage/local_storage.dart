import 'package:get_storage/get_storage.dart';

import '../errors/exceptions.dart';
import '../logging/app_logger.dart';

/// Контракт локального хранилища.
/// Реализацию можно сменить (GetStorage / Hive) без затрагивания BL.
abstract class LocalStorage {
  Future<void> write<T>(String key, T value);

  T? read<T>(String key, {T? defaultValue});

  Future<void> remove(String key);

  Future<void> clear();

  bool containsKey(String key);
}

/// Реализация на GetStorage — текущий адаптер проекта.
class GetStorageLocalStorage implements LocalStorage {
  GetStorageLocalStorage({GetStorage? box}) : _box = box ?? GetStorage();

  final GetStorage _box;

  @override
  Future<void> write<T>(String key, T value) async {
    try {
      await _box.write(key, value);
    } catch (e) {
      AppLogger.error('Ошибка записи ключа $key', e);
      throw CacheException('Не удалось сохранить данные ($key).');
    }
  }

  @override
  T? read<T>(String key, {T? defaultValue}) {
    try {
      return _box.read<T>(key) ?? defaultValue;
    } catch (e) {
      AppLogger.error('Ошибка чтения ключа $key', e);
      return defaultValue;
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      await _box.remove(key);
    } catch (e) {
      AppLogger.error('Ошибка удаления ключа $key', e);
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _box.erase();
    } catch (e) {
      AppLogger.error('Ошибка очистки хранилища', e);
    }
  }

  @override
  bool containsKey(String key) {
    try {
      return _box.hasData(key);
    } catch (e) {
      AppLogger.error('Ошибка проверки ключа $key', e);
      return false;
    }
  }
}
