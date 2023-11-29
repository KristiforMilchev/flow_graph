// Copyright (c) 2022, the flow_graph project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:flow_graph/src/graph.dart';
import 'package:flutter/material.dart';

import 'render/board_render.dart';

class GraphView<T> extends StatefulWidget {
  const GraphView(
      {Key? key, this.controller, required this.graph, this.onPaint})
      : super(key: key);

  final GraphViewController? controller;
  final Graph graph;
  final PaintCallback? onPaint;

  @override
  _GraphViewState<T> createState() => _GraphViewState<T>();
}

class _GraphViewState<T> extends State<GraphView<T>> {
  final GlobalKey _boardKey = GlobalKey();
  Offset _boardPosition = Offset.zero;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // Calculate the initial position to center the graph
      var graphSize = widget.graph.computeSize();
      var boardSize =
          (_boardKey.currentContext?.findRenderObject() as RenderBox?)?.size ??
              Size.zero;

      double dx = (boardSize.width - graphSize.width) / 2;
      double dy = (boardSize.height - graphSize.height) / 2;

      // Update the state with the calculated initial position
      setState(() {
        _boardPosition = Offset(dx, dy);
        widget.controller?._updatePosition(_boardPosition);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        //limit pan position
        var graphSize = widget.graph.computeSize();
        var boardSize =
            (_boardKey.currentContext?.findRenderObject() as RenderBox?)
                    ?.size ??
                Size.zero;
        double dx = 0, dy = 0;
        if (graphSize.width > boardSize.width) {
          dx = _boardPosition.dx + details.delta.dx;
          if (dx > 0) {
            dx = 0;
          } else if (dx < boardSize.width - graphSize.width - kMainAxisSpace) {
            // dx < -(graphSize.width - boardSize.width + kMainAxisSpace)
            dx = boardSize.width - graphSize.width - kMainAxisSpace;
          }
        }
        if (graphSize.height > boardSize.height) {
          dy = _boardPosition.dy + details.delta.dy;
          if (dy > 0) {
            dy = 0;
          } else if (dy <
              boardSize.height - graphSize.height - kMainAxisSpace) {
            //dy < -(graphSize.height - boardSize.height + kMainAxisSpace)
            dy = boardSize.height - graphSize.height - kMainAxisSpace;
          }
        }
      },
      child: ClipRect(
        child: GraphBoard(
          key: _boardKey,
          graph: widget.graph,
          position: _boardPosition,
          onPaint: widget.onPaint,
        ),
      ),
    );
  }
}

class GraphViewController with ChangeNotifier {
  Offset _position = Offset.zero;

  Offset get position => _position;

  void _updatePosition(Offset position) {
    _position = position;
    notifyListeners();
  }
}
