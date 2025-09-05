import 'package:flutter/material.dart';
import '../services/top_products_service.dart';
import '../services/sessions_service.dart';
import '../services/api_service.dart';
import '../models/planner_models.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  List<LiveSession> _userSessions = [];
  List<LiveSession> _aiSuggestions = [];
  DateTime _selectedDate = DateTime.now();
  late SessionsService _sessionsService;

  @override
  void initState() {
    super.initState();
    _sessionsService = SessionsService(apiService: ApiService());
    _loadSessions();
    _generateAISuggestions();
  }

  /// Load sessions from backend/local storage
  Future<void> _loadSessions() async {
    try {
      final sessions = await _sessionsService.loadSessions();
      setState(() {
        _userSessions = sessions;
      });
    } catch (e) {
      print('[PlannerScreen] Error loading sessions: $e');
    }
  }

  /// Save sessions to backend/local storage
  Future<void> _saveSessions() async {
    try {
      await _sessionsService.saveSessions(_userSessions);
    } catch (e) {
      print('[PlannerScreen] Error saving sessions: $e');
    }
  }

  void _generateAISuggestions() {
    if (TopProductsService.hasTopProducts) {
      final topProducts = TopProductsService.userTopProducts;
      if (topProducts.isNotEmpty) {
        final mainProduct = topProducts.first;

        setState(() {
          _aiSuggestions = [
            LiveSession(
              id: 'ai_1',
              copywriting:
                  'COPY: ${mainProduct.name} ala model, murah lebih, beli sekarang!',
              host: 'HOST: Dewi',
              time: 'TIME: 19:00-21:00 WIB',
              bundle: 'BUNDLE: ${mainProduct.name} + Bonus Item (diskon 10%)',
              isAISuggestion: true,
            ),
            LiveSession(
              id: 'ai_2',
              copywriting:
                  'COPY: Flash sale ${mainProduct.name}, stock terbatas!',
              host: 'HOST: Sarah',
              time: 'TIME: 20:00-22:00 WIB',
              bundle: 'BUNDLE: ${mainProduct.name} x2 + Free Shipping',
              isAISuggestion: true,
            ),
          ];
        });
      }
    }
  }

  // Get sessions for selected date only
  List<LiveSession> get _sessionsForSelectedDate {
    return _userSessions.where((session) {
      if (session.scheduledDate == null) return false;
      final sessionDate = session.scheduledDate!;
      return sessionDate.year == _selectedDate.year &&
             sessionDate.month == _selectedDate.month &&
             sessionDate.day == _selectedDate.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Planner',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Calendar Widget
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Calendar Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: () {
                          setState(() {
                            _selectedDate = DateTime(
                              _selectedDate.year,
                              _selectedDate.month - 1,
                              1,
                            );
                          });
                        },
                      ),
                      Text(
                        _getMonthYearString(_selectedDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: () {
                          setState(() {
                            _selectedDate = DateTime(
                              _selectedDate.year,
                              _selectedDate.month + 1,
                              1,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Calendar Grid
                  _buildCalendarGrid(),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Upcoming Sessions Section
            if (_userSessions.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Upcoming Sessions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // User Session Cards for selected date
              ..._sessionsForSelectedDate.map(
                (session) => Column(
                  children: [
                    _buildUserSessionCard(session),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Show message if no sessions for selected date
              if (_sessionsForSelectedDate.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tidak ada session untuk ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}. Tap "+" untuk menambah session baru.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),
            ],

            // AI Suggestions Section
            if (_aiSuggestions.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'AI Suggestions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // AI Suggestion Cards
              ..._aiSuggestions.map(
                (session) => Column(
                  children: [
                    _buildAISuggestionCard(session),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ] else ...[
              // No suggestions when no products
              _buildNoSuggestionsCard(),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSessionDialog,
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Plan New Session',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildCalendarGrid() {
    // Get the first day of current month and calculate calendar layout
    final firstDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday =
        firstDayOfMonth.weekday % 7; // Sunday = 0, Monday = 1, etc.
    final today = DateTime.now();
    final isCurrentMonth =
        _selectedDate.year == today.year && _selectedDate.month == today.month;

    return Column(
      children: [
        // Days of week header
        Row(
          children:
              ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 8),

        // Calendar grid
        ...List.generate(6, (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final dayNumber = (weekIndex * 7 + dayIndex) - firstWeekday + 1;
              final isValidDay = dayNumber >= 1 && dayNumber <= daysInMonth;
              final isToday =
                  isCurrentMonth && isValidDay && dayNumber == today.day;
              final isSelected = dayNumber == _selectedDate.day && isValidDay;

              return Expanded(
                child: GestureDetector(
                  onTap:
                      isValidDay
                          ? () {
                            setState(() {
                              _selectedDate = DateTime(
                                _selectedDate.year,
                                _selectedDate.month,
                                dayNumber,
                              );
                            });
                          }
                          : null,
                  child: Container(
                    height: 36,
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF3B82F6)
                              : isToday
                              ? const Color(0xFF3B82F6).withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border:
                          isToday && !isSelected
                              ? Border.all(
                                color: const Color(0xFF3B82F6),
                                width: 1,
                              )
                              : null,
                    ),
                    child: Center(
                      child: Text(
                        isValidDay ? dayNumber.toString() : '',
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : isToday
                                  ? const Color(0xFF3B82F6)
                                  : isValidDay
                                  ? Colors.black87
                                  : Colors.transparent,
                          fontWeight:
                              (isSelected || isToday)
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  Widget _buildUserSessionCard(LiveSession session) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.play_circle_rounded,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.copywriting,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.time,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _deleteSession(session.id),
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildAISuggestionCard(LiveSession session) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'AI Suggestion',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
              Tooltip(
                message: 'Schedule this suggestion',
                child: IconButton(
                  onPressed: () => _adoptAISuggestion(session),
                  icon: const Icon(
                    Icons.schedule,
                    color: Color(0xFF3B82F6),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            session.copywriting,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            session.time,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            session.bundle,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSuggestionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.lightbulb_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No AI Suggestions Available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your top 3 products first to get AI-powered live session suggestions',
            style: TextStyle(fontSize: 14, color: Colors.black45),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddSessionDialog() {
    final titleController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Plan New Session',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Session Title',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time (e.g., 19:00-21:00 WIB)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty &&
                      timeController.text.isNotEmpty) {
                    _addNewSession(titleController.text, timeController.text);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _addNewSession(String title, String time) {
    final newSession = LiveSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      copywriting: title,
      host: 'HOST: You',
      time: 'TIME: $time',
      bundle: 'BUNDLE: Manual Session',
      scheduledDate: _selectedDate,
    );

    setState(() {
      _userSessions.add(newSession);
    });

    // Save to backend/local storage
    _saveSessions();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _adoptAISuggestion(LiveSession suggestion) async {
    // Show date picker for user to choose when to schedule
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return; // User cancelled

    // Use original time from AI suggestion
    final DateTime scheduledDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      19, // Default time 19:00 (7 PM) - good time for live streaming
      0,
    );

    final adoptedSession = LiveSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      copywriting: suggestion.copywriting,
      host: suggestion.host,
      time: suggestion.time, // Use original time from suggestion
      bundle: suggestion.bundle,
      scheduledDate: scheduledDateTime,
    );

    setState(() {
      _userSessions.add(adoptedSession);
    });

    // Save to backend/local storage
    _saveSessions();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'AI suggestion scheduled for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year} at ${suggestion.time}!',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteSession(String sessionId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Session'),
            content: const Text(
              'Are you sure you want to delete this session?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _userSessions.removeWhere(
                      (session) => session.id == sessionId,
                    );
                  });
                  
                  // Save to backend/local storage
                  _saveSessions();
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Session deleted successfully!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
