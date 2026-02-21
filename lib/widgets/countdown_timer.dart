import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/app_utils.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime targetTime;
  final TextStyle? style;
  final String? prefix;

  const CountdownTimerWidget({
    super.key,
    required this.targetTime,
    this.style,
    this.prefix,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  Timer? _timer;
  String _countdown = '';

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    if (!mounted) return;
    setState(() {
      _countdown = AppUtils.getCountdown(widget.targetTime);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = widget.targetTime.isBefore(DateTime.now());
    return Text(
      '${widget.prefix ?? ''}$_countdown',
      style: widget.style ??
          GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isExpired ? AppColors.red : AppColors.accent,
          ),
    );
  }
}
