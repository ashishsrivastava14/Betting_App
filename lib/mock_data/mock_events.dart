import '../models/event_model.dart';

final List<EventModel> mockEvents = [
  // ── Upcoming Events ──
  EventModel(
    id: 'EVT001',
    name: 'IND vs AUS - 3rd ODI',
    eventType: 'Match Winner',
    team1: 'India',
    team2: 'Australia',
    startTime: DateTime.now().add(const Duration(hours: 6)),
    betCloseTime: DateTime.now().add(const Duration(hours: 5, minutes: 30)),
    status: 'upcoming',
    options: [
      BetOption(label: 'India', multiplier: 1.85),
      BetOption(label: 'Australia', multiplier: 2.10),
      BetOption(label: 'Draw', multiplier: 5.50),
    ],
  ),
  EventModel(
    id: 'EVT002',
    name: 'CSK vs MI - IPL Qualifier',
    eventType: 'Toss',
    team1: 'CSK',
    team2: 'MI',
    startTime: DateTime.now().add(const Duration(hours: 24)),
    betCloseTime: DateTime.now().add(const Duration(hours: 23, minutes: 30)),
    status: 'upcoming',
    options: [
      BetOption(label: 'CSK', multiplier: 1.90),
      BetOption(label: 'MI', multiplier: 1.90),
    ],
  ),

  // ── Live Events ──
  EventModel(
    id: 'EVT003',
    name: 'RCB vs KKR - IPL Match 42',
    eventType: 'Match Winner',
    team1: 'RCB',
    team2: 'KKR',
    startTime: DateTime.now().subtract(const Duration(hours: 1)),
    betCloseTime: DateTime.now().add(const Duration(minutes: 30)),
    status: 'live',
    options: [
      BetOption(label: 'RCB', multiplier: 1.90),
      BetOption(label: 'KKR', multiplier: 1.90),
    ],
  ),
  EventModel(
    id: 'EVT004',
    name: 'DC vs RR - Over Runs',
    eventType: 'Over Runs',
    team1: 'DC',
    team2: 'RR',
    startTime: DateTime.now().subtract(const Duration(hours: 2)),
    betCloseTime: DateTime.now().add(const Duration(minutes: 15)),
    status: 'live',
    options: [
      BetOption(label: 'Over 160.5', multiplier: 1.95),
      BetOption(label: 'Under 160.5', multiplier: 1.85),
    ],
  ),
  EventModel(
    id: 'EVT007',
    name: 'GT vs LSG - IPL Match 47',
    eventType: 'Match Winner',
    team1: 'GT',
    team2: 'LSG',
    startTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    betCloseTime: DateTime.now().add(const Duration(minutes: 45)),
    status: 'live',
    options: [
      BetOption(label: 'GT', multiplier: 1.80),
      BetOption(label: 'LSG', multiplier: 2.05),
    ],
  ),
  EventModel(
    id: 'EVT008',
    name: 'PAK vs NZ - 1st Test',
    eventType: 'Top Batsman',
    team1: 'Pakistan',
    team2: 'New Zealand',
    startTime: DateTime.now().subtract(const Duration(hours: 3)),
    betCloseTime: DateTime.now().add(const Duration(hours: 1)),
    status: 'live',
    options: [
      BetOption(label: 'Babar Azam', multiplier: 2.50),
      BetOption(label: 'Kane Williamson', multiplier: 2.80),
      BetOption(label: 'Mohammad Rizwan', multiplier: 3.20),
    ],
  ),
  EventModel(
    id: 'EVT009',
    name: 'MI vs PBKS - First 6 Overs Runs',
    eventType: 'Over Runs',
    team1: 'MI',
    team2: 'PBKS',
    startTime: DateTime.now().subtract(const Duration(minutes: 45)),
    betCloseTime: DateTime.now().add(const Duration(minutes: 20)),
    status: 'live',
    options: [
      BetOption(label: 'Over 52.5', multiplier: 1.90),
      BetOption(label: 'Under 52.5', multiplier: 1.90),
    ],
  ),

  // ── Settled Events ──
  EventModel(
    id: 'EVT005',
    name: 'IND vs ENG - 2nd T20I',
    eventType: 'Match Winner',
    team1: 'India',
    team2: 'England',
    startTime: DateTime.now().subtract(const Duration(days: 1)),
    betCloseTime: DateTime.now().subtract(const Duration(days: 1, hours: 0, minutes: 30)),
    status: 'settled',
    options: [
      BetOption(label: 'India', multiplier: 1.65),
      BetOption(label: 'England', multiplier: 2.40),
    ],
    winningOption: 'India',
  ),
  EventModel(
    id: 'EVT006',
    name: 'SRH vs PBKS - IPL Match 38',
    eventType: 'Toss',
    team1: 'SRH',
    team2: 'PBKS',
    startTime: DateTime.now().subtract(const Duration(days: 2)),
    betCloseTime: DateTime.now().subtract(const Duration(days: 2, hours: 0, minutes: 30)),
    status: 'settled',
    options: [
      BetOption(label: 'SRH', multiplier: 1.90),
      BetOption(label: 'PBKS', multiplier: 1.90),
    ],
    winningOption: 'SRH',
  ),
];
