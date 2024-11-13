import 'package:flutter/material.dart';
import 'package:spotify/screens/wait.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: IntroScreen(),
    );
  }
}

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            _createRoute(GetStartedScreen(
              imageWidth: 250,
              imageHeight: 400,
            )),
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/spo.png',
                width: 250,
                height: 400,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Hàm tạo route với hiệu ứng chuyển động từ phải sang trái
Route _createRoute(Widget screen) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

class GetStartedScreen extends StatelessWidget {
  final double imageWidth;
  final double imageHeight;

  GetStartedScreen({required this.imageWidth, required this.imageHeight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/home.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          Positioned(
            top: 1,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/spo.png',
              width: 196,
              height: 59,
              fit: BoxFit.contain,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Enjoy Listening To Music',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sagittis enim purus sed phasellus. Cursus ornare id scelerisque aliquam.',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 137, 125, 125),
                          fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF42C83C),
                        minimumSize: Size(250, 60),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          _createRoute(ModeSelectionScreen()),
                        );
                      },
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }
}

class ModeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/mode.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.8),
          ),
          Positioned(
            top: 1,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/spo.png',
              width: 196,
              height: 59,
              fit: BoxFit.contain,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Choose Mode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildModeButton(
                    icon: Icons.nights_stay,
                    label: 'Dark Mode',
                    backgroundColor: Colors.grey[800]!,
                    iconColor: Colors.white,
                  ),
                  SizedBox(width: 20),
                  _buildModeButton(
                    icon: Icons.wb_sunny,
                    label: 'Light Mode',
                    backgroundColor: Colors.grey[300]!,
                    iconColor: Colors.black,
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF42C83C),
                  minimumSize: Size(250, 60),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    _createRoute(WaitScreen()),
                  );
                },
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 40,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }
}
