import 'package:flutter/material.dart';

class WidgetMenu extends StatelessWidget {
  final void Function(Choice) _onExitApps;
  // ignore: prefer_typing_uninitialized_variables
  final username;
  // ignore: prefer_typing_uninitialized_variables
  final email;
  const WidgetMenu(this._onExitApps, this.username, this.email, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: PopupMenuButton<Choice>(
        icon: const Icon(
          Icons.more_vert,
          color: Colors.blueGrey,
        ),
        onSelected: _onExitApps,
        itemBuilder: (BuildContext context) {
          return choices.map((Choice choice) {
            return PopupMenuItem<Choice>(
                height: 30,
                value: choice,
                child: Builder(builder: (context) {
                  switch (choice.title) {
                    case 'Profile':
                      return Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.person_pin,
                              color: Colors.blue.shade400,
                              size: 20,
                            ),
                          ),
                          SizedBox(
                              width: 200,
                              child: Text(
                                username,
                                style: const TextStyle(fontSize: 14),
                              )),
                        ],
                      );
                    // break;
                    case 'Email':
                      return Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.mail_outline,
                              color: Colors.blue.shade400,
                              size: 20,
                            ),
                          ),
                          SizedBox(
                              width: 200,
                              child: Text(
                                email,
                                style: const TextStyle(fontSize: 14),
                              )),
                        ],
                      );
                    // break;
                    default:
                      return Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.power_settings_new_rounded,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                          SizedBox(
                              width: 200,
                              child: Text(
                                choice.title!,
                                style: const TextStyle(fontSize: 14),
                              )),
                        ],
                      );
                  }
                }));
          }).toList();
        },
      ),
    );
  }
}

class Choice {
  const Choice({this.title});

  final String? title;
}

const List<Choice> choices = <Choice>[
  Choice(title: 'Profile'),
  Choice(title: 'Email'),
  Choice(title: 'Logout'),
];
