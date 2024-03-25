import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:meeting_planning_tool/api_service.dart';
import 'package:meeting_planning_tool/data/plan/load_plan.dart';
import 'package:meeting_planning_tool/screens/navbar.dart';
import 'package:meeting_planning_tool/widgets/month_picker.dart';
import 'package:meeting_planning_tool/widgets/plan/view.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan'),
      ),
      body: Column(
        children: [
          MonthPicker(
            month: _month,
            onDateChanged: (p0) {
              setState(() {
                _month = p0;
              });
            },
          ),
          const SizedBox(height: 20.0),
          PlanViewWidget(month: _month)
        ],
      ),
      floatingActionButton: SpeedDial(
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 4,
        icon: Icons.dataset,
        children: [
          SpeedDialChild(
              child: const Icon(Icons.picture_as_pdf),
              label: "Get PDF",
              onTap: () async {
                String path = await ApiService.downloadFile(
                    context, 'plan', queryParam(_month));
                if (!kIsWeb && !Platform.isLinux && context.mounted) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: const Text('Preview'),
                          ),
                          body: PDFView(
                            filePath: path,
                          ),
                          floatingActionButton: FloatingActionButton(
                            child: const Icon(Icons.share),
                            onPressed: () {
                              Share.shareXFiles([XFile(path)],
                                  text: path.split('/').last);
                            },
                          ),
                        ),
                      ));
                } else {
                  OpenFilex.open(path);
                }
              }),
          SpeedDialChild(
              child: const Icon(Icons.add_box),
              label: "Create Plan",
              onTap: () async {
                ApiService.postData(
                    context, "plan", null, queryParam(_month), (p0) => null);
                setState(() => _month = _month);
              })
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }
}
