import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'date_utils.dart';
import 'month_year_picker.dart';

class MonthYearInputPicker extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? date;
  final ValueChanged<DateTime?>? changeDate;
  final ValueChanged<DateTime?>? saveDate;
  final TextInputType? textInputType;
  final List<String> dateDividers;

  const MonthYearInputPicker(
      {Key? key,
      required this.date,
      required this.firstDate,
      required this.lastDate,
      required this.changeDate,
      required this.saveDate,
      this.textInputType,
      this.dateDividers = const ['-', '/']})
      : super(key: key);

  @override
  State<MonthYearInputPicker> createState() => _MonthYearInputPickerState();
}

class _MonthYearInputPickerState extends State<MonthYearInputPicker> {
  late DateTime? _date = widget.date;
  late TextEditingController _dateController;
  late RegExp regExpDateInput = RegExp(r'^[0-9]{1,2}([-|.][0-9]{0,4})?');
  late RegExp regExpDateValidate = RegExp(r'^[0-9]{1,2}([-|.][0-9]{2,4})');
  late RegExp regExpShowDivider = RegExp(r'^[0-9]{1,2}$');
  final FocusNode _dateNode = FocusNode();
  bool showDivider = false;
  late String divider;

  @override
  void initState() {
    setDividers();
    _dateController = TextEditingController(text: dateToMonthYearText(_date));
    super.initState();
  }

  @override
  void didUpdateWidget(MonthYearInputPicker oldWidget) {
    setDividers();
    super.didUpdateWidget(oldWidget);
  }

  setDividers() {
    List<String> dateDividers = widget.dateDividers;
    int length = dateDividers.length;
    int i = 0;

    String regDivider = divider = (length < 0) ? '/' : dateDividers[0];

    while (i < length) {
      regDivider += '|${dateDividers[i++]}';
    }

    regExpDateInput = RegExp(r'^[0-9]{1,2}([' + regDivider + r'][0-9]{0,4})?');
    regExpDateValidate =
        RegExp(r'^[0-9]{1,2}([' + regDivider + r'][0-9]{2,4})');
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textField = Focus(
        onFocusChange: (bool value) {
          if (!value) {
            setDateFromTextField(validateDate(_dateController.text).date);
          }
        },
        child: TextFormField(
          focusNode: _dateNode,
          controller: _dateController,
          keyboardType: widget.textInputType ?? TextInputType.datetime,
          inputFormatters: [FilteringTextInputFormatter.allow(regExpDateInput)],
          decoration: const InputDecoration(
            // icon: Icon(Icons.person),
            hintText: 'mm-yyyy of mm.yyyy',
            labelText: 'Datum',
            // helperText: monthYearText
          ),
          validator: (String? value) {
            return validateDate(value).error;
          },
          onSaved: (String? value) {
            DateTime? date = validateDate(value).date;
            if (date != null) widget.saveDate?.call(date);
          },
          onFieldSubmitted: (String text) {
            setDateFromTextField(validateDate(text).date);
          },
          onChanged: checkDivider,
        ));

    Widget divider = IconButton(
        key: const Key('divider'),
        onPressed: () {
          String text = _dateController.text;
          if (!text.contains('-')) {
            int offset = _dateController.selection.baseOffset;

            text = '${text.substring(0, offset)}-${text.substring(offset)}';
            _dateController
              ..text = text
              ..selection = TextSelection.collapsed(offset: offset + 1);

            checkDivider(text);
          }
        },
        icon: const Icon(Icons.remove));

    Widget picker = IconButton(
        key: const Key('picker'),
        icon: const Icon(Icons.calendar_today),
        onPressed: () {
          DateTime? date = _date;
          if (_dateNode.hasFocus) {
            date = validateDate(_dateController.text).date;
            _dateNode.unfocus();
          }
          showMonthYearPicker(
                  context: context,
                  initialDate: date ?? toMonthYear(DateTime.now()),
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate)
              .then((value) {
            if (value != null) {
              setDateFromPicker(value);
            }
          });
        });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: textField),
        AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: showDivider ? divider : picker)
      ],
    );
  }

  setDateFromTextField(DateTime? value) {
    widget.changeDate?.call(value);

    _date = value;
  }

  void checkDivider(String value) {
    bool show = regExpShowDivider.hasMatch(value);

    if (show != showDivider) {
      setState(() {
        showDivider = show;
      });
    }
  }

  String dateToMonthYearText(DateTime? value) {
    return value == null
        ? ''
        : '${value.month < 9 ? '0' : ''}${value.month}$divider${value.year}';
  }

  setDateFromPicker(DateTime value) {
    _date = value;

    _dateController.text = dateToMonthYearText(value);

    widget.changeDate?.call(value);

    Timer(const Duration(milliseconds: 5), () {
      if (_dateNode.hasFocus) {
        if (!_dateNode.nextFocus()) {
          _dateNode.unfocus();
        }
      }
    });
  }

  MonthYearValidated validateDate(String? value) {
    if (value != null) {
      if (value.startsWith(regExpDateValidate)) {
        List<String> split = [];
        for (String d in widget.dateDividers) {
          if (value.contains(d)) {
            split = value.split(d);
            break;
          }
        }

        if (split.isEmpty) {
          return MonthYearValidated(error: ' : Try: mm${divider}yyyy');
        }

        int month = int.parse(split[0]);

        if (month < 1 || month > 12) {
          return MonthYearValidated(error: ' Use mm: 1-12');
        }

        String yearText = split[1];
        int year = 0;

        switch (yearText.length) {
          case 2:
            {
              year = int.parse('20$yearText');
              break;
            }
          case 4:
            {
              year = int.parse(yearText);
              break;
            }
          default:
            {
              return MonthYearValidated(error: ' Use last yy or yyyy');
            }
        }

        DateTime dateFromInput = DateTime(year, month);

        if (DateUtils.monthDelta(widget.firstDate, dateFromInput) < 0) {
          return MonthYearValidated(error: 'Te ..');
        } else if (DateUtils.monthDelta(widget.lastDate, dateFromInput) > 0) {
          return MonthYearValidated(error: 'Te ...');
        } else {
          return MonthYearValidated(date: dateFromInput);
        }
      } else {
        return MonthYearValidated(error: 'Use mm-yyyy');
      }
    }
    return MonthYearValidated(error: 'Empty');
  }
}

class MonthYearValidated {
  DateTime? date;
  String? error;
  MonthYearValidated({
    this.date,
    this.error,
  });
}
