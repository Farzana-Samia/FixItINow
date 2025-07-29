import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class ProjectorTeamStatsPage extends StatelessWidget {
  const ProjectorTeamStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = {
      "Ongoing": 1,
      // Values for Pending and Completed are 0 so not included in the chart
    };

    final colorList = <Color>[
      Colors.blue, // Ongoing
      Colors.red,  // Pending (won't show in chart if value is 0)
      Colors.green, // Completed (won't show in chart if value is 0)
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F1), // light background
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5E3C), // brown
        title: const Text(
          'Projector Team Stats',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PieChart(
              dataMap: dataMap,
              animationDuration: const Duration(milliseconds: 800),
              chartRadius: 150,
              colorList: [Colors.blue],
              chartType: ChartType.disc,
              chartValuesOptions: const ChartValuesOptions(
                showChartValuesInPercentage: true,
                showChartValueBackground: false,
                showChartValues: true,
                chartValueStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              legendOptions: const LegendOptions(showLegends: false),
            ),
            const SizedBox(height: 30),
            buildLegend(Colors.red, "Pending", 0),
            buildLegend(Colors.blue, "Ongoing", 1),
            buildLegend(Colors.green, "Completed", 0),
          ],
        ),
      ),
    );
  }

  Widget buildLegend(Color color, String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 6,
          ),
          const SizedBox(width: 8),
          Text(
            '$label ($count)',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}