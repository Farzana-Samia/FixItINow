import 'package:flutter/material.dart';

import 'complaint_page1.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage ({super.key});

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
  title: const Text('Notifications'),
  centerTitle: true,
  elevation: 0,
  ),
  body: ListView(
  children: const [
  NotificationItem(
  name: 'Kate Youn',
  time: '5 mins ago',
  message:
  'Lorem Ipsum\nContrary to popular belief, Lorem Ipsum is not simply random text.',
  isBold: true,
  ),
  Divider(height: 1),
  NotificationItem(
  name: 'Brandon Newman',
  time: '12 mins ago',
  message: 'Lorem Ipsum',
  ),
  Divider(height: 1),
  NotificationItem(
  name: 'Dave Wood',
  time: '1hr ago',
  message: 'Lorem Ipsum',
  ),
  Divider(height: 1),
  NotificationItem(
  name: 'Kate Youn',
  time: '2hr ago',
  message: 'Lorem Ipsum',
  ),
  Divider(height: 1),
  NotificationItem(
  name: 'Anne Lao',
  time: '1day ago',
  message:
  'Lorem Ipsum\nContrary to popular belief, Lorem Ipsum is not simply random text.',
  ),
  Divider(height: 1),
  Padding(
  padding: EdgeInsets.all(16.0),
  child: Center(
  child: Text(
  'See all incoming activity',
  style: TextStyle(
  color: Colors.blue,
  fontWeight: FontWeight.bold,
  ),
  ),
  ),
  ),
  ],
  ),
  );
  }
  }

// Individual notification item widget
  class NotificationItem extends StatelessWidget {
  final String name;
  final String time;
  final String message;
  final bool isBold;

  const NotificationItem({
  super.key,
  required this.name,
  required this.time,
  required this.message,
  this.isBold = false,
  });


  @override
  Widget build(BuildContext context) {
  return Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
  Text(
  name,
  style: TextStyle(
  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
  fontSize: 16,
  ),
  ),
  Text(
  time,
  style: const TextStyle(
  color: Colors.grey,
  fontSize: 14,
  ),
  ),
  ],
  ),
  const SizedBox(height: 8),
  Text(
  message,
  style: TextStyle(
  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
  ),
  ),
  ],
  ),
  );
  }
  }

