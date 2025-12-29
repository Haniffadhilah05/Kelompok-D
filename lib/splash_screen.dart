import 'package:flutter/material.dart';
import 'dart:math';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller; // gradient
  late AnimationController _logoController; // logo

  @override
  void initState() {
    super.initState();

    // Controller untuk animasi gradient
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Controller untuk animasi logo (sekali)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    // ✅ penting: start setelah frame pertama (lebih aman di web)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _logoController.forward(from: 0);
    });

    // Auto pindah ke HomePage setelah 2.5 detik
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // gradient bergerak
          final t1 = (sin(_controller.value * 2 * pi) + 1) / 2; // 0..1
          final t2 = (cos(_controller.value * 2 * pi) + 1) / 2; // 0..1

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(const Color(0xFFFFC27F), const Color(0xFFE57C23), t1)!,
                  Color.lerp(const Color(0xFFEDE0C8), const Color(0xFFE5B344), t2)!,
                ],
              ),
            ),

            // konten logo + teks
            child: Center(
              child: AnimatedBuilder(
                animation: _logoController,
                builder: (context, __) {
                  final v = Curves.easeOutCubic.transform(_logoController.value);

                  // fade 0 -> 1
                  final opacity = v;

                  // scale pop: 0.85 -> 1.08 -> 1.0
                  double scale;
                  if (v < 0.65) {
                    final vv = Curves.easeOut.transform(v / 0.65);
                    scale = 0.85 + (1.08 - 0.85) * vv;
                  } else {
                    final vv = Curves.easeOutBack.transform((v - 0.65) / 0.35);
                    scale = 1.08 + (1.0 - 1.08) * vv;
                  }

                  return Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 100,
                            color: Colors.white,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "NOTELEARN",
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
