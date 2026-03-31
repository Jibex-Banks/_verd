import 'package:flutter/material.dart';
import 'dart:math';

class NeuralBackground extends StatefulWidget {
  final Widget child;
  const NeuralBackground({super.key, required this.child});

  @override
  State<NeuralBackground> createState() => _NeuralBackgroundState();
}

class _NeuralBackgroundState extends State<NeuralBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Node> _nodes = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        setState(() {
          for (var node in _nodes) {
            node.update();
          }
        });
      })..repeat();

    // Initialize 40 nodes
    for (int i = 0; i < 40; i++) {
      _nodes.add(Node(
        offset: Offset(_random.nextDouble() * 2000, _random.nextDouble() * 2000),
        velocity: Offset((_random.nextDouble() - 0.5) * 0.5, (_random.nextDouble() - 0.5) * 0.5),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: NeuralPainter(nodes: _nodes),
          size: Size.infinite,
        ),
        widget.child,
      ],
    );
  }
}

class Node {
  Offset offset;
  Offset velocity;

  Node({required this.offset, required this.velocity});

  void update() {
    offset += velocity;
    // Simple wrap around logic would go here, but for infinite painter we just let them move.
    // In a real app we'd constrain to screen size.
  }
}

class NeuralPainter extends CustomPainter {
  final List<Node> nodes;
  NeuralPainter({required this.nodes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D6B1).withOpacity(0.05)
      ..strokeWidth = 1.0;

    final dotPaint = Paint()
      ..color = const Color(0xFF00D6B1).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < nodes.length; i++) {
      var node = nodes[i];
      // Keep nodes within bounds for visual sanity
      node.offset = Offset(
        node.offset.dx % size.width,
        node.offset.dy % size.height,
      );

      canvas.drawCircle(node.offset, 2.0, dotPaint);

      for (int j = i + 1; j < nodes.length; j++) {
        var other = nodes[j];
        double dist = (node.offset - other.offset).distance;
        if (dist < 150) {
          paint.color = const Color(0xFF00D6B1).withOpacity((1 - (dist / 150)) * 0.1);
          canvas.drawLine(node.offset, other.offset, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant NeuralPainter oldDelegate) => true;
}
