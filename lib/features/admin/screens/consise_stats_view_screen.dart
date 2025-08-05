import 'package:facultyfeed/core/models/feedback_form.dart';
import 'package:facultyfeed/core/models/response_form.dart';
import 'package:facultyfeed/features/feedback/controller/give_feedback_controller.dart';
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

    // Compute average rating
    double total = form.ratings.values.fold(0.0, (sum, r) => sum + r);
    overallAverage = total / form.ratings.length;

    // Determine highest and lowest
    highestRated = form.ratings.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    lowestRated = form.ratings.entries.reduce(
      (a, b) => a.value < b.value ? a : b,
    );

    //compute circular rating
    starsRating = {'5 ⭐': 0, '4 ⭐': 0, '3 ⭐': 0, '2 ⭐': 0, '1 ⭐': 0};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                // physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildOverallRating(),
                    SizedBox(height: 20),
                    Text(
                      "Rating Per Question",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 10),
                    PieChart(
                      dataMap: widget.form.ratings,
                      // chartRadius: 150,
                      chartType: ChartType.ring,
                      chartLegendSpacing: 32,
                      chartRadius: MediaQuery.of(context).size.width / 2.5,
                      colorList: [
                        Colors.blue,
                        Colors.green,
                        Colors.orange,
                        Colors.purple,
                        Colors.red,
                        Colors.cyan,
                        Colors.teal,
                      ],
                      chartValuesOptions: ChartValuesOptions(
                        showChartValuesInPercentage: false,
                        showChartValues: true,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Quick Stats",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.5,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _statCard(
                          "Submissions",
                          widget.form.totalResponses.toString(),
                        ),
                        _statCard(
                          "Highest Rated (${highestRated.value}⭐)",
                          highestRated.key,
                        ),
                        _statCard(
                          "Lowest Rated (${lowestRated.value}⭐)",
                          lowestRated.key,
                        ),
                        _statCard(
                          "Most Common",
                          "${overallAverage.round().toString()}⭐",
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.download),
                      label: Text("Export as PDF"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
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
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Overall Rating",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            RatingBarIndicator(
              rating: overallAverage,
              itemBuilder:
                  (context, _) => Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 32,
            ),
            SizedBox(height: 8),
            Text(
              "Avg: ${overallAverage.toStringAsFixed(2)} out of 5 from ${widget.form.totalResponses} responses",
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
