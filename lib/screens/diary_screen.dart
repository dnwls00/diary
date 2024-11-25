import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/diary_service.dart';

class DiaryScreen extends StatefulWidget {
  final DateTime selectedDate;
  final String? initialContent;

  const DiaryScreen({
    Key? key,
    required this.selectedDate,
    this.initialContent,
  }) : super(key: key);

  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final TextEditingController _diaryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _diaryController.text = widget.initialContent ?? '';
  }

  void _showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showDeleteConfirmDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('일기 삭제'),
              content: Text('정말로 이 일기를 삭제하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('삭제'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.selectedDate.year}년 ${widget.selectedDate.month}월 ${widget.selectedDate.day}일',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _diaryController,
                decoration: InputDecoration(
                  hintText: '일기를 작성하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.initialContent != null) ...[
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await DiaryService.saveDiary(
                          DateFormat('yyyy-MM-dd').format(widget.selectedDate),
                          _diaryController.text,
                        );
                        if (mounted) {
                          _showAlert(context, '일기가 저장되었습니다');
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('저장 중 오류가 발생했습니다')),
                          );
                        }
                      }
                    },
                    child: Text('저장'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final shouldDelete =
                          await _showDeleteConfirmDialog(context);
                      if (shouldDelete) {
                        try {
                          await DiaryService.deleteDiary(
                            DateFormat('yyyy-MM-dd')
                                .format(widget.selectedDate),
                          );
                          if (mounted) {
                            _showAlert(context, '일기가 삭제되었습니다');
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('삭제 중 오류가 발생했습니다')),
                            );
                          }
                        }
                      }
                    },
                    child: Text('삭제'),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () async {
                      if (_diaryController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('일기 내용을 입력해주세요')),
                        );
                        return;
                      }
                      try {
                        await DiaryService.saveDiary(
                          DateFormat('yyyy-MM-dd').format(widget.selectedDate),
                          _diaryController.text,
                        );
                        if (mounted) {
                          _showAlert(context, '일기가 저장되었습니다');
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('저장 중 오류가 발생했습니다')),
                          );
                        }
                      }
                    },
                    child: Text('저장'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
