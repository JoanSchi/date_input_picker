// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import '../month_year_picker.dart';

const double _monthPickerPadding = 16.0;
const double _monthPickerRowSpacing = 8.0;
const double _subHeaderHeight = 52.0;
const monthPickerRowHeight = 42.0;
const dividerHeight = 8.0;
const Duration _monthScrollDuration = Duration(milliseconds: 200);

class MonthPicker extends StatefulWidget {
  final DateTime currentDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime initialDate;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;
  final ValueChanged<int> onSwipeYear;
  final DragStartBehavior dragStartBehavior;
  final List<DateTime> disableDate;
  final PickerLayout pickerLayout;

  MonthPicker({
    Key? key,
    DateTime? currentDate,
    required this.firstDate,
    required this.lastDate,
    required this.pickerLayout,
    DateTime? initialDate,
    required this.selectedDate,
    required this.onChanged,
    required this.onSwipeYear,
    this.disableDate = const <DateTime>[],
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(!firstDate.isAfter(lastDate)),
        currentDate = DateUtils.dateOnly(currentDate ?? DateTime.now()),
        initialDate = DateUtils.dateOnly(initialDate ?? selectedDate),
        super(key: key);

  @override
  State<MonthPicker> createState() => _MonthPickerState();

  static calculatePickerLayout({required double availibleHeight}) {
    int column;
    double height;

    if (12.0 * heightPickerItem / availibleHeight >= 2.0) {
      column = 2;
      height = 12 ~/ 2 * heightPickerItem;
    } else {
      column = 1;
      height = 12 * heightPickerItem;
    }

    return PickerLayout(
        columns: column, height: math.min(availibleHeight, height));
  }
}

class _MonthPickerState extends State<MonthPicker> {
  late int _page = widget.selectedDate.year - widget.firstDate.year;
  late final PageController _pageController = PageController(initialPage: _page)
    ..addListener(() {
      if (_page != _pageController.page) {
        setState(() {
          _page = _pageController.page?.roundToDouble().toInt() ?? 0;
          widget.onSwipeYear(_page + widget.firstDate.year);
        });
      }
    });
  late List<DateTime> disabledMonths = widget.disableDate
      .where((DateTime element) => element.year == widget.selectedDate.year)
      .toList();

  late MaterialLocalizations localizations = MaterialLocalizations.of(context);

  late DateTime _selectedDate = widget.selectedDate;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MonthPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      // _scrollController.jumpTo(_scrollOffsetForYear(widget.selectedDate));
      _selectedDate = widget.selectedDate;
    }
  }

  bool get _isDisplayingFirstYear =>
      _selectedDate.year == widget.firstDate.year;

  bool get _isDisplayingLastYear => _selectedDate.year == widget.lastDate.year;

  void _handlePreviousYear() {
    _pageController.previousPage(
        duration: _monthScrollDuration, curve: Curves.ease);
  }

  void _handleNextYear() {
    _pageController.nextPage(
        duration: _monthScrollDuration, curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    assert(debugCheckHasMaterial(context));

    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsetsDirectional.only(top: 4, start: 16, end: 4),
          height: _subHeaderHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                // color: controlColor,
                // tooltip: _isDisplayingFirstYear ? null : previousTooltipText,
                onPressed: _isDisplayingFirstYear ? null : _handlePreviousYear,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                // color: controlColor,
                // tooltip: _isDisplayingLastMonth ? null : nextTooltipText,
                onPressed: _isDisplayingLastYear ? null : _handleNextYear,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: dividerHeight,
        ),
        Expanded(
            child: PageView.builder(
          controller: _pageController,
          itemCount: widget.lastDate.year - widget.firstDate.year + 1,
          itemBuilder: (BuildContext context, int index) {
            final year = widget.firstDate.year + index;

            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Container(
                    decoration: year % 2 != 0
                        ? BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(32.0),
                          )
                        : null,
                    child: LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return _Months(
                        height: constraints.maxHeight,
                        currentDate: widget.currentDate,
                        firstDate: widget.firstDate,
                        lastDate: widget.lastDate,
                        selectedDate: widget.selectedDate,
                        year: year,
                        columns: widget.pickerLayout.columns,
                        onChanged: widget.onChanged,
                      );
                    })));
          },
        )),
      ],
    );
  }
}

class _MonthPickerGridDelegate extends SliverGridDelegate {
  int columnCount;

  _MonthPickerGridDelegate(this.columnCount);

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final double tileWidth = (constraints.crossAxisExtent) / columnCount;
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: heightPickerItem,
      crossAxisCount: columnCount,
      crossAxisStride: tileWidth,
      mainAxisStride: heightPickerItem,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_MonthPickerGridDelegate oldDelegate) => false;
}

String _localeToString(BuildContext context) {
  Locale locale = Localizations.localeOf(context);
  return '${locale.languageCode}_${locale.countryCode}';
}

class _Months extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime selectedDate;
  final DateTime currentDate;
  final int year;
  final int columns;
  final double height;
  final ValueChanged<DateTime> onChanged;

  const _Months({
    Key? key,
    required this.height,
    required this.firstDate,
    required this.lastDate,
    required this.selectedDate,
    required this.currentDate,
    required this.year,
    required this.columns,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<_Months> createState() => _MonthsState();
}

class _MonthsState extends State<_Months> {
  late ScrollController _scrollController;

  @override
  void initState() {
    double initialScrollOffset = 0.0;

    int month = -1;
    if (widget.year == widget.selectedDate.year) {
      month = widget.selectedDate.month;
    } else if (widget.year == widget.currentDate.year) {
      month = widget.currentDate.month;
    }

    if (month != -1) {
      final int initialMonthIndex = month - 1;
      final int initialMonthRow = initialMonthIndex ~/ widget.columns + 1;

      if (widget.height < initialMonthRow * heightPickerItem) {
        initialScrollOffset =
            initialMonthRow * heightPickerItem - widget.height;
      }
    }
    _scrollController =
        ScrollController(initialScrollOffset: initialScrollOffset);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int compareMonths(DateTime date1, DateTime date2) {
    if (date1.year == date2.year) {
      return date1.month - date2.month;
    } else {
      return date1.year - date2.year;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      // dragStartBehavior: widget.dragStartBehavior,
      gridDelegate: _MonthPickerGridDelegate(widget.columns),
      itemBuilder: (BuildContext context, int index) =>
          _buildMonthItem(context, year: widget.year, month: index + 1),
      itemCount: _itemCount,
      padding: const EdgeInsets.symmetric(horizontal: _monthPickerPadding),
    );
  }

  Widget _buildMonthItem(BuildContext context,
      {required int year, required int month}) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final TextTheme textTheme = themeData.textTheme;
    final date = DateTime(year, month);

    final bool isSelected = compareMonths(date, widget.selectedDate) == 0;
    final bool isCurrentMonth = compareMonths(date, widget.currentDate) == 0;

    final bool isDisabled = false;
    //  = compareMonths(date, widget.firstDate) < 0 ||
    //     compareMonths(date, widget.lastDate) > 0 ||
    //     disabledMonths
    //             .indexWhere((DateTime element) => element.month == month) >
    //         -1;

    final Color selectedDayBackground = colorScheme.primary;

    const double decorationHeight = 36.0;
    // const double decorationWidth = 72.0;

    final Color textColor;
    if (isSelected) {
      textColor = colorScheme.onPrimary;
    } else if (isDisabled) {
      textColor = colorScheme.onSurface.withOpacity(0.38);
    } else if (isCurrentMonth) {
      textColor = colorScheme.primary;
    } else {
      textColor = colorScheme.onSurface.withOpacity(0.87);
    }
    TextStyle? itemStyle = textTheme.bodyLarge?.apply(color: textColor);

    BoxDecoration? decoration;
    if (isSelected) {
      decoration = BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(decorationHeight / 2.0),
      );
    } else if (isCurrentMonth && !isDisabled) {
      decoration = BoxDecoration(
        border: Border.all(
          color: colorScheme.primary,
        ),
        borderRadius: BorderRadius.circular(decorationHeight / 2.0),
      );
    }

    final monthInText = DateFormat.MMMM(_localeToString(context)).format(date);

    Widget monthItem = Padding(
      padding: const EdgeInsets.all(_monthPickerRowSpacing),
      child: Center(
        child: Container(
          decoration: decoration,
          child: Center(
            child: Semantics(
              selected: isSelected,
              child: Text(monthInText, style: itemStyle),
            ),
          ),
        ),
      ),
    );

    if (isDisabled) {
      monthItem = ExcludeSemantics(
        child: monthItem,
      );
    } else {
      monthItem = InkWell(
        splashColor: selectedDayBackground.withOpacity(0.38),
        key: ValueKey<int>(month),
        onTap: () => widget.onChanged(DateTime(year, month)),
        borderRadius: BorderRadius.circular(heightPickerItem / 2.0),
        child: monthItem,
      );
    }

    return monthItem;
  }

  int get _itemCount {
    return 12;
  }
}
