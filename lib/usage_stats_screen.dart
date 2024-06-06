import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'app_list_item.dart';
import 'streak_indicator.dart';
import 'app_usage_service.dart';

class UsageStatsScreen extends StatefulWidget {
  @override
  _UsageStatsScreenState createState() => _UsageStatsScreenState();
}

class _UsageStatsScreenState extends State<UsageStatsScreen> {
  List<Application> installedApps = [];
  Map<String?, NetworkInfo?> _netInfoMap = {};
  Map<String?, UsageInfo?> _usageInfoMap = {};
  Set<String> favouriteApps = Set<String>();

  @override
  void initState() {
    super.initState();
    initUsage();
  }

  Future<void> initUsage() async {
    try {
      // Grant usage permission
      UsageStats.grantUsagePermission();

      final result = await fetchUsageStatsAndApps();
      setState(() {
        _netInfoMap = result.netInfoMap;
        _usageInfoMap = result.usageInfoMap;
        installedApps = result.installedApps;
        _sortApps();
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

  void toggleFavourite(String packageName) {
    setState(() {
      if (favouriteApps.contains(packageName)) {
        favouriteApps.remove(packageName);
      } else {
        favouriteApps.add(packageName);
      }
      _sortApps();
    });
  }

  void _sortApps() {
    installedApps.sort((a, b) {
      bool aIsFav = favouriteApps.contains(a.packageName);
      bool bIsFav = favouriteApps.contains(b.packageName);

      if (aIsFav && !bIsFav) {
        return -1;
      } else if (!aIsFav && bIsFav) {
        return 1;
      } else {
        int aTimeInForeground = _usageInfoMap[a.packageName]
                    ?.totalTimeInForeground !=
                null
            ? int.parse(_usageInfoMap[a.packageName]!.totalTimeInForeground!)
            : 0;
        int bTimeInForeground = _usageInfoMap[b.packageName]
                    ?.totalTimeInForeground !=
                null
            ? int.parse(_usageInfoMap[b.packageName]!.totalTimeInForeground!)
            : 0;
        return bTimeInForeground.compareTo(aTimeInForeground);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Usage Stats"),
        actions: const [
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
                  ? const Center(
                      child: SpinKitFadingCircle(
                        color: Colors.blue,
                        size: 50.0,
                      ),
                    )
                  : ListView.separated(
                      itemBuilder: (context, index) {
                        var app = installedApps[index];
                        var usageInfo = _usageInfoMap[app.packageName];
                        return AppListItem(
                          app: app,
                          usageInfo: usageInfo,
                          isFavourite: favouriteApps.contains(app.packageName),
                          onFavouriteToggle: toggleFavourite,
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: installedApps.length,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
