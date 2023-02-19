library date_input_picker;

import 'dart:async';
import 'package:date_input_picker/src/calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'date_utils.dart';
import 'month_year_picker.dart';

enum DividerVisible { auto, no, visible }

enum DateMode { date, monthYear }

class DateInputPicker extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? date;
  final ValueChanged<DateTime?>? changeDate;
  final ValueChanged<DateTime?>? saveDate;
  final TextInputType? textInputType;
  final List<String>? additionalDividers;
  final DividerVisible dividerVisible;
  final Widget? dividerIcon;
  final double? iconSize;
  final String labelText;
  final String formatHint;
  final TextInputAction textInputAction;
  final DateMode dateMode;
  final String? format;
  final bool formatWithUnfocus;

  const DateInputPicker(
      {Key? key,
      this.dateMode = DateMode.date,
      required this.date,
      required this.firstDate,
      required this.lastDate,
      required this.changeDate,
      required this.saveDate,
      this.textInputType,
      this.additionalDividers,
      this.dividerVisible = DividerVisible.auto,
      this.dividerIcon,
      this.iconSize,
      this.textInputAction = TextInputAction.done,
      this.labelText = '',
      this.formatHint = '',
      this.format,
      this.formatWithUnfocus = true})
      : assert(dividerIcon == null || iconSize != null,
            'The size of the custom dividerIcon should be set by the user.'),
        super(key: key);

  @override
  State<DateInputPicker> createState() => _DateInputPickerState();
}

class _DateInputPickerState extends State<DateInputPicker> {
  late DateTime? _date = widget.date;
  late TextEditingController _dateController;
  late RegExp regExpDateInput; // = RegExp(r'^[0-9]{1,2}([-|.][0-9]{0,4})?');
  late RegExp regExpDateValidate; // = RegExp(r'^[0-9]{1,2}([-|.][0-9]{2,4})');
  late RegExp regExpShowDivider; // = RegExp(r'^[0-9]{1,2}$');
  late RegExp splitDateRegExp = RegExp(r'[0-9]{1,4}');
  final FocusNode _dateNode = FocusNode();
  bool dividerVisible = false;
  bool useDividerButton = false;
  String divider = '';
  Widget? iconDivider;
  String format = '';
  final orderRegExp = RegExp(r'([A-Za-z]{1,4})*');
  final formatRegExp = RegExp(r'([A-Za-z]{1,4})|([.|/|-]\s?)');
  final dividerRegExp = RegExp(r'([^0-9^A-Z^a-z^\s])');
  final spaceRegExp = RegExp(r'\s');
  int numberOfDividers = 0;
  String previousValidation = '';

  @override
  void initState() {
    setFormat();
    setDividers();
    _dateController = TextEditingController(text: dateToText(_date))
      ..selection
      ..addListener(selectionListener);
    super.initState();

    if (widget.formatWithUnfocus) {
      _dateNode.addListener(focusListener);
    }
  }

  @override
  void didChangeDependencies() {
    setIconDivider();

    // for (String l in ['nl', 'de', 'en', 'uk']) {
    //   final p = dateTimePatternMap()[l]?['yMd'];
    //   debugPrint('$l: $p');
    // }

    super.didChangeDependencies();
  }

  void focusListener() {
    if (!_dateNode.hasFocus) {
      if (_dateController.text != previousValidation) {
        validateDate(_dateController.text);
      }
    }
  }

  @override
  void didUpdateWidget(DateInputPicker oldWidget) {
    final oldFormat = format;
    setFormat();

    final oldDivider = divider;
    setDividers();

    if (oldDivider != divider ||
        oldWidget.dividerVisible != widget.dividerVisible ||
        oldWidget.iconSize != widget.iconSize ||
        oldWidget.dividerIcon != widget.dividerIcon) {
      setIconDivider();
    }

    if (widget.formatWithUnfocus && !oldWidget.formatWithUnfocus) {
      _dateNode.addListener(focusListener);
    } else if (!widget.formatWithUnfocus && oldWidget.formatWithUnfocus) {
      _dateNode.removeListener(focusListener);
    }

    if (oldFormat != format || _date != widget.date) {
      _date = widget.date;
      _dateController = TextEditingController(text: dateToText(_date))
        ..selection
        ..addListener(selectionListener);
    }

    super.didUpdateWidget(oldWidget);
  }

  void setFormat() {
    switch (widget.dateMode) {
      case DateMode.date:
        format = widget.format ?? 'y/M/d';
        break;
      case DateMode.monthYear:
        format = widget.format ?? 'y/M';
        break;
    }
  }

  setDividers() {
    final dividersInFormat = dividerRegExp.allMatches(format);
    final ad = widget.additionalDividers ?? [];

    bool first = true;
    String regDivider = '';
    numberOfDividers = 0;

    for (RegExpMatch m in dividersInFormat) {
      final d = m.group(0);

      if (d != null) {
        if (first) {
          divider = d;
          first = false;
        }
        if (!ad.contains(d)) {
          ad.add(d);
        }
        numberOfDividers++;
      }
    }

    int length = ad.length;
    int i = 0;

    if (length > 0) {
      regDivider = ad[i++];
    } else {
      regDivider = '/';
    }

    if (first) {
      divider = regDivider;
    }

    while (i < length) {
      regDivider += '|${ad[i++]}';
    }

    bool space = spaceRegExp.hasMatch(format);

    switch (widget.dateMode) {
      case DateMode.date:
        regExpShowDivider =
            RegExp(r'^[0-9]+([' + regDivider + r']\s?[0-9]+){0,1}$');
        break;
      case DateMode.monthYear:
        regExpShowDivider = RegExp(r'[0-9]+$');
        break;
    }
    regExpShowDivider = RegExp(r'[0-9]+$');

    regExpDateInput = RegExp(r'[0-9|' + regDivider + (space ? r'|\s]' : ']'));
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
    } else {
      iconDivider = null;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget textField = TextFormField(
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
    );

    final id = iconDivider;

    Widget? dividerButton = id != null
        ? IconButton(
            key: const Key('divider'),
            onPressed: () {
              String text = _dateController.text;
              int offset = _dateController.selection.baseOffset;

              text =
                  '${text.substring(0, offset)}$divider${text.substring(offset)}';
              _dateController
                ..text = text
                ..selection = TextSelection.collapsed(offset: offset + 1);
            },
            icon: id,
          )
        : null;

    Widget picker = IconButton(
      key: const Key('picker'),
      icon: widget.dateMode == DateMode.date
          ? const Icon(Icons.calendar_today)
          : const Icon(Icons.calendar_month),
      onPressed: () {
        DateTime? date = _date;

        _dateNode.unfocus();

        switch (widget.dateMode) {
          case DateMode.date:
            showDatePicker(
                    context: context,
                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                    initialDate: date ?? DateUtils.dateOnly(DateTime.now()),
                    firstDate: widget.firstDate,
                    lastDate: widget.lastDate)
                .then((value) {
              if (value != null) {
                setDateFromPicker(value);
              }
            });
            break;
          case DateMode.monthYear:
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
            break;
        }
      },
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: textField),
        Focus(
            skipTraversal: true,
            descendantsAreFocusable: false,
            descendantsAreTraversable: false,
            child: dividerButton != null
                ? AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: dividerVisible ? dividerButton : picker)
                : picker)
      ],
    );
  }

  setDateFromTextField(DateTime? value) {
    widget.changeDate?.call(value);
    _date = value;
  }

  void selectionListener() {
    final offset = _dateController.selection.baseOffset;

    if (offset < 0) {
      return;
    }

    final text = _dateController.text;
    bool show;

    if (dividerRegExp.allMatches(text).length < numberOfDividers) {
      final length = text.length;

      show = regExpShowDivider
          .hasMatch(text.substring(0, offset > length ? length : offset));
    } else {
      show = false;
    }

    showDivider(show);
  }

  void showDivider(bool show) {
    if (show != dividerVisible) {
      dividerVisible = show;

      setState(() {});
    }
  }

  String dateToText(DateTime? value) {
    return value != null ? DateFormat(format).format(value) : '';
  }

  setDateFromPicker(DateTime value) {
    _date = value;
    _dateController.text = dateToText(value);
    widget.changeDate?.call(value);
  }

  DateValidated validateDate(String? value) {
    if (value != null) {
      previousValidation = value;

      final List<String?> numbers = splitDateRegExp
          .allMatches(value)
          .map<String?>((e) => e.group(0))
          .where((e) => (e != ''))
          .toList();
      final List<String?> order = orderRegExp
          .allMatches(format)
          .map<String?>((e) => e.group(0))
          .where((e) => (e != ''))
          .toList();

      int day = (widget.dateMode == DateMode.monthYear) ? 1 : -1;
      int month = -1;
      int year = -1;

      int toInt(String? value) {
        return value == null ? 0 : int.parse(value);
      }

      int missing = order.length - numbers.length;

      bool yearMissing = missing >= 1;
      bool monthMissing = missing >= 2;
      bool dayMissing = missing == 3;

      if (missing < 0) {
        return DateValidated(error: 'To many Arguments');
      }

      int j = 0;
      for (int i = 0; i < order.length; i++) {
        String? o = order[i];

        if (o == null) {
          return DateValidated(error: '?');
        } else if ((o == 'd' || o == 'dd') && dayMissing) {
          day = DateTime.now().day;
          continue;
        } else if (o == 'y' && yearMissing) {
          year = DateTime.now().year;
          continue;
        } else if ((o == 'M' || o == 'MM') && monthMissing) {
          month = DateTime.now().month;
          continue;
        }

        String? n = j < numbers.length ? numbers[j++] : null;

        if (n == null) {
          return DateValidated(error: '?');
        } else if (o == 'y') {
          if (n.length == 2) {
            year = 2000 + toInt(n);
          } else if (n.length == 4) {
            year = toInt(n);
          }
        } else if (o == 'M' || o == 'MM') {
          month = toInt(n);
        } else if (o == 'd' || o == 'dd') {
          day = toInt(n);
        }
      }

      debugPrint('day: $day, month: $month, year; $year');

      if (day == -1 || month == -1 || year == -1) {
        return DateValidated(error: widget.formatHint);
      } else if (month > 12) {
        return DateValidated(error: 'M: 1..12');
      } else if (day < 1) {
        return DateValidated(error: 'd: 1..');
      } else if (day > daysInMonth(month: month, years: year)) {
        return DateValidated(
            error: 'd: 1..${daysInMonth(month: month, years: year)}');
      } else {
        DateTime dateFromInput = DateTime(year, month, day);

        debugPrint('dateFromInput to string $dateFromInput');

        if (DateUtils.monthDelta(widget.firstDate, dateFromInput) < 0 ||
            DateUtils.monthDelta(widget.lastDate, dateFromInput) > 0) {
          return DateValidated(
              error:
                  '${dateToText(widget.firstDate)}..${dateToText(widget.lastDate)}');
        } else {
          final formated = dateToText(dateFromInput);
          if (formated != value) {
            _dateController.text = previousValidation = formated;
          }
          scheduleMicrotask(() {
            showDivider(false);
          });

          return DateValidated(date: dateFromInput);
        }
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
