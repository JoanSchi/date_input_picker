import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

class MyFlex extends MultiChildRenderObjectWidget {
  MyFlex({
    Key? key,
    required this.direction,
    List<Widget> children = const <Widget>[],
  }) : super(key: key, children: children);

  final Axis direction;

  @override
  MyRenderFlex createRenderObject(BuildContext context) {
    return MyRenderFlex(
      direction: direction,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant MyRenderFlex renderObject) {
    renderObject.direction = direction;
  }
}

enum MyFlexFit {
  tight,
  fill,
}

class MyFlexible extends ParentDataWidget<MyFlexParentData> {
  /// Creates a widget that controls how a child of a [Row], [Column], or [Flex]
  /// flexes.
  const MyFlexible({
    Key? key,
    this.fit = MyFlexFit.tight,
    required Widget child,
  }) : super(key: key, child: child);

  final MyFlexFit fit;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is MyFlexParentData);
    final MyFlexParentData parentData =
        renderObject.parentData! as MyFlexParentData;
    bool needsLayout = false;

    if (parentData.fit != fit) {
      parentData.fit = fit;
      needsLayout = true;
    }

    if (needsLayout) {
      final AbstractNode? targetParent = renderObject.parent;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => Flex;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty('flex', fit));
  }
}

typedef _ChildSizingFunction = double Function(RenderBox child, double extent);

class MyFlexParentData extends ContainerBoxParentData<RenderBox> {
  MyFlexFit fit = MyFlexFit.tight;

  @override
  String toString() => '${super.toString()}; fit=$fit';
}

class MyRenderFlex extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MyFlexParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MyFlexParentData> {
  /// Creates a flex render object.
  ///
  /// By default, the flex layout is horizontal and children are aligned to the
  /// start of the main axis and the center of the cross axis.
  MyRenderFlex({
    List<RenderBox>? children,
    Axis direction = Axis.horizontal,
  }) : _direction = direction {
    addAll(children);
  }

  /// The direction to use as the main axis.
  Axis get direction => _direction;
  Axis _direction;
  set direction(Axis value) {
    if (_direction != value) {
      _direction = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! MyFlexParentData) {
      child.parentData = MyFlexParentData();
    }
  }

  double _getIntrinsicSize({
    required Axis sizingDirection,
    required double
        extent, // the extent in the direction that isn't the sizing direction
    required _ChildSizingFunction
        childSize, // a method to find the size in the sizing direction
  }) {
    if (_direction == sizingDirection) {
      double length = 0.0;
      RenderBox? child = firstChild;

      while (child != null) {
        length += childSize(child, extent);
        final MyFlexParentData childParentData =
            child.parentData! as MyFlexParentData;
        child = childParentData.nextSibling;
      }
      return length;
    } else {
      RenderBox? child = firstChild;
      double length = 0.0;

      while (child != null) {
        double crossSize = childSize(child, extent);

        if (length < crossSize) {
          length = crossSize;
        }

        final MyFlexParentData childParentData =
            child.parentData! as MyFlexParentData;
        child = childParentData.nextSibling;
      }

      return length;
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _getIntrinsicSize(
      sizingDirection: Axis.horizontal,
      extent: height,
      childSize: (RenderBox child, double extent) =>
          child.getMinIntrinsicWidth(extent),
    );
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _getIntrinsicSize(
      sizingDirection: Axis.horizontal,
      extent: height,
      childSize: (RenderBox child, double extent) =>
          child.getMaxIntrinsicWidth(extent),
    );
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _getIntrinsicSize(
      sizingDirection: Axis.vertical,
      extent: width,
      childSize: (RenderBox child, double extent) =>
          child.getMinIntrinsicHeight(extent),
    );
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _getIntrinsicSize(
      sizingDirection: Axis.vertical,
      extent: width,
      childSize: (RenderBox child, double extent) =>
          child.getMaxIntrinsicHeight(extent),
    );
  }

  @override
  void performLayout() {
    double x = 0.0;
    double y = 0.0;
    double height;
    double width;

    switch (_direction) {
      case Axis.horizontal:
        RenderBox? child = firstChild;
        height = constraints.maxHeight;
        width = 0.0;

        while (child != null) {
          final MyFlexParentData childParentData =
              child.parentData! as MyFlexParentData;

          if (childParentData.fit == MyFlexFit.tight) {
            child.layout(
                BoxConstraints(
                  maxWidth: constraints.maxWidth,
                  minHeight: height,
                  maxHeight: height,
                ),
                parentUsesSize: true);

            width += child.size.width;
          }

          child = childParentData.nextSibling;
        }

        child = firstChild;

        while (child != null) {
          final MyFlexParentData childParentData =
              child.parentData! as MyFlexParentData;

          if (childParentData.fit == MyFlexFit.fill) {
            child.layout(
                BoxConstraints(
                    maxWidth: math.max(0.0, constraints.maxWidth - width),
                    maxHeight: height),
                parentUsesSize: true);

            width += child.size.width;
            height = child.size.height;
          }

          child = childParentData.nextSibling;
        }

        child = firstChild;

        while (child != null) {
          final MyFlexParentData childParentData =
              child.parentData! as MyFlexParentData;

          if (childParentData.fit == MyFlexFit.tight) {
            child.layout(
                BoxConstraints(
                  maxWidth: constraints.maxWidth,
                  minHeight: height,
                  maxHeight: height,
                ),
                parentUsesSize: true);
          }

          childParentData.offset = Offset(x, y);
          x += child.size.width;

          child = childParentData.nextSibling;
        }

        break;
      case Axis.vertical:
        {
          RenderBox? child = firstChild;
          height = 0.0;
          width = constraints.maxWidth;

          while (child != null) {
            final MyFlexParentData childParentData =
                child.parentData! as MyFlexParentData;

            if (childParentData.fit == MyFlexFit.tight) {
              child.layout(
                  constraints.tighten(
                    width: width,
                  ),
                  parentUsesSize: true);

              height += child.size.height;
            }

            child = childParentData.nextSibling;
          }

          child = firstChild;

          while (child != null) {
            final MyFlexParentData childParentData =
                child.parentData! as MyFlexParentData;

            if (childParentData.fit == MyFlexFit.fill) {
              child.layout(
                  BoxConstraints(
                    maxWidth: width,
                    maxHeight: math.max(0.0, constraints.maxHeight - height),
                  ),
                  parentUsesSize: true);

              height += child.size.height;
            }

            child = childParentData.nextSibling;
          }

          child = firstChild;

          while (child != null) {
            final MyFlexParentData childParentData =
                child.parentData! as MyFlexParentData;

            childParentData.offset = Offset(x, y);
            y += child.size.height;

            child = childParentData.nextSibling;
          }
        }
    }
    size = Size(width, height);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
