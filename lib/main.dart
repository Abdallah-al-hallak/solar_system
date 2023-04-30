import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'dart:ui' as ui show Image;
import 'dart:ui';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const SolarWidget(),
    );
  }
}

class SolarWidget extends StatefulWidget {
  const SolarWidget({super.key});

  @override
  State<SolarWidget> createState() => _SolarWidgetState();
}

class _SolarWidgetState extends State<SolarWidget>
    with SingleTickerProviderStateMixin {
  ui.Image? earthimage;
  ui.Image? moonimage;
  late AnimationController _controller;
  @override
  void initState() {
    loadPictures();
    _controller = AnimationController(
        vsync: this,
        upperBound: 2 * pi,
        duration: const Duration(
          milliseconds: 5000,
        ));
    _controller.addListener(() {
      setState(() {});
    });

    _controller.forward();
    _controller.repeat();
    super.initState();
  }

  Future loadPictures() async {
    earthimage = await _loadImage('assets/imgs/earth.png', 80, 80);
    moonimage = await _loadImage('assets/imgs/moon.png', 50, 50);
    setState(() {});
  }

  Future<ui.Image> _loadImage(String path, int w, int h) async {
    final ByteData data = await rootBundle.load(path);
    final codec = await instantiateImageCodec(
      data.buffer.asUint8List(),
      targetHeight: w,
      targetWidth: h,
    );
    var frame = await codec.getNextFrame();

    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InteractiveViewer(
        child: CustomPaint(
          painter: OrbitPainter(_controller, earthimage, moonimage),
          child: Container(),
        ),
      ),
    );
  }
}

class OrbitPainter extends CustomPainter {
  final ui.Image? earthimage;
  final ui.Image? imoonmage;

  final Animation<double> animation;
  OrbitPainter(
    this.animation,
    this.earthimage,
    this.imoonmage,
  );
  @override
  void paint(Canvas canvas, Size size) async {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    const strokeWidth = 20.0;
    final shadowPaint = Paint()
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, 20.0 * animation.value)
      ..color = Colors.yellow.withOpacity(0.5);
    final imagePaint = Paint();

    final sunPaint = Paint()
      ..shader = RadialGradient(
        tileMode: TileMode.mirror,
        colors: [Colors.orange.shade300, Colors.yellow],
        stops: [0.0, radius / (radius + strokeWidth)],
      ).createShader(
        Rect.fromCircle(center: center, radius: 100),
      )
      ..color = Colors.yellow;

    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.grey.withOpacity(0.5);
    const earthOrbit = 70.0;

    canvas.drawCircle(center, 110, shadowPaint); //sun shadow
    canvas.drawCircle(
        Offset(size.width / 2 + 252 * cos(animation.value),
            size.height / 2 + 252 * sin(animation.value)),
        earthOrbit,
        orbitPaint);
    // canvas.drawCircle(center, 200, orbitPaint);
    canvas.drawOval(
        Rect.fromCenter(center: center, height: 500, width: 520), orbitPaint);
    canvas.drawCircle(center, 110, sunPaint);
    if (earthimage != null) {
      canvas.drawImage(
          earthimage!,
          Offset(size.width / 2.1 + 250 * cos(animation.value),
              size.height / 2.2 + 250 * sin(animation.value)),
          imagePaint);
    }
    if (imoonmage != null) {
      canvas.drawImage(
          imoonmage!,
          Offset(
              size.width / 2.08 +
                  250 * cos(animation.value) +
                  earthOrbit * cos(animation.value),
              size.height / 2.15 +
                  250 * sin(animation.value) +
                  earthOrbit * sin(animation.value)),
          imagePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
