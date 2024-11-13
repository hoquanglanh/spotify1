import 'package:flutter/material.dart';
import 'package:spotify/screens/register.dart';
import 'package:spotify/screens/sign_in.dart';

class WaitScreen extends StatelessWidget {
  const WaitScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 34, 34),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/wait.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/spo.png',
                        width: 200,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Enjoy Listening To Music',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Spotify is a proprietary Swedish audio\nstreaming and media services provider',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Spacer(), // This will push the buttons to the bottom
                Padding(
                  padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: HoverButton(
                          onPressed: () {
                            Navigator.of(context).push(SlideRightRoute(page: RegisterScreen()));
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: HoverButton(
                          onPressed: () {
                            Navigator.of(context).push(SlideRightRoute(page: SignInScreen()));
                          },
                          child: Text(
                            'Sign in',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  SlideRightRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
}

class HoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const HoverButton({
    Key? key,
    required this.child,
    required this.onPressed,
  }) : super(key: key);

  @override
  _HoverButtonState createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 0), // Instant color change
        decoration: BoxDecoration(
          color: isHovered ? Color(0xFF1DB954) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          onPressed: widget.onPressed,
          child: widget.child,
        ),
      ),
    );
  }
}