// Константы для цветов приложения
class AppColors {
  static const int primaryBackground = 0xFF1F2937;
  static const int cardBackground = 0xFF181F2A;
  static const int border = 0xFF374151;
  static const int accent = 0xFF388E3C;
  static const int warning = 0xFFF59E0B;
  static const int textPrimary = 0xFFFFFFFF;
  static const int textSecondary = 0xFFD1D5DB;
  static const int textMuted = 0xFF9CA3AF;
  static const int placeholder = 0xBF9B9B9B;
}

// Константы для размеров
class AppSizes {
  static const double cardHeight = 134.0;
  static const double appBarHeight = 83.0;
  static const double bottomNavHeight = 69.0;
  static const double borderRadius = 16.0;
  static const double tagBorderRadius = 12.0;
  static const double spacing = 10.0;
  static const double paddingSmall = 6.0;
  static const double paddingMedium = 10.0;
  static const double paddingLarge = 20.0;
}

// Константы для текстовых стилей
class AppTextStyles {
  static const String primaryFont = 'Roboto';
  static const String secondaryFont = 'Inter';
  
  static const double headingLarge = 20.0;
  static const double headingMedium = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
  static const double caption = 10.0;
  static const double tiny = 9.0;
}

// Константы для анимаций
class AppAnimations {
  static const int fastDuration = 200;
  static const int normalDuration = 300;
  static const int slowDuration = 500;
}

// Ключи для навигации
class AppRoutes {
  static const String home = '/';
  static const String comments = '/comments';
  static const String bookmarks = '/bookmarks';
  static const String profile = '/profile';
  static const String modDetails = '/mod-details';
}

// Константы для API
class ApiConstants {
  static const int defaultLimit = 20;
  static const int maxRetries = 3;
  static const int timeoutSeconds = 30;
  
  static const String periodAllTime = 'all_time';
  static const String periodMonth = 'month';
  static const String periodWeek = 'week';
  static const String periodRecent = 'recent';
}

// Локализация текстов
class AppStrings {
  static const String appTitle = 'ESCLIENT Mobile';
  static const String searchMods = 'Поиск модов';
  static const String searchHint = 'Введите название или описание мода...';
  static const String topForPeriod = 'Топ за период';
  static const String modsList = 'Список модов';
  static const String searchResults = 'Результаты поиска';
  static const String noModsFound = 'Моды не найдены';
  static const String noSearchResults = 'По запросу ничего не найдено';
  static const String showAllMods = 'Показать все моды';
  static const String description = 'Описание:';
  static const String author = 'Автор:';
  static const String downloads = 'загрузок';
  static const String downloadMod = 'Скачать мод';
  static const String downloadStarted = 'началось';
  static const String downloading = 'Скачивание';
  static const String loadingError = 'Ошибка загрузки модов:';
  
  // Навигация
  static const String navHome = 'Главная';
  static const String navBookmarks = 'Закладки';
  static const String navProfile = 'Профиль';
  static const String navComments = 'Комментарии';
  
  // Периоды
  static const String periodAllTime = 'За всё время';
  static const String periodMonth = 'За месяц';
  static const String periodWeek = 'За неделю';
  static const String periodRecent = 'Недавние';
  
  // Действия
  static const String search = 'Поиск';
  static const String clear = 'Очистить';
  static const String cancel = 'Отмена';
  static const String ok = 'OK';
  
  // Сообщения
  static const String filtersNotImplemented = 'Фильтры пока не реализованы';
  static const String notificationsNotImplemented = 'Уведомления пока не реализованы';
  static const String bookmarksNotImplemented = 'Закладки пока не реализованы';
}
