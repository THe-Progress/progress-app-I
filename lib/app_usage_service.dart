import 'package:usage_stats/usage_stats.dart';
import 'package:device_apps/device_apps.dart';

class UsageStatsResult {
  final Map<String?, NetworkInfo?> netInfoMap;
  final Map<String?, UsageInfo?> usageInfoMap;
  final List<Application> installedApps;

  UsageStatsResult({
    required this.netInfoMap,
    required this.usageInfoMap,
    required this.installedApps,
  });
}

Future<UsageStatsResult> fetchUsageStatsAndApps() async {
  // Set the date range
  DateTime endDate = DateTime.now();
  DateTime startDate = endDate.subtract(const Duration(days: 1));

  // Query network info and usage stats
  List<NetworkInfo> networkInfos = await UsageStats.queryNetworkUsageStats(
    startDate,
    endDate,
    networkType: NetworkType.all,
  );
  List<UsageInfo> usageInfoList =
      await UsageStats.queryUsageStats(startDate, endDate);

  // Create maps for quick lookup
  Map<String?, NetworkInfo?> netInfoMap = {
    for (var v in networkInfos) v.packageName: v
  };
  Map<String?, UsageInfo?> usageInfoMap = {
    for (var v in usageInfoList) v.packageName: v
  };

  // Get installed apps
  List<Application> installedApps = await DeviceApps.getInstalledApplications(
    includeSystemApps: false,
    includeAppIcons: true,
    onlyAppsWithLaunchIntent: true,
  );

  return UsageStatsResult(
    netInfoMap: netInfoMap,
    usageInfoMap: usageInfoMap,
    installedApps: installedApps,
  );
}
