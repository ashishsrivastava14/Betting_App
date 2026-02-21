import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';

class AdminCreateEventScreen extends StatefulWidget {
  const AdminCreateEventScreen({super.key});

  @override
  State<AdminCreateEventScreen> createState() => _AdminCreateEventScreenState();
}

class _AdminCreateEventScreenState extends State<AdminCreateEventScreen> {
  final _nameController = TextEditingController();
  final _team1Controller = TextEditingController();
  final _team2Controller = TextEditingController();
  String _eventType = 'Match Winner';
  DateTime _startTime = DateTime.now().add(const Duration(hours: 6));
  DateTime _betCloseTime = DateTime.now().add(const Duration(hours: 5, minutes: 30));

  final List<Map<String, dynamic>> _options = [
    {'label': '', 'multiplier': 1.90},
    {'label': '', 'multiplier': 1.90},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _team1Controller.dispose();
    _team2Controller.dispose();
    super.dispose();
  }

  void _addOption() {
    setState(() { _options.add({'label': '', 'multiplier': 1.90}); });
  }

  void _removeOption(int index) {
    if (_options.length > 2) setState(() { _options.removeAt(index); });
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startTime : _betCloseTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(primary: AppColors.accent, surface: AppColors.card),
          ),
          child: child!,
        );
      },
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startTime : _betCloseTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(primary: AppColors.accent, surface: AppColors.card),
          ),
          child: child!,
        );
      },
    );
    if (time == null) return;
    final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() { if (isStart) { _startTime = dateTime; } else { _betCloseTime = dateTime; } });
  }

  void _saveEvent() {
    if (_nameController.text.trim().isEmpty || _team1Controller.text.trim().isEmpty || _team2Controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
      return;
    }
    final betOptions = <BetOption>[];
    for (var opt in _options) {
      if ((opt['label'] as String).trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all option labels')));
        return;
      }
      betOptions.add(BetOption(label: (opt['label'] as String).trim(), multiplier: (opt['multiplier'] as double)));
    }
    final event = EventModel(
      id: AppUtils.generateId('EVT'),
      name: _nameController.text.trim(),
      eventType: _eventType,
      team1: _team1Controller.text.trim(),
      team2: _team2Controller.text.trim(),
      startTime: _startTime,
      betCloseTime: _betCloseTime,
      status: 'upcoming',
      options: betOptions,
    );
    context.read<EventProvider>().addEvent(event);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event created successfully!'), backgroundColor: AppColors.green));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: AppColors.card, border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(Icons.arrow_back, size: 18),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Event Name'),
            TextFormField(
              controller: _nameController,
              style: GoogleFonts.poppins(color: AppColors.white),
              decoration: const InputDecoration(hintText: 'e.g. IND vs AUS - 3rd ODI', prefixIcon: Icon(Icons.event)),
            ),
            const SizedBox(height: 16),
            _label('Event Type'),
            DropdownButtonFormField<String>(
              initialValue: _eventType,
              dropdownColor: AppColors.card,
              style: GoogleFonts.poppins(color: AppColors.white),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.category)),
              items: ['Match Winner', 'Toss', 'Over Runs'].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (v) => setState(() => _eventType = v!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label('Team 1'),
                  TextFormField(controller: _team1Controller, style: GoogleFonts.poppins(color: AppColors.white),
                    decoration: const InputDecoration(hintText: 'e.g. India', prefixIcon: Icon(Icons.groups))),
                ])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label('Team 2'),
                  TextFormField(controller: _team2Controller, style: GoogleFonts.poppins(color: AppColors.white),
                    decoration: const InputDecoration(hintText: 'e.g. Australia', prefixIcon: Icon(Icons.groups))),
                ])),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label('Start Time'),
                  GestureDetector(
                    onTap: () => _pickDateTime(true),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
                      child: Row(children: [
                        const Icon(Icons.schedule, color: AppColors.accent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(AppUtils.formatDateShort(_startTime), style: GoogleFonts.poppins(fontSize: 12, color: AppColors.white))),
                      ]),
                    ),
                  ),
                ])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label('Bet Close Time'),
                  GestureDetector(
                    onTap: () => _pickDateTime(false),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
                      child: Row(children: [
                        const Icon(Icons.timer_off, color: AppColors.accent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(AppUtils.formatDateShort(_betCloseTime), style: GoogleFonts.poppins(fontSize: 12, color: AppColors.white))),
                      ]),
                    ),
                  ),
                ])),
              ],
            ),
            const SizedBox(height: 24),
            Row(children: [
              _label('Betting Options'),
              const Spacer(),
              TextButton.icon(onPressed: _addOption, icon: const Icon(Icons.add, size: 16), label: Text('Add', style: GoogleFonts.poppins(fontSize: 12))),
            ]),
            const SizedBox(height: 8),
            ...List.generate(_options.length, (i) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
                child: Row(children: [
                  Expanded(flex: 2, child: TextFormField(
                    initialValue: _options[i]['label'],
                    style: GoogleFonts.poppins(color: AppColors.white, fontSize: 13),
                    decoration: InputDecoration(hintText: 'Label (e.g. India)', isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), fillColor: AppColors.cardLight),
                    onChanged: (v) => _options[i]['label'] = v,
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(
                    initialValue: _options[i]['multiplier'].toString(),
                    style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 13),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: 'Odds', isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), fillColor: AppColors.cardLight, suffixText: 'x'),
                    onChanged: (v) => _options[i]['multiplier'] = double.tryParse(v) ?? 1.0,
                  )),
                  if (_options.length > 2)
                    IconButton(icon: const Icon(Icons.remove_circle, color: AppColors.red, size: 20), onPressed: () => _removeOption(i)),
                ]),
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saveEvent,
                icon: const Icon(Icons.check_circle, size: 20),
                label: Text('CREATE EVENT', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
    );
  }
}