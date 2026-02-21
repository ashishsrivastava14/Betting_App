class BetOption {
  final String label;
  final double multiplier;

  BetOption({required this.label, required this.multiplier});
}

class EventModel {
  final String id;
  final String name;
  final String eventType; // 'Toss' | 'Match Winner' | 'Over Runs'
  final String team1;
  final String team2;
  final DateTime startTime;
  final DateTime betCloseTime;
  String status; // 'upcoming' | 'live' | 'closed' | 'settled'
  final List<BetOption> options;
  String? winningOption;
  bool isEnabled;

  EventModel({
    required this.id,
    required this.name,
    required this.eventType,
    required this.team1,
    required this.team2,
    required this.startTime,
    required this.betCloseTime,
    required this.status,
    required this.options,
    this.winningOption,
    this.isEnabled = true,
  });

  EventModel copyWith({
    String? id,
    String? name,
    String? eventType,
    String? team1,
    String? team2,
    DateTime? startTime,
    DateTime? betCloseTime,
    String? status,
    List<BetOption>? options,
    String? winningOption,
    bool? isEnabled,
  }) {
    return EventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      eventType: eventType ?? this.eventType,
      team1: team1 ?? this.team1,
      team2: team2 ?? this.team2,
      startTime: startTime ?? this.startTime,
      betCloseTime: betCloseTime ?? this.betCloseTime,
      status: status ?? this.status,
      options: options ?? this.options,
      winningOption: winningOption ?? this.winningOption,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
