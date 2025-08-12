import 'package:flutter/material.dart';

class ElectricalTeamDetailsPage extends StatefulWidget {
  @override
  _ElectricalTeamDetailsPageState createState() => _ElectricalTeamDetailsPageState();
}

class _ElectricalTeamDetailsPageState extends State<ElectricalTeamDetailsPage> {
  final List<String> pendingTasks = [
    "Fix classroom light issue - Room 302",
    "Check wiring in Lab 204"
  ];

  final List<String> ongoingTasks = [
    "Replace fan in Room 107",
    "Install new switch in Hall A"
  ];

  final List<String> completedTasks = [
    "Transformer upgrade - Block B",
    "Fixed main corridor lights"
  ];

  bool showPending = false;
  bool showOngoing = false;
  bool showCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F2),
      appBar: AppBar(
        title: const Text(
          'Electrical Team Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pink.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildExpandableBox(
              title: "Pending Tasks",
              icon: Icons.schedule,
              tasks: pendingTasks,
              isExpanded: showPending,
              toggleExpanded: () => setState(() => showPending = !showPending),
            ),
            const SizedBox(height: 20),
            _buildExpandableBox(
              title: "Ongoing Tasks",
              icon: Icons.sync,
              tasks: ongoingTasks,
              isExpanded: showOngoing,
              toggleExpanded: () => setState(() => showOngoing = !showOngoing),
            ),
            const SizedBox(height: 20),
            _buildExpandableBox(
              title: "Completed Tasks",
              icon: Icons.check_circle,
              tasks: completedTasks,
              isExpanded: showCompleted,
              toggleExpanded: () => setState(() => showCompleted = !showCompleted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableBox({
    required String title,
    required IconData icon,
    required List<String> tasks,
    required bool isExpanded,
    required VoidCallback toggleExpanded,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink.shade200, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 3)),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: toggleExpanded,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, color: Colors.pink.shade400),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade700,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tasks
                    .map(
                      (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const Text(
                          "•",
                          style: TextStyle(fontSize: 18, color: Colors.black87),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            task,
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
