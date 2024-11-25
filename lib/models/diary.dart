class Diary {
  final int id;
  final String title;
  final String body;
  final String createdAt;

  Diary({required this.id, required this.title, required this.body, required this.createdAt});

  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
    };
  }
}
