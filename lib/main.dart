import 'package:flutter/material.dart';
import 'dart:async';
import 'package:usage_stats/usage_stats.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'StreakIndicator.dart';

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
      DateTime startDate = endDate.subtract(Duration(days: 72));

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
        onlyAppsWithLaunchIntent: true,
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
      Fluttertoast.showToast(
        msg: "Failed to load usage data: $err",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 20.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
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
        body: Column(
          children: [
            StreakIndicator(), // Add the StreakIndicator widget here
            Expanded(
              child: RefreshIndicator(
                onRefresh: initUsage,
                child: installedApps.isEmpty
                    ? Center(
                        child: SpinKitFadingCircle(
                          color: Colors.blue,
                          size: 50.0,
                        ),
                      )
                    : ListView.separated(
                        itemBuilder: (context, index) {
                          var app = installedApps[index];
                          var networkInfo = _netInfoMap[app.packageName];
                          var usageInfo = _usageInfoMap[app.packageName];

                          return Card(
                            elevation: 4.0,
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: app is ApplicationWithIcon
                                  ? CircleAvatar(
                                      backgroundImage: MemoryImage(
                                          (app as ApplicationWithIcon).icon),
                                      radius: 20,
                                    )
                                  : null,
                              title: Text(app.appName,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  networkInfo == null
                                      ? Text("Unknown network usage")
                                      : Text(
                                          "Received bytes: ${networkInfo.rxTotalBytes}\nTransferred bytes: ${networkInfo.txTotalBytes}",
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                  SizedBox(height: 4),
                                  usageInfo == null
                                      ? Text("No usage data")
                                      : Text(
                                          "Time in foreground: ${formatDuration(Duration(milliseconds: int.parse(usageInfo.totalTimeInForeground!)))}",
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => Divider(),
                        itemCount: installedApps.length,
                      ),
              ),
            ),
          ],
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
