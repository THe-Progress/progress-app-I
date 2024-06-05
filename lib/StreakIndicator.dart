import 'package:flutter/material.dart';

class StreakIndicator extends StatefulWidget {
  @override
  _StreakIndicatorState createState() => _StreakIndicatorState();
}

class _StreakIndicatorState extends State<StreakIndicator> {
  int currentStreak = 1; // streak value from the user's activity
  bool isTodayStreakDay = true; // depends on the user's activity
  List<String> weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  List<String> _getOrderedWeekdays() {
    int todayIndex = (DateTime.now().weekday) % 7;
    List<String> orderedWeekdays = List.from(weekdays);
    return orderedWeekdays.sublist(todayIndex)
      ..addAll(orderedWeekdays.sublist(0, todayIndex));
  }

  @override
  Widget build(BuildContext context) {
    List<String> orderedWeekdays = _getOrderedWeekdays();
    orderedWeekdays = orderedWeekdays.skip(2).toList();
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$currentStreak days',
              style: TextStyle(
                color: Colors.red[900],
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                orderedWeekdays.length,
                (index) {
                  bool isStreakDay;
                  if (index == 4) {
                    isStreakDay = isTodayStreakDay;
                  } else if ((index + currentStreak) >=
                      4 + (isTodayStreakDay ? 1 : 0)) {
                    isStreakDay = true;
                  } else {
                    isStreakDay = false;
                  }
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isStreakDay ? Colors.red[900] : Colors.red[100],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isStreakDay ? Colors.red[900]! : Colors.red[100]!,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        orderedWeekdays[index],
                        style: TextStyle(
                          color: isStreakDay ? Colors.white : Colors.red[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
