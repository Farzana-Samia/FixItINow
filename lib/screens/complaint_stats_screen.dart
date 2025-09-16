import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';

class ComplaintStatsScreen extends StatefulWidget {
  const ComplaintStatsScreen({super.key});
  @override
  State<ComplaintStatsScreen> createState() => _ComplaintStatsScreenState();
}

class _ComplaintStatsScreenState extends State<ComplaintStatsScreen> {
  // Donut buckets
  int submitted = 0, assigned = 0, ongoing = 0, completed = 0;

  // Always show all problem types (even when 0)
  final List<String> problemTypes = const [
    'Electric',
    'Computer',
    'Furniture',
    'Water',
    'Projector',
  ];
  Map<String, int> problemTypeCounts = {
    'Electric': 0,
    'Computer': 0,
    'Furniture': 0,
    'Water': 0,
    'Projector': 0,
  };

  bool loading = true;
  String filterType = 'month'; // 'day' | 'month'
  DateTime selectedDate = DateTime.now();

  // Used to detect team assignment quickly
  final List<String> teamNames = const [
    'Electric',
    'Computer',
    'Furniture',
    'Water',
    'Projector',
  ];

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  // ---------- helpers (logic only) ----------
  // choose a usable timestamp for filtering
  Timestamp? _pickWhen(Map<String, dynamic> d) {
    final v1 = d['submitted_at'];
    if (v1 is Timestamp) return v1;
    final v2 = d['updated_at'];
    if (v2 is Timestamp) return v2;
    final v3 = d['timestamp'];
    if (v3 is Timestamp) return v3;
    return null;
  }

  // Returns 0=submitted, 1=assigned, 2=ongoing, 3=completed
  int _bucketStatus(String rawStatus, String assignedTeam) {
    final s = rawStatus.toLowerCase().replaceAll(' ', '_');

    if (s.contains('completed') ||
        s.contains('resolved') ||
        s.contains('team_completed')) {
      return 3;
    }
    if (s.contains('ongoing') ||
        s.contains('in_progress') ||
        s.contains('rework') ||
        s.contains('working')) {
      return 2;
    }
    if (s.contains('assigned') || s.contains('team_assigned')) {
      return 1;
    }
    if (s.contains('pending') || s.contains('submitted')) {
      return 0;
    }

    // Fallbacks when status is unknown/empty:
    if (assignedTeam.trim().isEmpty) return 0; // no team yet -> Submitted
    return 1; // has team -> Assigned
  }

  // ✅ Fixed: removed the loose "it" match that caused false positives
  String _normalizeProblemType(String x) {
    final v = x.trim().toLowerCase();
    if (v.contains('electric')) return 'Electric';
    if (v.contains('computer') || v.contains('pc')) return 'Computer';
    if (v.contains('furniture')) return 'Furniture';
    if (v.contains('water') || v.contains('plumb')) return 'Water';
    if (v.contains('projector')) return 'Projector';
    return 'Other';
  }

  Future<void> fetchStats() async {
    setState(() {
      loading = true;
      problemTypeCounts = {for (final p in problemTypes) p: 0};
      submitted = assigned = ongoing = completed = 0;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => loading = false);
      return;
    }

    final snap = await FirebaseFirestore.instance
        .collection('cr_complaints')
        .where('userId', isEqualTo: uid)
        .get();

    int s = 0, a = 0, o = 0, c = 0;

    // reset counts
    final nextCounts = {for (final p in problemTypes) p: 0};

    for (final doc in snap.docs) {
      final data = doc.data();

      // pick a usable timestamp (submitted_at > updated_at > timestamp)
      final Timestamp? ts = _pickWhen(data);
      if (ts == null) continue;
      final dt = ts.toDate();

      final inRange = (filterType == 'day')
          ? (dt.year == selectedDate.year &&
                dt.month == selectedDate.month &&
                dt.day == selectedDate.day)
          : (dt.year == selectedDate.year && dt.month == selectedDate.month);

      if (!inRange) continue;

      final assignedTeam = (data['assignedTeam'] ?? '').toString();
      final status = (data['status'] ?? '').toString();

      // donut buckets
      switch (_bucketStatus(status, assignedTeam)) {
        case 0:
          s++;
          break;
        case 1:
          a++;
          break;
        case 2:
          o++;
          break;
        case 3:
          c++;
          break;
      }

      // type counting
      final rawType =
          (data['problem_type'] ?? data['problemType'] ?? data['type'] ?? '')
              .toString()
              .trim();

      String t = _normalizeProblemType(rawType);

      // fallback to assigned team if type unknown/other
      if (t == 'Other' || t.isEmpty) {
        final fallback = (data['assignedTeam'] ?? data['team'] ?? '')
            .toString()
            .trim();
        final inferred = _normalizeProblemType(fallback);
        if (nextCounts.containsKey(inferred)) t = inferred;
      }

      if (nextCounts.containsKey(t)) {
        nextCounts[t] = (nextCounts[t] ?? 0) + 1;
      }
    }

    setState(() {
      submitted = s;
      assigned = a;
      ongoing = o;
      completed = c;
      // publish a fresh map so the UI always reflects the latest values
      problemTypeCounts = Map<String, int>.from(nextCounts);
      loading = false;
    });
  }

  void _selectDate(BuildContext context) async {
    if (filterType == 'day') {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2023),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        setState(() => selectedDate = picked);
        fetchStats();
      }
    } else {
      // simple month picker (current year)
      final now = DateTime.now();
      final options = List.generate(
        12,
        (i) => DateFormat('MMMM yyyy').format(DateTime(now.year, i + 1, 1)),
      );
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        builder: (_) => ListView.builder(
          itemCount: options.length,
          itemBuilder: (_, i) {
            final date = DateTime(now.year, i + 1, 1);
            return ListTile(
              title: Text(options[i]),
              onTap: () {
                setState(() => selectedDate = date);
                Navigator.pop(context);
                fetchStats();
              },
            );
          },
        ),
      );
    }
  }

  // ---- admin-style bar row (unchanged UI) ----
  Widget _barRow({
    required String label,
    required int value,
    required int maxValue,
  }) {
    const Color fill = Color(0xFF1C99D3);
    const Color track = Color(0xFFE5E7EB);
    const double h = 18;

    final double factor = (maxValue <= 0)
        ? 0
        : (value / maxValue).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF5A4030),
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: h,
                  decoration: BoxDecoration(
                    color: track,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: factor,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    height: h,
                    decoration: BoxDecoration(
                      color: fill,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pieData = <String, double>{
      "Submitted ($submitted)": submitted.toDouble(),
      "Assigned ($assigned)": assigned.toDouble(),
      "Ongoing ($ongoing)": ongoing.toDouble(),
      "Completed ($completed)": completed.toDouble(),
    };

    final int maxType = problemTypes
        .map((p) => problemTypeCounts[p] ?? 0)
        .fold<int>(0, (m, v) => v > m ? v : m);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5E3C),
        title: const Text("Complaint Stats"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              setState(() => filterType = v);
              fetchStats();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'day', child: Text("Daily")),
              PopupMenuItem(value: 'month', child: Text("Monthly")),
            ],
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      filterType == 'day'
                          ? "Showing stats for ${DateFormat('dd MMM yyyy').format(selectedDate)}"
                          : "Showing stats for ${DateFormat('MMMM yyyy').format(selectedDate)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF8B5E3C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Donut (unchanged UI)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PieChart(
                      dataMap: pieData,
                      animationDuration: const Duration(milliseconds: 800),
                      chartRadius: MediaQuery.of(context).size.width / 1.8,
                      chartType: ChartType.ring,
                      ringStrokeWidth: 28,
                      colorList: const [
                        Color(0xFFE02A2A), // Submitted
                        Color(0xFF1C99D3), // Assigned
                        Color(0xFFDB0F7F), // Ongoing
                        Color(0xFF0DC51D), // Completed
                      ],
                      chartValuesOptions: const ChartValuesOptions(
                        showChartValuesInPercentage: true,
                        showChartValuesOutside: true,
                        decimalPlaces: 1,
                      ),
                      legendOptions: const LegendOptions(
                        legendPosition: LegendPosition.bottom,
                        showLegendsInRow: true,
                        legendTextStyle: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Bars (unchanged UI)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.build_rounded,
                          size: 20,
                          color: Color(0xFF5A4030),
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Complaints by Problem Type",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF5A4030),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: problemTypes.length,
                    itemBuilder: (_, i) {
                      final t = problemTypes[i];
                      final v = problemTypeCounts[t] ?? 0;
                      return _barRow(
                        label: t,
                        value: v,
                        maxValue: (maxType <= 0) ? 1 : maxType,
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
