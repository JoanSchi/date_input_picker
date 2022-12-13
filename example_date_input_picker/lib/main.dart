import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:date_input_picker/date_utils.dart';
import 'package:date_input_picker/date_input_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Date Input or Picker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime date = DateTime.now();
  DateTime monthYear = toMonthYear(DateTime.now());
  final GlobalKey<FormState> _form = GlobalKey();

  List<String> dateFormatList = [
    'd-M-y',
    'y/M/d',
    'y-MM-dd',
    'dd.MM.y',
    'y. M. d.'
  ];
  String dateFormat = 'd-M-y';

  List<String> monthFormatList = ['M-y', 'y/M', 'y-MM', 'MM.y', 'y. M.'];

  String monthFormat = 'M-y';

  @override
  Widget build(BuildContext context) {
    // final t = Localizations.localeOf(context).toString();
    // print('time $t');
    bool formatWithUnfocus;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        {
          formatWithUnfocus = true;
          break;
        }

      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        {
          formatWithUnfocus = false;
        }
        break;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Form(
        key: _form,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              Focus(
                descendantsAreFocusable: false,
                descendantsAreTraversable: false,
                skipTraversal: true,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  spacing: 8.0,
                  children: [
                    for (String f in dateFormatList)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            dateFormat = f;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: f == dateFormat ? 2.0 : 1.0,
                            backgroundColor: f == dateFormat
                                ? Colors.blue[100]
                                : Colors.white,
                            shape: const StadiumBorder()),
                        child: Text(f),
                      )
                  ],
                ),
              ),
              DateInputPicker(
                  formatWithUnfocus: formatWithUnfocus,
                  format: dateFormat,
                  dateMode: DateMode.date,
                  textInputAction: TextInputAction.next,
                  dividerVisible: DividerVisible.visible,
                  date: date,
                  firstDate: DateTime(2000, 1, 1),
                  lastDate: DateTime(2040, 1, 1),
                  changeDate: changeMonthYear,
                  saveDate: changeMonthYear),
              const SizedBox(
                height: 24.0,
              ),
              Focus(
                descendantsAreFocusable: false,
                descendantsAreTraversable: false,
                skipTraversal: true,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  spacing: 8.0,
                  children: [
                    for (String f in monthFormatList)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            monthFormat = f;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: f == monthFormat ? 2.0 : 1.0,
                            backgroundColor: f == monthFormat
                                ? Colors.blue[100]
                                : Colors.white,
                            shape: const StadiumBorder()),
                        child: Text(f),
                      )
                  ],
                ),
              ),
              DateInputPicker(
                  formatWithUnfocus: formatWithUnfocus,
                  format: monthFormat,
                  dateMode: DateMode.monthYear,
                  textInputAction: TextInputAction.next,
                  dividerVisible: DividerVisible.visible,
                  date: monthYear,
                  firstDate: DateTime(2000, 1, 1),
                  lastDate: DateTime(2040, 1, 1),
                  changeDate: changeMonthYear,
                  saveDate: changeMonthYear),
              const SizedBox(
                height: 12.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: onValidate, child: const Text('Validate'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  changeDate(DateTime? date) {
    if (date != null) {
      this.date = date;
    }
  }

  changeMonthYear(DateTime? date) {
    if (date != null) {
      monthYear = date;
    }
  }

  void onValidate() {
    _form.currentState?.validate();
  }
}
