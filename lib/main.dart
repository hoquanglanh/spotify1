import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spotify/screens/intro.dart';
import 'package:spotify/screens/pages/home_page.dart';
import 'package:spotify/screens/register.dart';
import 'package:spotify/screens/sign_in.dart';
import 'package:spotify/screens/wait.dart';
import 'package:provider/provider.dart'; // Import Provider package

// UserProvider to manage login state
class UserProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  UserProvider() {
    _checkLoggedInStatus();
  }

  Future<void> _checkLoggedInStatus() async {
    String? email = await _storage.read(key: 'logged_in_user');
    _isLoggedIn = email != null;
    notifyListeners();
  }

  Future<void> logIn(String email) async {
    await _storage.write(key: 'logged_in_user', value: email);
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logOut() async {
    await _storage.delete(key: 'logged_in_user');
    _isLoggedIn = false;
    notifyListeners();
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: userProvider.isLoggedIn ? HomePage() : IntroScreen(),
          routes: {
            '/intro': (context) => IntroScreen(),
            '/wait': (context) => WaitScreen(),
            '/register': (context) => RegisterScreen(),
            '/signin': (context) => SignInScreen(),
            '/home_page': (context) => HomePage(),
          },
        );
      },
    );
  }
}
