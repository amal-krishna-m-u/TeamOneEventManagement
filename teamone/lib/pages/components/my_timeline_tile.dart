import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:TeamOne/pages/components/event_card.dart';
import 'package:TeamOne/pages/components/my_timeline_tile.dart';

class MyTimeLineTile extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool isPast;
  final eventCard;
  final int heroIndex;

  const MyTimeLineTile({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.isPast,
    required this.eventCard,
    required this.heroIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: TimelineTile(
        isFirst: isFirst,
        isLast: isLast,
        //decorate line
        beforeLineStyle: LineStyle(
          color: isPast ? Colors.blueAccent : Colors.transparent,
        ),
        //decorate icon
        indicatorStyle: IndicatorStyle(
          width: 40,
          color: isPast ? Colors.blue : Colors.transparent,
          iconStyle: IconStyle(
            color: isPast ? Colors.white : Colors.transparent,
            iconData: Icons.check,
          ),
        ),
        endChild: EventCard(
          isPast: isPast,
          child: Hero(
            // Use a unique tag for each Hero widget
            tag: 'timeline_tile_hero_$heroIndex',
            child: eventCard,
          ),
        ),
      ),
    );
  }
}
