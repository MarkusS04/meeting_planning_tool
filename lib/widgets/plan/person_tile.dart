import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/services/api_service.dart';
import 'package:meeting_planning_tool/models/person/person.dart';
import 'package:meeting_planning_tool/models/plan/plan.dart';
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
        People? people;
        await ApiService.fetchData(
          context,
          'plan/${_person!.planId}/people',
          {},
          (data) => People.fromJson(data),
        ).then((value) => people = value);

        if (context.mounted && people != null) {
          Person? initialSelectedPerson;
          if (people!.available.isNotEmpty) {
            initialSelectedPerson = people!.available.last;
          } else if (people!.absent.isNotEmpty) {
            initialSelectedPerson = people!.absent.last;
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(AppLocalizations.of(context).noData),
                  content: Text(AppLocalizations.of(context).noPerson),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
            return;
          }
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return PersonDropdown(
                personsAvailable: people!.available,
                personsAbsent: people!.absent,
                initialSelectedPerson: initialSelectedPerson!,
                planId: _person!.planId,
              );
            },
          );
          if (context.mounted) {
            final plan = await ApiService.fetchData<Plan>(context,
                'plan/${_person!.planId}', {}, (json) => Plan.fromJson(json));
            setState(() {
              _person = PersonWithPlanId(person: plan.person, planId: plan.id);
            });
          }
        }
      },
    );
  }
}
