import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/models/plan/load_plan.dart';
import 'package:meeting_planning_tool/models/plan/plan.dart';
import 'package:meeting_planning_tool/widgets/plan/big_screen.dart';
import 'package:meeting_planning_tool/widgets/plan/small_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlanViewWidget extends StatefulWidget {
  final DateTime month;
  final bool bigScreen;

  const PlanViewWidget({super.key, required this.month, required this.bigScreen});

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
          return Center(
              child: Text(
                  '${AppLocalizations.of(context).error}: ${snapshot.error}'));
        } else {
          TransformedPlan? data = snapshot.data;
          if (data != null && data.data.isNotEmpty) {
            if (widget.bigScreen) {
              return BigPlanView(data: data);
            } else {
              return SmallPlanView(data: data);
            }
          } else {
            return Center(child: Text(AppLocalizations.of(context).noData));
          }
        }
      },
    ));
  }
}
