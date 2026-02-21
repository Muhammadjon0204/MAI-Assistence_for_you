// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mai_app/models/math_problem.dart';
import 'package:mai_app/services/auth_service.dart';
import 'package:mai_app/services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  final TextEditingController _searchController = TextEditingController();
  List<MathSolution> _allHistory = [];
  List<MathSolution> _filteredHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadUserName();
  }

  Future<void> _loadHistory() async {
    final history = await _historyService.getHistory();
    setState(() {
      _allHistory = history.cast<MathSolution>();
      _filteredHistory = history.cast<MathSolution>();
      _isLoading = false;
    });
  }

  Future<void> _loadUserName() async {
    final user = await AuthService().getCurrentUser();
    if (user != null) {
      setState(() {});
    }
  }

  void _filterHistory(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredHistory = _allHistory;
      });
      return;
    }

    setState(() {
      _filteredHistory = _allHistory.where((item) {
        return item.problem.toLowerCase().contains(query.toLowerCase()) ||
            item.solution.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFCC785C)))
          : _filteredHistory.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1a1a1a),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'История',
        style: GoogleFonts.sourceSerif4(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2d2d2d),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: _filterHistory,
              decoration: InputDecoration(
                hintText: 'Поиск по истории...',
                // ignore: deprecated_member_use
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                filled: false,
                fillColor: Colors.transparent,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                prefixIcon:
                    Icon(Icons.search, color: Colors.white.withOpacity(0.4)),
                border: InputBorder.none,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: Colors.white.withOpacity(0.4)),
                        onPressed: () {
                          _searchController.clear();
                          _filterHistory('');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF2d2d2d),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              _searchController.text.isNotEmpty
                  ? Icons.search_off
                  : Icons.history,
              size: 40,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchController.text.isNotEmpty
                ? 'Ничего не найдено'
                : 'История пуста',
            style: GoogleFonts.sourceSerif4(
              fontSize: 24,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Попробуйте другой запрос'
                : 'Начните решать задачи',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    // Группируем по датам
    Map<String, List<MathSolution>> grouped = {};
    for (var item in _filteredHistory) {
      final date = _formatDate(item.timestamp);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final dateKey = grouped.keys.elementAt(index);
        final items = grouped[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок даты
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 8, bottom: 12),
              child: Text(
                dateKey,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white54,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Карточки чатов
            ...items.map((item) => _buildHistoryCard(item)),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildHistoryCard(MathSolution item) {
    return Dismissible(
      key: Key(item.timestamp.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (direction) async {
        await _historyService.deleteItem(item.timestamp);
        _loadHistory();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Удалено'),
            backgroundColor: const Color(0xFF2d2d2d),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          // TODO: Открыть чат с этой задачей
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2d2d2d),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Задача
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCC785C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.calculate,
                      size: 16,
                      color: Color(0xFFCC785C),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.problem,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Время
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 12,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(item.timestamp),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return 'Сегодня';
    } else if (itemDate == yesterday) {
      return 'Вчера';
    } else if (now.difference(date).inDays < 7) {
      const weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
      return weekdays[date.weekday - 1];
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
