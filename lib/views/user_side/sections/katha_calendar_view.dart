import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../models/homepage_model.dart';

class KathaCalendarView extends StatefulWidget {
  final List<UpcomingKatha> kathas;
  const KathaCalendarView({super.key, required this.kathas});

  @override
  State<KathaCalendarView> createState() => _KathaCalendarViewState();
}

class _KathaCalendarViewState extends State<KathaCalendarView> {
  DateTime _focusedDay = DateTime.now();
  final Color accentGold = const Color(0xFFC89A5B);
  final Color primaryTeal = const Color(0xFF0F4C5C);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_focusedDay).toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryTeal,
                    letterSpacing: 1,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              headerVisible: true,
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: primaryTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: primaryTeal,
                  fontWeight: FontWeight.bold,
                ),
                markerDecoration: BoxDecoration(
                  color: accentGold,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return _buildDayCell(day, isKatha: _isKathaDay(day));
                },
                todayBuilder: (context, day, focusedDay) {
                  return _buildDayCell(day, isToday: true, isKatha: _isKathaDay(day));
                },
              ),
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _legendItem(accentGold, "Scheduled Katha"),
                const SizedBox(width: 20),
                _legendItem(primaryTeal.withOpacity(0.2), "Today"),
              ],
            )
          ],
        ),
      ),
    );
  }

  bool _isKathaDay(DateTime day) {
    for (var katha in widget.kathas) {
      if (katha.startDate != null && katha.endDate != null) {
        // Simple date check
        final d = DateTime(day.year, day.month, day.day);
        final s = DateTime(katha.startDate!.year, katha.startDate!.month, katha.startDate!.day);
        final e = DateTime(katha.endDate!.year, katha.endDate!.month, katha.endDate!.day);
        
        if ((d.isAtSameMomentAs(s) || d.isAfter(s)) && (d.isAtSameMomentAs(e) || d.isBefore(e))) {
          return true;
        }
      }
    }
    return false;
  }

  Widget _buildDayCell(DateTime day, {bool isToday = false, bool isKatha = false}) {
    return Center(
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isKatha ? accentGold : (isToday ? primaryTeal.withOpacity(0.1) : null),
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: isKatha ? Colors.white : (isToday ? primaryTeal : Colors.black87),
              fontWeight: (isToday || isKatha) ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
