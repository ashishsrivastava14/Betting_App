import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../mock_data/mock_events.dart';

class EventProvider extends ChangeNotifier {
  final List<EventModel> _events = List.from(mockEvents);

  List<EventModel> get events => _events;

  List<EventModel> get allEvents => _events.where((e) => e.isEnabled).toList();
  List<EventModel> get liveEvents =>
      _events.where((e) => e.status == 'live' && e.isEnabled).toList();
  List<EventModel> get upcomingEvents =>
      _events.where((e) => e.status == 'upcoming' && e.isEnabled).toList();
  List<EventModel> get settledEvents =>
      _events.where((e) => e.status == 'settled' && e.isEnabled).toList();
  List<EventModel> get closedEvents =>
      _events.where((e) => e.status == 'closed' && e.isEnabled).toList();

  // Admin: all events regardless of enabled
  List<EventModel> get adminAllEvents => _events;

  EventModel? getEventById(String id) {
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  void addEvent(EventModel event) {
    _events.add(event);
    notifyListeners();
  }

  void updateEvent(EventModel updated) {
    final idx = _events.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _events[idx] = updated;
      notifyListeners();
    }
  }

  void toggleEventEnabled(String eventId) {
    final event = getEventById(eventId);
    if (event != null) {
      event.isEnabled = !event.isEnabled;
      notifyListeners();
    }
  }

  void declareResult(String eventId, String winningOption) {
    final event = getEventById(eventId);
    if (event != null) {
      event.status = 'settled';
      event.winningOption = winningOption;
      notifyListeners();
    }
  }

  void refresh() {
    notifyListeners();
  }
}
