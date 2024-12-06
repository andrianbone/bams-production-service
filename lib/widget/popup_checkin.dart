import 'package:flutter/material.dart';
import '../pages/checkin_detail.dart';
import '../widget/padding.dart';

class WidgetPopUpCheckIn extends StatelessWidget {
  final params;
  final parent;
  final _formKey = GlobalKey<FormState>();

  WidgetPopUpCheckIn({super.key, @required this.params, @required this.parent});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white70,
      child: ListTile(
          title: Text(params['pROGRAMNAME'] ?? ''),
          subtitle: Column(
            children: [
              const WidgetPadding(10),
              Row(
                children: [
                  Text(params['bOOKNO'] ?? ''),
                ],
              ),
              const WidgetPadding(5),
              Row(
                children: [
                  Text(params['pROGRAMSTARTDATE'] ?? ''),
                ],
              ),
            ],
          ),
          trailing: Text(params['pROGRAMLOCATIONNAME'] ?? ''),
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        // Positioned(
                        //   right: -40.0,
                        //   top: -40.0,
                        //   child: InkResponse(
                        //     onTap: () {
                        //       Navigator.of(parent).pop();
                        //     },
                        //     child: const CircleAvatar(
                        //       backgroundColor: Colors.red,
                        //       child: Icon(Icons.close),
                        //     ),
                        //   ),
                        // ),
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Text('PROGRAM SELECTED',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              const WidgetPadding(15),
                              const Text('Book No.',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const WidgetPadding(5),
                              Text('${params['bOOKNO'] ?? ''}'),
                              const WidgetPadding(10),
                              const Text('Start Booking Date',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const WidgetPadding(5),
                              Text('${params['pROGRAMSTARTDATE'] ?? ''}'),
                              const WidgetPadding(10),
                              const Text('Program Name',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const WidgetPadding(5),
                              Text('${params['pROGRAMNAME'] ?? ''}'),
                              const WidgetPadding(20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CheckInDetPage(
                                                        params: params)),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 5),
                                            textStyle: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                        child: const Text(
                                          'YES',
                                          style: TextStyle(
                                            color: Colors
                                                .white, // Set text color to white
                                            fontWeight: FontWeight
                                                .bold, // Optional: Make text bold
                                            fontSize:
                                                16, // Optional: Adjust font size
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 5),
                                            textStyle: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                        child: const Text(
                                          'NO',
                                          style: TextStyle(
                                            color: Colors
                                                .white, // Set text color to white
                                            fontWeight: FontWeight
                                                .bold, // Optional: Make text bold
                                            fontSize:
                                                16, // Optional: Adjust font size
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                });
          }),
    );
  }
}
