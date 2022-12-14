import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:date_input_picker/date_utils.dart';
import 'package:date_input_picker/date_input_picker.dart';

import 'about.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DateInputPicker',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Date or M/y Input field and Picker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  DateTime date = DateTime.now();
  DateTime monthYear = toMonthYear(DateTime.now());
  late DateTime firstDate;
  late DateTime lastDate;
  final GlobalKey<FormState> _form = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey();
  DividerVisible dividerVisible = DividerVisible.auto;
  late final TabController _tabController =
      TabController(length: 2, vsync: this);

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
  void initState() {
    final now = DateTime.now();

    firstDate = DateTime(now.year - 50, 1, 1);
    lastDate = DateTime(now.year + 50, 1, 1);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      key: _scaffold,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        bottom: TabBar(
            controller: _tabController,
            labelColor: theme.primaryColor,
            tabs: const [
              Tab(
                text: 'Example',
              ),
              Tab(text: 'About')
            ]),
      ),
      body: Center(
        child: SizedBox(
          width: 900.0,
          child: TabBarView(
            controller: _tabController,
            children: [
              Form(
                key: _form,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView(
                    children: <Widget>[
                      const SizedBox(
                        height: 16.0,
                      ),
                      const Center(
                        child: Text('Change picker in divider button.',
                            style: TextStyle(fontSize: 18.0)),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.center,
                          spacing: 8.0,
                          children: [
                            MyRadio<DividerVisible>(
                              change: changeDividerVisible,
                              text: 'auto',
                              groupValue: dividerVisible,
                              value: DividerVisible.auto,
                            ),
                            MyRadio<DividerVisible>(
                              change: changeDividerVisible,
                              text: 'No',
                              groupValue: dividerVisible,
                              value: DividerVisible.no,
                            ),
                            MyRadio<DividerVisible>(
                              change: changeDividerVisible,
                              text: 'Yes',
                              groupValue: dividerVisible,
                              value: DividerVisible.visible,
                            )
                          ]),
                      const SizedBox(
                        height: 16.0,
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
                          additionalDividers: const ['/', '.', '-'],
                          formatWithUnfocus: formatWithUnfocus,
                          format: dateFormat,
                          labelText: 'Date',
                          formatHint: dateFormat,
                          dateMode: DateMode.date,
                          textInputAction: TextInputAction.next,
                          dividerVisible: dividerVisible,
                          date: date,
                          firstDate: firstDate,
                          lastDate: lastDate,
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
                          additionalDividers: const ['/', '.', '-'],
                          formatWithUnfocus: formatWithUnfocus,
                          format: monthFormat,
                          labelText: 'Month/Year',
                          formatHint: monthFormat,
                          dateMode: DateMode.monthYear,
                          textInputAction: TextInputAction.next,
                          dividerVisible: dividerVisible,
                          date: monthYear,
                          firstDate: firstDate,
                          lastDate: lastDate,
                          changeDate: changeMonthYear,
                          saveDate: changeMonthYear),
                      const SizedBox(
                        height: 12.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: onValidate,
                              child: const Text('Validate'))
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView(
                  children: const [
                    SizedBox(
                      height: 8.0,
                    ),
                    About(),
                  ],
                ),
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
    if (_form.currentState?.validate() ?? false) {
      const snackBar = SnackBar(
        duration: Duration(milliseconds: 500),
        content: Text('Validated'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void changeDividerVisible(DividerVisible? value) {
    if (value == null) return;
    setState(() {
      dividerVisible = value;
    });
  }
}

class MyRadio<T> extends StatelessWidget {
  final T groupValue;
  final T value;
  final ValueChanged<T?> change;
  final String text;

  const MyRadio(
      {super.key,
      required this.groupValue,
      required this.value,
      required this.change,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio(
          groupValue: groupValue,
          value: value,
          onChanged: change,
        ),
        const SizedBox(
          width: 4,
        ),
        Text(text),
      ],
    );
  }
}
