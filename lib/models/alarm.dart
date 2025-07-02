// models/alarm.dart

enum RepeatType {
  once,      // Une seule fois
  daily,     // Tous les jours
  weekdays,  // Jours de semaine (Lun-Ven)
  weekends,  // Week-ends (Sam-Dim)
  custom     // Jours personnalisés
}

class Alarm {
  int? id;
  final String title;
  DateTime time;
  bool isActive;
  RepeatType repeatType;
  List<int> customDays; // 1=Lundi, 2=Mardi, ..., 7=Dimanche

  Alarm({
    this.id,
    required this.title,
    required this.time,
    required this.isActive,
    this.repeatType = RepeatType.once,
    this.customDays = const [],
  });

  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
    id: json['id'],
    title: json['title'],
    time: DateTime.parse(json['time']),
    isActive: json['isActive'] == 1,
    repeatType: RepeatType.values[json['repeatType'] ?? 0],
    customDays: json['customDays'] != null
        ? (json['customDays'] as String).split(',').map((e) => int.parse(e)).toList()
        : [],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'title': title,
    'time': time.toIso8601String(),
    'isActive': isActive ? 1 : 0,
    'repeatType': repeatType.index,
    'customDays': customDays.join(','),
  };

  Alarm copyWith({
    int? id,
    String? title,
    DateTime? time,
    bool? isActive,
    RepeatType? repeatType,
    List<int>? customDays,
  }) {
    return Alarm(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
      repeatType: repeatType ?? this.repeatType,
      customDays: customDays ?? this.customDays,
    );
  }

  // Méthode pour obtenir le texte de répétition
  String get repeatText {
    switch (repeatType) {
      case RepeatType.once:
        return 'Une fois';
      case RepeatType.daily:
        return 'Tous les jours';
      case RepeatType.weekdays:
        return 'Jours de semaine';
      case RepeatType.weekends:
        return 'Week-ends';
      case RepeatType.custom:
        if (customDays.isEmpty) return 'Personnalisé';
        final dayNames = ['', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
        return customDays.map((day) => dayNames[day]).join(', ');
    }
  }

  // Vérifie si l'alarme doit sonner aujourd'hui
  bool shouldRingToday() {
    final now = DateTime.now();
    final weekday = now.weekday; // 1=Lundi, 7=Dimanche

    switch (repeatType) {
      case RepeatType.once:
        return time.day == now.day && time.month == now.month && time.year == now.year;
      case RepeatType.daily:
        return true;
      case RepeatType.weekdays:
        return weekday >= 1 && weekday <= 5; // Lundi à Vendredi
      case RepeatType.weekends:
        return weekday == 6 || weekday == 7; // Samedi et Dimanche
      case RepeatType.custom:
        return customDays.contains(weekday);
    }
  }
}