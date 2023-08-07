import 'package:flutter/material.dart'; 


class EventCard extends StatelessWidget {
final isPast;
final child;

  const EventCard({super.key, this.isPast, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(25),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:isPast? Colors.blueAccent:Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}