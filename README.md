# Kollibry - приложение доставки дронами

## 📋 Описание

Kollibry - это мобильное приложение для заказа товаров с доставкой дронами. Приложение поддерживает три роли пользователей: покупатель, продавец и техник. Построено на Flutter с использованием GetX для управления состоянием.

## 🏗️ Архитектура

Проект приведён к Clean Architecture с иерархией платы разработки:

`Repository → Service → Provider → Manager → UI`

- **Repository** — доступ к API и локальному хранилищу. UI его не вызывает.
- **Service** — бизнес-сценарии (заказ одного товара, роли, люк, дронбокс). Без Flutter-виджетов.
- **Provider** — состояние сессии (`SessionProvider`).
- **Manager** — GetX-контроллеры, единственная точка входа для View.
- **UI** — экраны ролей покупатель / продавец / техник.

```
lib/
├── core/                 # сеть, DI, ошибки, хранилище, логгер
├── domain/               # сущности, контракты репозиториев, сервисы
├── data/                 # реализации репозиториев и API
├── presentation/         # SessionProvider, CatalogManager, DeviceCommandManager
└── features/             # экраны и GetX-менеджеры ролей
```

- **Flutter** - кроссплатформенная разработка
- **GetX** - управление состоянием и навигация
- **GetStorage** - локальное хранение данных
- **HTTP/Dio** - работа с API
- **Flutter Map** - карты и геолокация

### Архитектурные паттерны

- **Repository Pattern** - абстракция работы с данными
- **MVC Pattern** - разделение логики, представления и данных
- **Dependency Injection** - через GetX bindings

### Структура проекта

```
lib/
├── app.dart                    # Главный класс приложения
├── main.dart                   # Точка входа
├── bindings/                   # DI контейнеры
├── common/                     # Общие компоненты
│   ├── styles/                # Цвета, размеры, изображения
│   ├── themes/                # Темы приложения
│   └── widgets/               # Переиспользуемые виджеты
├── data/                      # Слой данных
│   ├── models/                # Модели данных
│   ├── repositories/          # Репозитории
│   └── sources/               # API и локальные источники
├── features/                  # Функциональные модули
│   ├── auth/                  # Аутентификация
│   ├── home/                  # Главная страница
│   ├── cart/                  # Корзина
│   ├── orders/                # Заказы
│   ├── profile/               # Профиль
│   ├── seller/                # Функции продавца
│   ├── tech/                  # Функции техника
│   └── admin/                 # Административные функции
├── routes/                    # Маршрутизация
├── utils/                     # Утилиты
└── localizations/             # Локализация
```

## 👥 Роли пользователей

### Покупатель (buyer)

- Просмотр каталога товаров
- Добавление товаров в корзину
- Оформление заказов с выбором точки доставки
- Отслеживание статуса доставки
- Управление избранными товарами

### Продавец (seller)

- Просмотр своих товаров
- Просмотр заказов от покупателей
- Управление статусами заказов
- Выбор точки отправки товара

### Техник (tech)

- Просмотр заказов для технической обработки
- Детальная информация о заказах
- Обновление статусов заказов
- Управление дронами и доставкой

## 🚀 Установка и запуск

### Требования

- Flutter SDK 3.6.0+
- Dart SDK
- Android Studio / VS Code
- Git

### Установка

1. Клонируйте репозиторий:
```bash
git clone https://github.com/Yaroslavgiv/kollibery_mobail.git
cd kollibry
```

2. Установите зависимости:
```bash
flutter pub get
```

3. Настройте платформы:
```bash
flutter create --platforms=android,ios .
```

4. Запустите приложение:
```bash
flutter run
```

### Конфигурация

- **API Base URL**: `http://80.90.191.66`
- **Локальное хранилище**: GetStorage
- **Карты**: Flutter Map с OpenStreetMap

## 📱 Основные экраны

### Аутентификация

- **LoginScreen** - вход в систему
- **RegistrationScreen** - регистрация
- **ForgotPasswordScreen** - восстановление пароля

### Главные экраны

- **MainScreen** - главный экран покупателя
- **SellerMainScreen** - главный экран продавца
- **TechMainScreen** - главный экран техника

### Функциональные экраны

- **HomeScreen** - каталог товаров
- **CartScreen** - корзина покупок
- **OrderListScreen** - список заказов
- **DeliveryStatusScreen** - статус доставки
- **ProfileScreen** - профиль пользователя

## 🔌 API Endpoints

### Базовый URL

```
http://80.90.191.66
```

### Заказы

- `POST /order/placeorder` - создание заказа
- `GET /order/getorders` - получение заказов
- `GET /order/getproducts` - получение товаров
- `GET /order/sseorders/{orderId}` - подписка на статус заказа

### Полеты

- `GET /flight/orderlocation` - получение местоположения заказа

### Структура заказа

```json
{
  "userId": "string",
  "productId": 0,
  "quantity": 0,
  "deliveryLatitude": 0.0,
  "deliveryLongitude": 0.0
}
```

## 🗂️ Модели данных

### OrderModel

```dart
class OrderModel {
  final int id;
  final String userId;
  final int productId;
  final int quantity;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final String status;
  final String productName;
  final String productImage;
  final double price;
  final String buyerName;
  final String sellerName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

## 🎨 Темы и стили

### Цветовая схема

- **Primary**: основной цвет приложения
- **Secondary**: дополнительный цвет
- **Text Primary/Secondary**: цвета текста
- **Background**: фоновые цвета

### Адаптивность

- Поддержка различных размеров экранов
- Responsive дизайн для планшетов
- Оптимизация для мобильных устройств

## 🔧 Утилиты

### Управление экранами

- `ScreenUtil` - адаптивные размеры
- `DeviceUtil` - информация об устройстве

### Валидация

- `ValidationUtil` - валидация форм
- Email, пароль, телефон

### Хелперы

- `DateFormatter` - форматирование дат
- `HelperFunctions` - общие функции
- `StorageUtility` - работа с хранилищем

## 🌐 Локализация

Поддерживаемые языки:

- Русский (ru.json)
- Английский (en.json)

## 📦 Зависимости

### Основные

- `get: ^4.6.6` - управление состоянием
- `get_storage: ^2.1.1` - локальное хранилище
- `http: ^1.2.2` - HTTP клиент
- `dio: ^5.8.0+1` - продвинутый HTTP клиент

### UI/UX

- `flutter_svg: ^2.0.16` - SVG поддержка
- `carousel_slider: ^5.0.0` - карусели
- `motion_tab_bar: ^2.0.0` - анимированные табы
- `badges: ^2.0.3` - бейджи

### Карты и геолокация

- `flutter_map: ^8.0.0` - карты
- `location: ^8.0.0` - геолокация
- `latlong2: ^0.9.1` - координаты

## 🚀 Развертывание

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

## 🧪 Тестирование

```bash
flutter test
```

## 📝 Логирование

Используется встроенный `Logger` для отладки:

- Уровни логирования
- Цветной вывод
- Фильтрация по тегам

## 🔒 Безопасность

- Локальное хранение токенов
- Валидация входных данных
- HTTPS для API запросов
- Управление сессиями

## 📞 Поддержка

Для получения поддержки:

1. Создайте issue в репозитории
2. Опишите проблему подробно
3. Приложите логи и скриншоты

## 📄 Лицензия

[Указать лицензию проекта]

## 🤝 Вклад в проект

1. Форкните репозиторий
2. Создайте feature branch
3. Внесите изменения
4. Создайте Pull Request

---

**Версия**: 0.1.0  
**Последнее обновление**: 2025-01-07
