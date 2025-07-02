class Alarm {
  final int id;
  final String title;
  late final DateTime time;
  bool isActive; // Suppression de 'late' et 'final'

  Alarm({
    required this.id,
    required this.title,
    required this.time,
    required this.isActive,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
    id: json['id'],
    title: json['title'],
    time: DateTime.parse(json['time']),
    isActive: json['isActive'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'time': time.toIso8601String(),
    'isActive': isActive,
  };
}