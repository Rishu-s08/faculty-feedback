import 'package:facultyfeed/core/models/feedback_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_chart/pie_chart.dart';

class ConsiseStatsViewScreen extends ConsumerStatefulWidget {
  final FeedbackForm form;
  const ConsiseStatsViewScreen({super.key, required this.form});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConsiseStatsViewScreenState();
}

class _ConsiseStatsViewScreenState
    extends ConsumerState<ConsiseStatsViewScreen> {
  late Map<String, double> starsRating;
  late double overallAverage;
  late MapEntry<String, double> highestRated;
  late MapEntry<String, double> lowestRated;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    calculateStatsFromForm(widget.form);
    isLoading = false;
  }

  void calculateStatsFromForm(FeedbackForm form) {
    if (form.totalResponses == 0) {
      overallAverage = 0;
      highestRated = MapEntry("No entries", 0);
      lowestRated = MapEntry("No entries", 0);
      return;
    }

    double total = form.ratings.values.fold(0.0, (sum, r) => sum + r);
    overallAverage = total / form.ratings.length;

    highestRated = form.ratings.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    lowestRated = form.ratings.entries.reduce(
      (a, b) => a.value < b.value ? a : b,
    );

    starsRating = {'5 ⭐': 0, '4 ⭐': 0, '3 ⭐': 0, '2 ⭐': 0, '1 ⭐': 0};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildOverallRating(),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Rating Per Question",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    PieChart(
                      dataMap: widget.form.ratings.map(
                        (key, value) => MapEntry(_truncate(key, 60), value),
                      ),
                      chartType: ChartType.ring,
                      chartLegendSpacing: 32,
                      chartRadius: MediaQuery.of(context).size.width / 2.2,
                      colorList: const [
                        Color(0xFF4E79A7), // Blue
                        Color(0xFFF28E2B), // Orange
                        Color(0xFFE15759), // Red
                        Color(0xFF76B7B2), // Teal
                        Color(0xFF59A14F), // Green
                        Color(0xFFEDC948), // Yellow
                        Color(0xFFB07AA1), // Purple
                        Color(0xFF9C755F), // Brown
                        Color(0xFFBAB0AC),
                        Color.fromARGB(255, 0, 42, 255),
                      ],
                      chartValuesOptions: const ChartValuesOptions(
                        showChartValuesInPercentage: false,
                        showChartValues: true,
                      ),
                      legendOptions: const LegendOptions(
                        legendPosition: LegendPosition.bottom,
                        showLegendsInRow: false,
                        showLegends: true,
                        legendTextStyle: TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Quick Stats",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      physics: NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.8, // slightly taller
                      children: [
                        _statCard(
                          "Submissions",
                          widget.form.totalResponses.toString(),
                        ),
                        _statCard(
                          "Highest Rated (${highestRated.value.toStringAsFixed(1)}⭐)",
                          highestRated.key,
                        ),
                        _statCard(
                          "Lowest Rated (${lowestRated.value.toStringAsFixed(1)}⭐)",
                          lowestRated.key,
                        ),
                        _statCard("Most Common", "${overallAverage.round()}⭐"),
                      ],
                    ),

                    const SizedBox(height: 20),
                    // ElevatedButton.icon(
                    //   onPressed: () {},
                    //   icon: const Icon(Icons.download),
                    //   label: const Text("Export as PDF"),
                    //   style: ElevatedButton.styleFrom(
                    //     minimumSize: const Size(double.infinity, 50),
                    //   ),
                    // ),
                  ],
                ),
              ),
    );
  }

  Widget _buildOverallRating() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Overall Rating",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            RatingBarIndicator(
              rating: overallAverage,
              itemBuilder:
                  (context, _) => const Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 32,
            ),
            const SizedBox(height: 8),
            Text(
              "Avg: ${overallAverage.toStringAsFixed(2)} out of 5 from ${widget.form.totalResponses} responses",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _truncate(String input, int maxLength) {
    return input.length <= maxLength
        ? input
        : '${input.substring(0, maxLength)}...';
  }
}
