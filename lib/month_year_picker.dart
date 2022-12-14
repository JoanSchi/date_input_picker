library month_year_picker;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'src/month_picker.dart';
import 'src/month_year_layout.dart';
import 'src/year_picker.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

// const double _kDatePickerHeaderPortraitHeight = 100.0;
const double _kDatePickerHeaderLandscapeWidth = 220.0;
const double _monthNavButtonsWidth = 108.0;
const double _subHeaderHeight = 52.0;
const dividerHeight = 8.0;
const double decorationHeight = 36.0;
const double decorationBorder = 8.0;
const double heightPickerItem = decorationHeight + 2.0 * decorationBorder;

const actionButtonHeight = 56.0;

enum YearMonthPickerMode {
  month,
  year,
}

class PickerLayout {
  final int columns;
  final double height;

  PickerLayout({required this.columns, required this.height});
}

Future<DateTime?> showMonthYearPicker(
    {required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate}) async {
  return await showDialog<DateTime>(
    context: context,
    builder: (context) => _MonthYearPickerDialog(
        initialDate: initialDate, firstDate: firstDate, lastDate: lastDate),
  );
}

class _MonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate, firstDate, lastDate;

  const _MonthYearPickerDialog(
      {Key? key,
      required this.initialDate,
      required this.firstDate,
      required this.lastDate})
      : super(key: key);

  @override
  _MonthYearPickerDialogState createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  // YearMonthPickerMode _mode = YearMonthPickerMode.month;
  late DateTime _selectedDate =
      DateTime(widget.initialDate.year, widget.initialDate.month);
  late final DateTime _currentDate = monthYearOnly(DateTime.now());
  late PickerLayout layoutYearPicker;
  late PickerLayout layoutMonthPicker;

  static DateTime monthYearOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  void didUpdateWidget(_MonthYearPickerDialog oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialDate != oldWidget.initialDate ||
        widget.firstDate != oldWidget.firstDate ||
        widget.lastDate != oldWidget.lastDate) {
      _selectedDate =
          DateTime(widget.initialDate.year, widget.initialDate.month);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  setDate(DateTime date) {
    if (date != _selectedDate) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final orientation = mediaQuery.orientation;

    final localizations = MaterialLocalizations.of(context);
    final locale = _localeToString(context);

    final header = buildHeader(theme, locale, orientation);

    return Dialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(builder: (context, BoxConstraints constraints) {
          final calenderPicker = CalendarPicker(
            currentDate: _currentDate,
            initialYearMonthPickerMode: YearMonthPickerMode.month,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            selectedDate: _selectedDate,
            changeDate: setDate,
          );

          if (orientation == Orientation.portrait) {
            return Container(
              constraints: BoxConstraints.loose(
                  Size(constraints.constrainWidth(360), constraints.maxHeight)),
              child: MyFlex(direction: Axis.vertical, children: [
                header,
                MyFlexible(
                  fit: MyFlexFit.fill,
                  child: calenderPicker,
                ),
                buildButtonBar(context, localizations)
              ]),
            );
          } else {
            return ConstrainedBox(
              constraints: BoxConstraints.loose(
                  Size(constraints.constrainWidth(600), constraints.maxHeight)),
              child: MyFlex(direction: Axis.horizontal, children: [
                SizedBox(
                    width: _kDatePickerHeaderLandscapeWidth, child: header),
                MyFlexible(
                    fit: MyFlexFit.fill,
                    child: MyFlex(
                      direction: Axis.vertical,
                      children: [
                        MyFlexible(
                          fit: MyFlexFit.fill,
                          child: calenderPicker,
                        ),
                        buildButtonBar(context, localizations)
                      ],
                    ))
              ]),
            );
          }
        }));
  }

  Widget buildButtonBar(
      BuildContext context, MaterialLocalizations localizations) {
    return SizedBox(
      height: actionButtonHeight,
      child: ButtonBar(
        children: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(localizations.cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _selectedDate),
            child: Text(localizations.okButtonLabel),
          )
        ],
      ),
    );
  }

  Widget buildHeader(ThemeData theme, String locale, Orientation orientation) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    final ColorScheme colorScheme = theme.colorScheme;

    final Color onPrimarySurface = colorScheme.brightness == Brightness.light
        ? colorScheme.onPrimary
        : colorScheme.onSurface;

    final TextStyle? yearStyle =
        theme.textTheme.headline4?.copyWith(color: onPrimarySurface);
    final TextStyle? monthStyle =
        theme.textTheme.headline4?.copyWith(color: onPrimarySurface);

    Widget year =
        Text(localizations.formatYear(_selectedDate), style: yearStyle);

    Widget month =
        Text(DateFormat.MMMM(locale).format(_selectedDate), style: monthStyle);

    return Material(
      color: theme.primaryColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8.0),
          month,
          year,
          const SizedBox(height: 8.0)
        ],
      ),
    );
  }
}

class CalendarPicker extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime selectedDate;
  final DateTime currentDate;
  final YearMonthPickerMode initialYearMonthPickerMode;

  final ValueChanged<DateTime> changeDate;

  const CalendarPicker(
      {Key? key,
      required this.firstDate,
      required this.lastDate,
      required this.selectedDate,
      required this.currentDate,
      required this.initialYearMonthPickerMode,
      required this.changeDate})
      : super(key: key);

  @override
  State<CalendarPicker> createState() => _CalendarPickerState();
}

class _CalendarPickerState extends State<CalendarPicker> {
  YearMonthPickerMode _mode = YearMonthPickerMode.month;
  late DateTime _selectedDate = widget.selectedDate;
  late int _year = widget.selectedDate.year;

  @override
  void didUpdateWidget(CalendarPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialYearMonthPickerMode !=
        oldWidget.initialYearMonthPickerMode) {
      _mode = widget.initialYearMonthPickerMode;
    }
    if (!DateUtils.isSameDay(widget.selectedDate, oldWidget.selectedDate)) {
      _selectedDate = widget.selectedDate;
    }
  }

  void _handleMonthChanged(DateTime date) {
    widget.changeDate(date);
  }

  void _handleYearChanged(DateTime date) {
    _mode = YearMonthPickerMode.month;
    _year = date.year;
    widget.changeDate(date);
  }

  void _onSwipeYear(int value) {
    setState(() {
      _year = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final size = constraints.biggest;

      final PickerLayout monthLayoutPicker = MonthPicker.calculatePickerLayout(
        availibleHeight: math.min(
            size.height - _subHeaderHeight - dividerHeight * 2.0,
            12.0 * heightPickerItem),
      );

      final PickerLayout yearLayoutPicker = MyYearPicker.calculateHeightAndRows(
          availibleHeight: math.min(
              size.height - _subHeaderHeight - dividerHeight * 2.0,
              12.0 * heightPickerItem),
          firstDate: widget.firstDate,
          lastDate: widget.lastDate);

      double heightMonthPicker =
          monthLayoutPicker.height + _subHeaderHeight + dividerHeight * 2.0;

      double heightYearPeaker =
          yearLayoutPicker.height + _subHeaderHeight + dividerHeight * 2.0;

      double height = (heightMonthPicker > heightYearPeaker
          ? heightMonthPicker
          : heightYearPeaker);

      // height = constraints.constrainHeight(height);

      final picker = _mode == YearMonthPickerMode.month
          ? MonthPicker(
              pickerLayout: monthLayoutPicker,
              selectedDate: _selectedDate,
              currentDate: widget.currentDate,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              onChanged: _handleMonthChanged,
              onSwipeYear: _onSwipeYear,
            )
          : Padding(
              padding: const EdgeInsets.only(top: _subHeaderHeight),
              child: MyYearPicker(
                pickerLayout: yearLayoutPicker,
                currentDate: widget.currentDate,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                selectedDate: _selectedDate,
                onChanged: _handleYearChanged,
              ));

      return ConstrainedBox(
        constraints: constraints.tighten(height: height),
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: picker),
            // Put the mode toggle button on top so that it won't be covered up by the _MonthPicker
            _DatePickerModeToggleButton(
              mode: _mode,
              title: _year.toString(),
              onTitlePressed: () {
                // Toggle the day/year mode.
                _handleModeChanged(_mode == YearMonthPickerMode.month
                    ? YearMonthPickerMode.year
                    : YearMonthPickerMode.month);
              },
            ),
          ],
        ),
      );
    });
  }

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        HapticFeedback.vibrate();
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
  }

  void _handleModeChanged(YearMonthPickerMode mode) {
    _vibrate();
    setState(() {
      _mode = mode;
    });
  }
}

String _localeToString(BuildContext context) {
  Locale locale = Localizations.localeOf(context);
  return '${locale.languageCode}_${locale.countryCode}';
}

class _DatePickerModeToggleButton extends StatefulWidget {
  const _DatePickerModeToggleButton({
    required this.mode,
    required this.title,
    required this.onTitlePressed,
  });

  /// The current display of the calendar picker.
  final YearMonthPickerMode mode;

  /// The text that displays the current month/year being viewed.
  final String title;

  /// The callback when the title is pressed.
  final VoidCallback onTitlePressed;

  @override
  _DatePickerModeToggleButtonState createState() =>
      _DatePickerModeToggleButtonState();
}

class _DatePickerModeToggleButtonState
    extends State<_DatePickerModeToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: widget.mode == YearMonthPickerMode.year ? 0.5 : 0,
      upperBound: 0.5,
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_DatePickerModeToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode == widget.mode) {
      return;
    }

    if (widget.mode == YearMonthPickerMode.year) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color controlColor = colorScheme.onSurface.withOpacity(0.60);

    return Container(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 16, top: 5.0),
      height: _subHeaderHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Semantics(
              label: MaterialLocalizations.of(context).selectYearSemanticsLabel,
              excludeSemantics: true,
              button: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(32),
                onTap: widget.onTitlePressed,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          widget.title,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.subtitle2?.copyWith(
                            color: controlColor,
                          ),
                        ),
                      ),
                      RotationTransition(
                        turns: _controller,
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: controlColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (widget.mode == YearMonthPickerMode.month)
            // Give space for the prev/next month buttons that are underneath this row
            const SizedBox(width: _monthNavButtonsWidth),
        ],
      ),
    );
  }
}
