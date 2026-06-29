import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import '../../../models/homepage_model.dart';

class KathaCalendarView extends StatefulWidget {
  final List<UpcomingKatha> kathas;
  const KathaCalendarView({super.key, required this.kathas});

  @override
  State<KathaCalendarView> createState() => _KathaCalendarViewState();
}

class _KathaCalendarViewState extends State<KathaCalendarView> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(20),
        color: const Color(0xFFFDF9F6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_focusedDay),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => setState(
                        () => _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month - 1,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => setState(
                        () => _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month + 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              headerVisible: false,
              daysOfWeekHeight: 40,
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
                weekendStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) =>
                    _buildDayCell(day),
                outsideBuilder: (context, day, focusedDay) =>
                    _buildDayCell(day, isOutside: true),
                todayBuilder: (context, day, focusedDay) =>
                    _buildDayCell(day, isToday: true),
              ),
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day, {
    bool isOutside = false,
    bool isToday = false,
  }) {
    // Check if this day falls within any katha range
    UpcomingKatha? activeKatha;
    for (var katha in widget.kathas) {
      if (katha.startDate != null && katha.endDate != null) {
        if (day.isAfter(
              katha.startDate!.subtract(const Duration(seconds: 1)),
            ) &&
            day.isBefore(katha.endDate!.add(const Duration(days: 1)))) {
          activeKatha = katha;
          break;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        color: isOutside ? const Color(0xFFF9F9F9) : Colors.white,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 5,
            right: 5,
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: isOutside
                    ? Colors.grey[300]
                    : (isToday ? Colors.brown : Colors.grey[600]),
                fontSize: 12,
              ),
            ),
          ),
          if (activeKatha != null)
            Positioned(
              bottom: 5,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showKathaDetail(activeKatha!),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC19A6B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    'Katha ${activeKatha.kathaNumber} - ${activeKatha.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          if (isToday)
            Center(
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.brown, width: 1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showKathaDetail(UpcomingKatha katha) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  IconButton(
                    icon: const Icon(Icons.close_outlined, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                'Katha ${katha.kathaNumber} - ${katha.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF444444),
                ),
              ),
              const Center(
                child: SizedBox(
                  width: 40,
                  child: Divider(color: Colors.brown, thickness: 2),
                ),
              ),
              const SizedBox(height: 20),
              _detailRow(
                'Starts',
                katha.startDate != null
                    ? DateFormat('M/d/yyyy, hh:mm a').format(katha.startDate!)
                    : '-',
              ),
              _detailRow(
                'Ends',
                katha.endDate != null
                    ? DateFormat('M/d/yyyy, hh:mm a').format(katha.endDate!)
                    : '-',
              ),
              const Center(
                child: SizedBox(
                  width: 40,
                  child: Divider(color: Colors.brown, thickness: 2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'View Katha  ',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      final Event event = Event(
                        title: 'Katha ${katha.kathaNumber} - ${katha.name}',
                        description: 'Ram Katha by Pu. Jigneshdada',
                        location: katha.name,
                        startDate: katha.startDate ?? DateTime.now(),
                        endDate:
                            katha.endDate ??
                            DateTime.now().add(const Duration(hours: 2)),
                      );
                      Add2Calendar.addEvent2Cal(event);
                    },
                    child: const Text(
                      'Add to your calendar',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.brown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
