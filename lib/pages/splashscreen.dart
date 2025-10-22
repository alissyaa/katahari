import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signup_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dropAnim;
  late Animation<double> _expandAnim;
  late Animation<double> _bgTransitionAnim;
  late Animation<double> _textFadeAnim;

  bool _showBlueLogo = false;
  bool _showText = false;

  final Color _startColor = const Color(0xFFA9CCEF);
  final Color _endColor = Colors.white;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _dropAnim = Tween<double>(begin: -300, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    _expandAnim = Tween<double>(begin: 100, end: 2000).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.65, curve: Curves.easeInOut),
      ),
    );

    _bgTransitionAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeInOut),
      ),
    );

    _textFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.addListener(() {
      if (_controller.value > 0.45 && !_showBlueLogo) {
        setState(() => _showBlueLogo = true);
      }
      if (_controller.value > 0.8 && !_showText) {
        setState(() => _showText = true);
      }
    });

    _controller.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignupPage()),
        );
      }
    });


  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Shader gradientShader = const LinearGradient(
      colors: [
        Color(0xFFA9CCEF),
        Color(0xFF0C1212),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final bgColor =
        Color.lerp(_startColor, _endColor, _bgTransitionAnim.value)!;

        return Scaffold(
          backgroundColor: bgColor,
          body: Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Expanding soft white glow
                Transform.translate(
                  offset: Offset(0, _dropAnim.value),
                  child: Container(
                    width: _expandAnim.value,
                    height: _expandAnim.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(
                        alpha: 0.85 * _bgTransitionAnim.value,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(
                            alpha: 0.7 * _bgTransitionAnim.value,
                          ),
                          blurRadius: 120,
                          spreadRadius: 80,
                        ),
                      ],
                    ),
                  ),
                ),

                // Logo + Text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      child: Image.asset(
                        _showBlueLogo
                            ? 'assets/logo_blue.png'
                            : 'assets/logo_white.png',
                        key: ValueKey<bool>(_showBlueLogo),
                        width: 220,
                        height: 220,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_showText)
                      FadeTransition(
                        opacity: _textFadeAnim,
                        child: ShaderMask(
                          shaderCallback: (bounds) => gradientShader,
                          blendMode: BlendMode.srcIn,
                          child: Text(
                            'katahari.',
                            style: GoogleFonts.poppins(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0C1212),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}