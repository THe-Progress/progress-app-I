import 'package:flutter/material.dart';
import 'dart:async';
import 'package:usage_stats/usage_stats.dart';
import 'package:device_apps/device_apps.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Application> installedApps = [];
  Map<String?, NetworkInfo?> _netInfoMap = {};
  Map<String?, UsageInfo?> _usageInfoMap = {};

  @override
  void initState() {
    super.initState();
    initUsage();
  }

  Future<void> initUsage() async {
    try {
      // Grant usage permission
      UsageStats.grantUsagePermission();

      // Set the date range
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: 1));

      // Query network info and usage stats
      List<NetworkInfo> networkInfos = await UsageStats.queryNetworkUsageStats(
        startDate,
        endDate,
        networkType: NetworkType.all,
      );
      List<UsageInfo> usageInfoList =
          await UsageStats.queryUsageStats(startDate, endDate);

      // Create maps for quick lookup
      Map<String?, NetworkInfo?> netInfoMap = Map.fromIterable(
        networkInfos,
        key: (v) => v.packageName,
        value: (v) => v,
      );
      Map<String?, UsageInfo?> usageInfoMap = Map.fromIterable(
        usageInfoList,
        key: (v) => v.packageName,
        value: (v) => v,
      );

      // Get installed apps
      installedApps = await DeviceApps.getInstalledApplications(
        includeSystemApps: false,
        includeAppIcons: true,
        onlyAppsWithLaunchIntent: false,
      );

      // Sort installed apps by time in foreground (descending)
      installedApps.sort((a, b) {
        int aTimeInForeground =
            usageInfoMap[a.packageName]?.totalTimeInForeground != null
                ? int.parse(usageInfoMap[a.packageName]!.totalTimeInForeground!)
                : 0;
        int bTimeInForeground =
            usageInfoMap[b.packageName]?.totalTimeInForeground != null
                ? int.parse(usageInfoMap[b.packageName]!.totalTimeInForeground!)
                : 0;
        return bTimeInForeground.compareTo(aTimeInForeground);
      });

      // Update state with the retrieved data
      setState(() {
        _netInfoMap = netInfoMap;
        _usageInfoMap = usageInfoMap;
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Usage Stats"),
          actions: [
            IconButton(
              onPressed: UsageStats.grantUsagePermission,
              icon: Icon(Icons.settings),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: initUsage,
          child: ListView.separated(
            itemBuilder: (context, index) {
              var app = installedApps[index];
              var networkInfo = _netInfoMap[app.packageName];
              var usageInfo = _usageInfoMap[app.packageName];

              return ListTile(
                leading: app is ApplicationWithIcon
                    ? Image.memory((app as ApplicationWithIcon).icon,
                        width: 40, height: 40)
                    : null,
                title: Text(app.appName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    networkInfo == null
                        ? Text("Unknown network usage")
                        : Text(
                            "Received bytes: ${networkInfo.rxTotalBytes}\nTransferred bytes: ${networkInfo.txTotalBytes}",
                          ),
                    usageInfo == null
                        ? Text("No usage data")
                        : Text(
                            "Time in foreground: ${formatDuration(Duration(milliseconds: int.parse(usageInfo.totalTimeInForeground!)))}",
                          ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => Divider(),
            itemCount: installedApps.length,
          ),
        ),
      ),
    );
  }

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
}
