import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/data/plan/load_plan.dart';
import 'package:meeting_planning_tool/data/plan/plan.dart';
import 'package:meeting_planning_tool/widgets/plan/big_screen.dart';
import 'package:meeting_planning_tool/widgets/plan/small_screen.dart';

class PlanViewWidget extends StatefulWidget {
  final DateTime month;

  const PlanViewWidget({super.key, required this.month});

  @override
  State<PlanViewWidget> createState() => _PlanViewWidgetState();
}

class _PlanViewWidgetState extends State<PlanViewWidget> {
  late Future<TransformedPlan?> _data;
  late DateTime _month;

  @override
  Widget build(BuildContext context) {
    _month = widget.month;
    _data = fetchPlan(context, _month);
    return Expanded(
        child: FutureBuilder<TransformedPlan?>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          TransformedPlan? data = snapshot.data;
          if (data != null && data.data.isNotEmpty) {
            if (MediaQuery.of(context).size.width > 600) {
              return BigPlanView(data: data);
            } else {
              return SmallPlanView(data: data);
            }
          } else {
            return const Center(child: Text('No Data'));
          }
        }
      },
    ));
  }
}
