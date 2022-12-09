import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'date_utils.dart';
import 'month_year_picker.dart';

enum DividerVisible { auto, no, visible }

enum DateMode { date, monthYear }

class MonthYearInputPicker extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? date;
  final ValueChanged<DateTime?>? changeDate;
  final ValueChanged<DateTime?>? saveDate;
  final TextInputType? textInputType;
  final List<String> dateDividers;
  final DividerVisible dividerVisible;
  final Widget? dividerIcon;
  final double? iconSize;
  final String labelText;
  final String formatHint;
  final TextInputAction textInputAction;
  final DateMode dateMode;

  const MonthYearInputPicker(
      {Key? key,
      this.dateMode = DateMode.date,
      required this.date,
      required this.firstDate,
      required this.lastDate,
      required this.changeDate,
      required this.saveDate,
      this.textInputType,
      this.dateDividers = const ['-', '/'],
      this.dividerVisible = DividerVisible.auto,
      this.dividerIcon,
      this.iconSize,
      this.textInputAction = TextInputAction.done,
      this.labelText = 'Month/Year',
      this.formatHint = 'mm/yyyy'})
      : assert(dividerIcon == null || iconSize != null,
            'The size of the custom dividerIcon should be set by the user.'),
        super(key: key);

  @override
  State<MonthYearInputPicker> createState() => _MonthYearInputPickerState();
}

class _MonthYearInputPickerState extends State<MonthYearInputPicker> {
  late DateTime? _date = widget.date;
  late TextEditingController _dateController;
  late RegExp regExpDateInput; // = RegExp(r'^[0-9]{1,2}([-|.][0-9]{0,4})?');
  late RegExp regExpDateValidate; // = RegExp(r'^[0-9]{1,2}([-|.][0-9]{2,4})');
  late RegExp regExpShowDivider; // = RegExp(r'^[0-9]{1,2}$');
  late RegExp splitDate = RegExp(r'[0-9]{1,4}');
  final FocusNode _dateNode = FocusNode();
  bool dividerVisible = false;
  bool useDividerButton = false;
  late String divider;
  Widget? iconDivider;

  @override
  void initState() {
    setDividers();
    _dateController = TextEditingController(text: dateToText(_date));
    super.initState();
  }

  @override
  void didChangeDependencies() {
    setIconDivider();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(MonthYearInputPicker oldWidget) {
    setDividers();

    if ((widget.dateDividers.isNotEmpty && divider != widget.dateDividers[0]) ||
        oldWidget.iconSize != widget.iconSize ||
        oldWidget.dividerIcon != widget.dividerIcon) {
      setIconDivider();
    }

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

    switch (widget.dateMode) {
      case DateMode.date:
        regExpDateInput = RegExp(r'^[0-9]{1,2}([' +
            regDivider +
            r']([0-9]{1,2}([' +
            regDivider +
            r'][0-9]{0,4})?)?)?');

        regExpDateValidate = RegExp(r'^[0-9]{1,2}[' +
            regDivider +
            r'][0-9]{1,2}([' +
            regDivider +
            r'][0-9]{2,4})');

        regExpShowDivider = RegExp(r'^[0-9]{1,2}([/|-][0-9]{1,2}){0,1}$');
        break;
      case DateMode.monthYear:
        regExpDateInput =
            RegExp(r'^[0-9]{1,2}([' + regDivider + r'][0-9]{0,4})?');
        regExpDateValidate =
            RegExp(r'^[0-9]{1,2}([' + regDivider + r'][0-9]{2,4})');

        regExpShowDivider = RegExp(r'^[0-9]{1,2}$');
        break;
    }

    // regExpDateInput = RegExp(r'^[0-9]{1,2}([' + regDivider + r'][0-9]{0,4})?');
    // regExpDateValidate =
    //     RegExp(r'^[0-9]{1,2}([' + regDivider + r'][0-9]{2,4})');
  }

  setIconDivider() {
    switch (widget.dividerVisible) {
      case DividerVisible.auto:
        {
          switch (defaultTargetPlatform) {
            case TargetPlatform.android:
            case TargetPlatform.fuchsia:
            case TargetPlatform.iOS:
              useDividerButton = true;
              break;
            case TargetPlatform.linux:
            case TargetPlatform.macOS:
            case TargetPlatform.windows:
              useDividerButton = false;
              break;
          }
          break;
        }
      case DividerVisible.no:
        {
          useDividerButton = false;
          break;
        }
      case DividerVisible.visible:
        {
          useDividerButton = true;
          break;
        }
    }

    if (useDividerButton) {
      iconDivider = widget.dividerIcon;

      if (iconDivider == null) {
        final iconSize =
            widget.iconSize ?? Theme.of(context).iconTheme.size ?? 24.0;
        switch (divider) {
          case '/':
            {
              iconDivider = Image.asset(
                'graphics/slash.png',
                package: 'date_input_picker',
                width: iconSize,
                height: iconSize,
              );
              break;
            }
          case '-':
            {
              iconDivider = Image.asset(
                'graphics/min.png',
                package: 'date_input_picker',
                width: iconSize,
                height: iconSize,
              );
              break;
            }
          case '.':
            {
              iconDivider = Image.asset(
                'graphics/point.png',
                package: 'date_input_picker',
                width: iconSize,
                height: iconSize,
              );
              break;
            }
          default:
            {
              iconDivider = Image.asset(
                'graphics/unknown.png',
                package: 'date_input_picker',
                width: iconSize,
                height: iconSize,
              );
            }
        }
      } else {
        iconDivider = null;
      }
    }
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
          textInputAction: widget.textInputAction,
          inputFormatters: [FilteringTextInputFormatter.allow(regExpDateInput)],
          decoration: InputDecoration(
            hintText: widget.formatHint,
            labelText: widget.labelText,
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
          onChanged: useDividerButton ? checkDivider : null,
        ));

    final id = iconDivider;

    Widget? dividerButton = id != null
        ? IconButton(
            focusNode: FocusNode(skipTraversal: true),
            key: const Key('divider'),
            onPressed: () {
              String text = _dateController.text;

              int offset = _dateController.selection.baseOffset;

              text =
                  '${text.substring(0, offset)}$divider${text.substring(offset)}';
              _dateController
                ..text = text
                ..selection = TextSelection.collapsed(offset: offset + 1);

              checkDivider(text);
            },
            icon: id,
          )
        : null;

    Widget picker = IconButton(
      focusNode: FocusNode(skipTraversal: true),
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
      },
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: textField),
        dividerButton != null
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: dividerVisible ? dividerButton : picker)
            : picker
      ],
    );
  }

  setDateFromTextField(DateTime? value) {
    widget.changeDate?.call(value);
    _date = value;
  }

  void checkDivider(String value) {
    bool show = regExpShowDivider.hasMatch(value);

    if (show != dividerVisible) {
      setState(() {
        dividerVisible = show;
      });
    }
  }

  String dateToText(DateTime? value) {
    String text = '';

    if (value != null) {
      if (widget.dateMode == DateMode.date) {
        text = '${value.day < 9 ? '0' : ''}${value.day}$divider';
      }
      text +=
          '${value.month < 9 ? '0' : ''}${value.month}$divider${value.year}';
    }
    return text;
  }

  setDateFromPicker(DateTime value) {
    _date = value;
    _dateController.text = dateToText(value);
    widget.changeDate?.call(value);
  }

  DateValidated validateDate(String? value) {
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
          return DateValidated(error: widget.formatHint);
        }

        int month = int.parse(split[0]);

        if (month < 1 || month > 12) {
          return DateValidated(error: 'mm: 1..12');
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
              return DateValidated(error: widget.formatHint);
            }
        }

        DateTime dateFromInput = DateTime(year, month);

        if (DateUtils.monthDelta(widget.firstDate, dateFromInput) < 0 ||
            DateUtils.monthDelta(widget.lastDate, dateFromInput) > 0) {
          return DateValidated(
              error:
                  '${dateToText(widget.firstDate)}..${dateToText(widget.lastDate)}');
        } else {
          return DateValidated(date: dateFromInput);
        }
      } else {
        return DateValidated(error: widget.formatHint);
      }
    }
    return DateValidated(error: widget.formatHint);
  }
}

class DateValidated {
  DateTime? date;
  String? error;
  DateValidated({
    this.date,
    this.error,
  });
}
