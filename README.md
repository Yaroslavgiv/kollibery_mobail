# Kollibry

Мобильное приложение доставки дронами. Три роли: **покупатель** (`buyer`), **продавец** (`seller`) и **техник** (`technician`). Стек: Flutter 3.6+, GetX, GetStorage, Dio/http, flutter_map.

Репозиторий: [Yaroslavgiv/kollibery_mobail](https://github.com/Yaroslavgiv/kollibery_mobail)

## Возможности по ролям

### Покупатель

- В каталоге заказывает **один товар** за раз.
- На карте выбирает точку посадки дрона; координаты уходят на сервер с пометкой покупателя.
- Отслеживает статус заказа по SSE (`/order/sseorders/{orderId}`).
- После посадки открывает грузовой бокс дрона.

### Продавец

- Две основные вкладки: товары и заказы. Каждый заказ отправляется отдельно.
- Вызывает дрон, указывает точку посадки (пометка продавца).
- Статусы: дрон вылетел → дрон прилетел → открытие люка → отправка.
- После того как покупатель забрал товар, заказ уходит из списка (с кратким уведомлением).

### Техник

- Может и заказать товар (как покупатель), и отправить (как продавец) — с указанием геолокации.
- Управление грузовым люком дрона (открыть / закрыть).
- Управление дронбоксом: крыша, платформа (подъём / опускание), люк, батареи, зарядка.

Роль читается из JWT и задаёт стартовый маршрут (`/home`, `/seller-home`, `/tech-home`).

## Архитектура

Clean Architecture и иерархия платы разработки:

```
Repository → Service → Provider → Manager → UI
```

| Слой | Что делает | Куда инжектируется |
| --- | --- | --- |
| **Repository** | API и локальное хранилище | Service, Provider, Manager |
| **Service** | Бизнес-сценарии без виджетов (заказ одного товара, точка посадки, люк, дронбокс) | Provider, Manager |
| **Provider** | Состояние сессии (`SessionProvider`) | только Manager |
| **Manager** | GetX-контроллеры — единственная точка входа для View | никуда |
| **UI** | Экраны ролей | вызывает только Manager |

View **не** вызывает `FlightApi`, `OrderApi` и репозитории напрямую.

Принципы: SOLID, KISS, DRY, инверсия зависимостей, комментарии в коде на русском.

### Структура `lib/`

```
lib/
├── main.dart                 # точка входа, AppBindings до runApp
├── app.dart                  # GetMaterialApp, стартовый маршрут из SessionProvider
├── core/                     # сеть, DI, ошибки, хранилище, логгер, JWT
│   ├── constants/storage_keys.dart
│   ├── di/app_bindings.dart
│   ├── errors/               # Failures, Exceptions
│   ├── logging/app_logger.dart
│   ├── network/api_client.dart
│   ├── storage/local_storage.dart
│   └── utils/jwt_decoder.dart
├── domain/                   # сущности, контракты, сервисы (без Flutter-виджетов)
│   ├── entities/             # UserRole, GeoPoint, UserEntity, ProductEntity, OrderEntity
│   ├── repositories/         # интерфейсы
│   └── services/             # AuthService, ProductService, OrderService, FlightService
├── data/                     # реализации репозиториев, DTO, API
│   ├── models/               # ProductModel, OrderModel
│   ├── repositories/         # *Impl
│   └── sources/api/          # HTTP, SSE, WebSocket статусов
├── presentation/             # слой BL для UI
│   ├── providers/session_provider.dart
│   └── managers/             # CatalogManager, DeviceCommandManager
├── features/                 # экраны и GetX-менеджеры ролей
│   ├── auth/
│   ├── onboarding/
│   ├── home/                 # каталог покупателя
│   ├── cart/
│   ├── favorites/
│   ├── orders/
│   ├── profile/
│   ├── seller/
│   └── tech/
├── common/                   # темы, цвета, размеры, виджеты
├── routes/app_routes.dart
└── utils/                    # константы API, ScreenUtil, DateFormatter
```

DI регистрируется в `AppBindings` до `runApp`.

## Стек

| Пакет | Назначение |
| --- | --- |
| `get` | состояние, навигация, DI |
| `get_storage` | локальное хранилище (токен, роль, история) |
| `dio` / `http` | HTTP-клиент, Bearer-interceptor |
| `logger` | логирование |
| `flutter_map` + `latlong2` + `location` | карта и геолокация |
| `web_socket_channel` | статус дрона и дронбокса |
| `permission_handler` | разрешения |
| `image_picker` | фото товаров |

Версия приложения: `0.1.0` (`pubspec.yaml`). SDK: Dart `^3.6.0`.

## Запуск

Требования: Flutter SDK 3.6+, Android Studio / VS Code, Git.

```bash
git clone https://github.com/Yaroslavgiv/kollibery_mobail.git
cd kollibery_mobail
flutter pub get
flutter run
```

Сборка:

```bash
flutter build apk --release
flutter build ios --release
```

Анализ и тесты:

```bash
flutter analyze
flutter test
```

Юнит-тесты (без виджетов экранов):

- `test/core/jwt_decoder_test.dart`
- `test/domain/entities/user_role_test.dart`
- `test/domain/entities/geo_point_test.dart`
- `test/domain/services/auth_service_test.dart`
- `test/domain/services/flight_service_test.dart`

## API

Базовый URL задаётся в `lib/utils/constants/api_constants.dart`.

```
HTTP: http://81.3.182.146
WS:   ws://81.3.182.146
```

### Заказы и каталог

| Метод | Путь | Назначение |
| --- | --- | --- |
| `POST` | `/order/placeorder` | создать заказ |
| `GET` | `/order/getorders` | список заказов |
| `GET` | `/order/getproducts` | каталог |
| `GET` | `/order/getlastfiveorders` | последние заказы |
| `GET` | `/order/sseorders/{orderId}` | SSE статуса |
| `POST` | `/order/updatestatus` | обновить статус |
| `POST` | `/order/creatproduct` | создать товар |
| `POST` | `/order/deleteproduct` | удалить товар |
| `POST` | `/order/deleteorder` | удалить заказ |

### Полёт

| Метод | Путь | Назначение |
| --- | --- | --- |
| `POST` | `/flight/orderlocation` | точка посадки (buyer / seller) |

Тело заказа на сервер:

```json
{
  "userId": "string",
  "productId": 0,
  "quantity": 1,
  "deliveryLatitude": 0.0,
  "deliveryLongitude": 0.0
}
```

### WebSocket

| URL | Назначение |
| --- | --- |
| `ws://81.3.182.146/ws/status` | статус дрона |
| `ws://81.3.182.146/ws/statusdb` | статус дронбокса |

Токен хранится в GetStorage и подставляется в `ApiClient` как Bearer.

## Экраны

| Роль | Ключевые экраны |
| --- | --- |
| Общие | `LoginScreen`, `RegistrationScreen`, `ForgotPasswordScreen`, `OnboardingScreen`, `ProfileScreen` |
| Покупатель | `MainScreen`, `HomeScreen`, `CartScreen`, `DeliveryPointScreen`, `DeliveryStatusScreen`, `DeliveryCompletedScreen` |
| Продавец | `SellerMainScreen`, `SellerPickupLocationScreen`, `SellerOrderStatusScreen`, `SellerOrderCompletedScreen`, `AddEditProductScreen` |
| Техник | `TechMainScreen`, `TechPickupLocationScreen`, `TechDeliveryStatusScreen`, `TechDroneScreen`, `TechDroneboxScreen` |

Маршруты — в `lib/routes/app_routes.dart`.

## Как развивать код

1. Новая бизнес-логика — в `domain/services`, без виджетов.
2. Доступ к сети и диску — только через контракт репозитория в `domain/repositories`.
3. View получает данные и команды через GetX-менеджер (`presentation/managers` или `features/*/controllers`).
4. Комментарии — на русском.
5. Перед коммитом: `flutter analyze` и `flutter test`.
