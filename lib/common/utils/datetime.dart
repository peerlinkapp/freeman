import 'package:freeman/common.dart';
import 'package:intl/intl.dart';

class DateTimeUtils {

// 转换为人性化的日期格式（如：昨天、前天、具体日期等）
  static String getHumanReadableDate(int epoch) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    DateTime now = DateTime.now();

    // 获取今天、昨天、前天的日期
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(Duration(days: 1));
    DateTime theDayBeforeYesterday = today.subtract(Duration(days: 2));
    DateTime targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String timeStr = DateFormat('HH:mm').format(dateTime); // 提取时间

    if (targetDate.isAtSameMomentAs(today)) {
      return '${Global.l10n.time_today} $timeStr';
    } else if (targetDate.isAtSameMomentAs(yesterday)) {
      return '${Global.l10n.time_yesterday} $timeStr';
    } else if (targetDate.isAtSameMomentAs(theDayBeforeYesterday)) {
      return '${Global.l10n.time_before_yesterday} $timeStr';
    } else if (dateTime.year == now.year) {
      return '${DateFormat('MM-dd').format(dateTime)} $timeStr';
    } else {
      return '${DateFormat('yyyy-MM-dd').format(dateTime)} $timeStr';
    }
  }

  static bool areNeighbourMinute(int epochTime1, int epochTime2)
  {
      bool isSame = areInSameMinute(epochTime1, epochTime2);
      if(isSame) return true;
      //不同的分钟数
      DateTime time1 = DateTime.fromMillisecondsSinceEpoch(epochTime1 * 1000);
      DateTime time2 = DateTime.fromMillisecondsSinceEpoch(epochTime2 * 1000);
      int d = time2.minute - time1.minute;
      return d.abs() <= 5;
  }

  static bool areInSameMinute(int epochTime1, int epochTime2) {
    DateTime time1 = DateTime.fromMillisecondsSinceEpoch(epochTime1 * 1000);
    DateTime time2 = DateTime.fromMillisecondsSinceEpoch(epochTime2 * 1000);

    // 比较年、月、日、小时和分钟，确保在同一分钟
    return time1.year == time2.year &&
        time1.month == time2.month &&
        time1.day == time2.day &&
        time1.hour == time2.hour &&
        time1.minute == time2.minute;
  }

  static int getEpochNow()
  {
     return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }
}