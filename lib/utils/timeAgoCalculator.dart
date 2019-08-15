import 'package:timeago/timeago.dart' as timeago;

class TimeAgoCalculator{
  
  ago() {
    final fifteenAgo = new DateTime.now().subtract(new Duration(minutes: 15));
    return timeago.format(fifteenAgo); // 15 minutes ago 
  }

  calculate(DateTime time) {
    final fifteenAgo = new DateTime.now().subtract(DateTime.now().difference(time));
    return timeago.format(fifteenAgo); // 15 minutes ago 
  }

}