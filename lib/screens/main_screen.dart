import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/diary_service.dart';
import 'login_screen.dart';
import 'diary_screen.dart';
import 'diary_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedDiaryContent;
  Set<String> _diaryDates = {};

  void _checkAuthState() {
    if (AuthService.token == null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    _selectedDay = _focusedDay;
    _loadDiaryContent();
    _loadDiaryDates();
  }

  Future<void> _loadDiaryContent() async {
    if (_selectedDay != null) {
      try {
        final diary = await DiaryService.getDiary(
            DateFormat('yyyy-MM-dd').format(_selectedDay!));

        if (!mounted) return;

        setState(() {
          _selectedDiaryContent = diary?.content;
        });
      } catch (e) {
        print('Error loading diary content: $e');
        if (!mounted) return;
        setState(() {
          _selectedDiaryContent = null;
        });
      }
    }
  }

  Future<void> _loadDiaryDates() async {
    try {
      final diaries = await DiaryService.getDiaries();
      setState(() {
        _diaryDates = diaries.map((d) => d.date).toSet();
      });
    } catch (e) {
      print('Error loading diary dates: $e');
    }
  }

  Future<DateTime?> _showYearMonthPicker(
      BuildContext context, DateTime initialDate) {
    int selectedYear = initialDate.year;
    int selectedMonth = initialDate.month;

    return showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('날짜 선택'),
          content: Container(
            height: 200,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('년도'),
                    DropdownButton<int>(
                      value: selectedYear,
                      items: List.generate(11, (index) => 2020 + index)
                          .map((year) => DropdownMenuItem(
                                value: year,
                                child: Text('$year년'),
                              ))
                          .toList(),
                      onChanged: (int? value) {
                        if (value != null) {
                          selectedYear = value;
                          (context as Element).markNeedsBuild();
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('월'),
                    DropdownButton<int>(
                      value: selectedMonth,
                      items: List.generate(12, (index) => index + 1)
                          .map((month) => DropdownMenuItem(
                                value: month,
                                child: Text('$month월'),
                              ))
                          .toList(),
                      onChanged: (int? value) {
                        if (value != null) {
                          selectedMonth = value;
                          (context as Element).markNeedsBuild();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, DateTime(selectedYear, selectedMonth)),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primaryContainer,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: Text(
                      AuthService.email?.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AuthService.email?.split('@')[0] ?? '사용자',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.book_outlined,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('일기 목록'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DiaryListScreen(),
                  ),
                );
                setState(() {
                  _selectedDiaryContent = null;
                  _diaryDates = {};
                });
                await _loadDiaryDates();
                await _loadDiaryContent();
              },
            ),
            ListTile(
              leading: Icon(Icons.analytics_outlined,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('감정 분석 결과'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout_outlined,
                  color: Theme.of(context).colorScheme.error),
              title: Text('로그아웃',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () async {
                await AuthService.logout();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          '캘린더',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            locale: 'ko_KR',
            headerVisible: true,
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              leftChevronIcon: Icon(Icons.chevron_left),
              rightChevronIcon: Icon(Icons.chevron_right),
              titleTextStyle: TextStyle(fontSize: 17.0),
              headerPadding: EdgeInsets.symmetric(vertical: 12),
              rightChevronMargin: EdgeInsets.zero,
              leftChevronMargin: EdgeInsets.zero,
            ),
            calendarBuilders: CalendarBuilders(
              headerTitleBuilder: (context, day) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${day.year}년 ${day.month}월',
                      style: TextStyle(fontSize: 17.0),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_drop_down),
                      onPressed: () async {
                        final DateTime? picked = await _showYearMonthPicker(
                          context,
                          day,
                        );
                        if (picked != null) {
                          setState(() {
                            _focusedDay = picked;
                            _selectedDay = picked;
                          });
                          _loadDiaryContent();
                        }
                      },
                    ),
                  ],
                );
              },
              markerBuilder: (context, date, events) {
                final dateString = DateFormat('yyyy-MM-dd').format(date);
                if (_diaryDates.contains(dateString)) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      width: 6.0,
                      height: 6.0,
                    ),
                  );
                }
                return null;
              },
            ),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            onDaySelected: (selectedDay, focusedDay) async {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });

              try {
                final diary = await DiaryService.getDiary(
                  DateFormat('yyyy-MM-dd').format(selectedDay),
                );

                if (mounted) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryScreen(
                        selectedDate: selectedDay,
                        initialContent: diary?.content,
                      ),
                    ),
                  );

                  if (result == true) {
                    setState(() {
                      _selectedDiaryContent = null;
                      _diaryDates = {};
                    });

                    await _loadDiaryDates();
                    await _loadDiaryContent();

                    if (mounted) {
                      setState(() {});
                    }
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('오류가 발생했습니다: $e')),
                  );
                }
                print('Error: $e');
              }
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
