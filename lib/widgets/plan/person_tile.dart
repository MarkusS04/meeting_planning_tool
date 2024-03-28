import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/api_service.dart';
import 'package:meeting_planning_tool/data/person/person.dart';
import 'package:meeting_planning_tool/data/plan/plan.dart';
import 'package:meeting_planning_tool/widgets/plan/plan_person_update.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlanPersonTile extends StatefulWidget {
  final PersonWithPlanId? person;
  final String? task;
  const PlanPersonTile({super.key, required this.person, this.task});

  @override
  State<PlanPersonTile> createState() => _PlanPersonTileState();
}

class _PlanPersonTileState extends State<PlanPersonTile> {
  late PersonWithPlanId? _person;

  @override
  void initState() {
    super.initState();
    _person = widget.person;
  }

  @override
  Widget build(BuildContext context) {
    List<Text> text = [];
    if (widget.task != null) {
      text.add(Text('${widget.task}:'));
    }
    text.add(
      Text(_person != null
          ? (_person!.person != null && _person!.person!.givenName != ''
              ? '${_person!.person!.givenName} ${_person!.person!.lastName}'
              : AppLocalizations.of(context).notAssigned)
          : AppLocalizations.of(context).noEntryGenerated),
    );
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: text,
      ),
      onTap: () async {
        List<Person> personsAvailable = [];
        if (_person != null) {
          await ApiService.fetchData(
              context,
              'plan/${_person!.planId}/people',
              {},
              (data) => (data as List)
                  .map((json) => Person.fromJson(json))
                  .toList()).then((value) => personsAvailable = value);
          _person!.person != null
              ? personsAvailable.add(_person!.person!)
              : null;

          if (context.mounted) {
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return PersonDropdown(
                    personsAvailable: personsAvailable,
                    initialSelectedPerson: personsAvailable.last,
                    planId: _person!.planId,
                  );
                });
            if (context.mounted) {
              final plan = await ApiService.fetchData<Plan>(context,
                  'plan/${_person!.planId}', {}, (json) => Plan.fromJson(json));
              setState(() {
                _person =
                    PersonWithPlanId(person: plan.person, planId: plan.id);
              });
            }
          }
        }
      },
    );
  }
}
