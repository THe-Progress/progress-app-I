import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:usage_stats/usage_stats.dart';

class AppListItem extends StatelessWidget {
  final Application app;
  final UsageInfo? usageInfo;
  final bool isFavourite;
  final ValueChanged<String> onFavouriteToggle;

  const AppListItem({
    super.key,
    required this.app,
    this.usageInfo,
    required this.isFavourite,
    required this.onFavouriteToggle,
  });

  String formatDuration(Duration duration) {
    int inSeconds = duration.inSeconds;
    int hours = inSeconds ~/ 3600;
    int minutes = (inSeconds % 3600) ~/ 60;
    int seconds = inSeconds % 60;

    String formatted = '';
    if (hours > 0) {
      formatted += '${hours}h ';
    }
    if (minutes > 0) {
      formatted += '${minutes}m ';
    }
    if (seconds > 0) {
      formatted += '${seconds}s';
    }

    return formatted.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: app is ApplicationWithIcon
            ? CircleAvatar(
                backgroundImage: MemoryImage((app as ApplicationWithIcon).icon),
                radius: 20,
              )
            : null,
        title: Text(app.appName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Commented out the network usage section
            /*
            networkInfo == null
                ? Text("Unknown network usage")
                : Text(
                    "Received bytes: ${networkInfo.rxTotalBytes}\nTransferred bytes: ${networkInfo.txTotalBytes}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
            SizedBox(height: 4),
            */
            usageInfo == null
                ? const Text("No usage data")
                : Text(
                    "Screen Time: ${formatDuration(Duration(milliseconds: int.parse(usageInfo!.totalTimeInForeground!)))}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            isFavourite ? Icons.star : Icons.star_border,
            color: isFavourite ? Colors.blue[500] : null,
          ),
          onPressed: () => onFavouriteToggle(app.packageName!),
        ),
      ),
    );
  }
}
