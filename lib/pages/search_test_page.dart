import 'package:flutter/material.dart' hide SearchBar;

import '../components/search_bar.dart';
import '../utils/app_theme.dart';

class SearchTestPage extends StatefulWidget {
  const SearchTestPage({super.key});

  @override
  State<SearchTestPage> createState() => _SearchTestPageState();
}

class _SearchTestPageState extends State<SearchTestPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text(
          'Тест строки поиска',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.colors.surface,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Интерактивная строка поиска (исправлена):',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '✅ Убрана лишняя обводка TextField\n✅ Исправлено выравнивание текста\n✅ Точные отступы как в макете',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Interactive search bar
            SearchBar(
              onSubmitted: (query) {
                setState(() {
                  _searchQuery = query;
                });
                // Убираем print для production
                // print('Поиск: $query');
              },
              onFilterPressed: () {
                // print('Кнопка фильтра нажата');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Фильтры пока не реализованы'),
                    backgroundColor: Color(0xFF388E3C),
                  ),
                );
              },
              hintText: 'Find something',
            ),

            const SizedBox(height: 30),

            Text(
              'Текущий поисковый запрос: $_searchQuery',
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
                fontFamily: 'Roboto',
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              'Состояния строки поиска из макета:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // States demonstration
            const Expanded(
              child: SingleChildScrollView(child: SearchBarDemo()),
            ),
          ],
        ),
      ),
    );
  }
}
