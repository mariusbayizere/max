import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAM_hf_KMph6CmVDH-Euzx2VGDIl3eo8ts",
        authDomain: "fir-authentication-3282f.firebaseapp.com",
        projectId: "fir-authentication-3282f",
        storageBucket: "fir-authentication-3282f.appspot.com",
        messagingSenderId: "453653438317",
        appId: "1:453653438317:android:15b911a78398239fd0c464",
        measurementId: "G-XXXXXXXXXX",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  final themeMode = await getThemeMode();
  runApp(MyApp(themeMode: themeMode));
}

Future<ThemeMode> getThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  return isDarkMode ? ThemeMode.dark : ThemeMode.light;
}

class MyApp extends StatelessWidget {
  final ThemeMode themeMode;

  const MyApp({Key? key, required this.themeMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  ThemeMode _themeMode = ThemeMode.system;
  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late StreamSubscription<BatteryState> _batterySubscription;

  static const List<Widget> _widgetOptions = <Widget>[
    SignInScreen(),
    SignUpScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _initializeConnectivity();
    _initializeBatteryListener();
  }

  Future<void> _loadThemeMode() async {
    final themeMode = await getThemeMode();
    setState(() {
      _themeMode = themeMode;
    });
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = _themeMode == ThemeMode.dark;
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    });
    await prefs.setBool('isDarkMode', !isDarkMode);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _initializeConnectivity() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      String message;
      switch (result) {
        case ConnectivityResult.wifi:
          message = "Connected to Wi-Fi";
          break;
        case ConnectivityResult.mobile:
          message = "Connected to Mobile Network";
          break;
        case ConnectivityResult.none:
          message = "No Internet Connection";
          break;
        default:
          message = "Connectivity Changed";
          break;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    });
  }

  void _initializeBatteryListener() {
    _batterySubscription =
        _battery.onBatteryStateChanged.listen((BatteryState state) async {
      if (state == BatteryState.charging) {
        int batteryLevel = await _battery.batteryLevel;
        if (batteryLevel >= 90) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Battery is sufficiently charged!")),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _batterySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              _themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Sign In',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration),
            label: 'Sign Up',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
      drawer: MyDrawer(onMenuItemSelected: _onItemTapped),
    );
  }
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 20.0,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 20.0,
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 20.0,
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final String email = emailController.text.trim();
                final String password = passwordController.text.trim();
                final String confirmPassword =
                    confirmPasswordController.text.trim();

                if (password != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match.'),
                    ),
                  );
                  return;
                }

                try {
                  final UserCredential userCredential = await FirebaseAuth
                      .instance
                      .createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sign up successful!'),
                    ),
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                  );
                } on FirebaseAuthException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sign up failed: ${e.message}'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? '),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 20.0,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 20.0,
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final String email = emailController.text.trim();
                final String password = passwordController.text.trim();

                try {
                  final UserCredential userCredential =
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sign in successful!'),
                    ),
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                  );
                } on FirebaseAuthException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sign in failed: ${e.message}'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(
                FontAwesomeIcons.google,
                color: Colors.red,
              ),
              label: const Text(
                'Sign In with Google',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onPressed: () async {
                try {
                  final GoogleSignInAccount? googleUser =
                      await GoogleSignIn().signIn();

                  if (googleUser != null) {
                    final GoogleSignInAuthentication googleAuth =
                        await googleUser.authentication;
                    final OAuthCredential credential =
                        GoogleAuthProvider.credential(
                      accessToken: googleAuth.accessToken,
                      idToken: googleAuth.idToken,
                    );

                    // ignore: unused_local_variable
                    final UserCredential userCredential = await FirebaseAuth
                        .instance
                        .signInWithCredential(credential);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Google Sign-In successful!'),
                      ),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyHomePage()),
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Google Sign-In failed: ${e.message}'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Don\'t have an account? '),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  final Function(int) onMenuItemSelected;

  const MyDrawer({Key? key, required this.onMenuItemSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        NetworkImage('https://via.placeholder.com/150'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'User Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Sign In'),
            onTap: () {
              onMenuItemSelected(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.app_registration),
            title: const Text('Sign Up'),
            onTap: () {
              onMenuItemSelected(1);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}












// ------------------

// import 'dart:async';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:battery_plus/battery_plus.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   if (kIsWeb) {
//     await Firebase.initializeApp(
//       options: const FirebaseOptions(
//         apiKey: "AIzaSyAM_hf_KMph6CmVDH-Euzx2VGDIl3eo8ts",
//         authDomain: "YOUR_AUTH_DOMAIN",
//         projectId: "fir-authentication-3282f",
//         storageBucket: "YOUR_STORAGE_BUCKET",
//         messagingSenderId: "453653438317",
//         appId: "1:453653438317:android:15b911a78398239fd0c464",
//         measurementId: "YOUR_MEASUREMENT_ID",
//       ),
//     );
//   } else {
//     await Firebase.initializeApp();
//   }

//   final themeMode = await getThemeMode();
//   runApp(MyApp(themeMode: themeMode));
// }

// Future<ThemeMode> getThemeMode() async {
//   final prefs = await SharedPreferences.getInstance();
//   final isDarkMode = prefs.getBool('isDarkMode') ?? false;
//   return isDarkMode ? ThemeMode.dark : ThemeMode.light;
// }

// class MyApp extends StatelessWidget {
//   final ThemeMode themeMode;

//   const MyApp({Key? key, required this.themeMode}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//       ),
//       darkTheme: ThemeData.dark(),
//       themeMode: themeMode,
//       home: const MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _selectedIndex = 0;
//   ThemeMode _themeMode = ThemeMode.system;
//   final Battery _battery = Battery();
//   final Connectivity _connectivity = Connectivity();
//   late StreamSubscription<ConnectivityResult> _connectivitySubscription;
//   late StreamSubscription<BatteryState> _batterySubscription;

//   static const List<Widget> _widgetOptions = <Widget>[
//     SignInScreen(),
//     SignUpScreen(),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadThemeMode();
//     _initializeConnectivity();
//     _initializeBatteryListener();
//   }

//   Future<void> _loadThemeMode() async {
//     final themeMode = await getThemeMode();
//     setState(() {
//       _themeMode = themeMode;
//     });
//   }

//   void _toggleTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     final isDarkMode = _themeMode == ThemeMode.dark;
//     setState(() {
//       _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
//     });
//     await prefs.setBool('isDarkMode', !isDarkMode);
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   void _initializeConnectivity() {
//     _connectivitySubscription =
//         _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
//       String message;
//       switch (result) {
//         case ConnectivityResult.wifi:
//           message = "Connected to Wi-Fi";
//           break;
//         case ConnectivityResult.mobile:
//           message = "Connected to Mobile Network";
//           break;
//         case ConnectivityResult.none:
//           message = "No Internet Connection";
//           break;
//         default:
//           message = "Connectivity Changed";
//           break;
//       }
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text(message)));
//     });
//   }

//   void _initializeBatteryListener() {
//     _batterySubscription =
//         _battery.onBatteryStateChanged.listen((BatteryState state) async {
//       if (state == BatteryState.charging) {
//         int batteryLevel = await _battery.batteryLevel;
//         if (batteryLevel >= 90) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Battery is sufficiently charged!")),
//           );
//         }
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _connectivitySubscription.cancel();
//     _batterySubscription.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Flutter Demo Home Page'),
//         actions: <Widget>[
//           IconButton(
//             icon: Icon(
//               _themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
//             ),
//             onPressed: _toggleTheme,
//           ),
//         ],
//       ),
//       body: Center(
//         child: _widgetOptions.elementAt(_selectedIndex),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.login),
//             label: 'Sign In',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.app_registration),
//             label: 'Sign Up',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.blue,
//         onTap: _onItemTapped,
//       ),
//       drawer: MyDrawer(onMenuItemSelected: _onItemTapped),
//     );
//   }
// }

// class SignUpScreen extends StatelessWidget {
//   const SignUpScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController emailController = TextEditingController();
//     final TextEditingController passwordController = TextEditingController();
//     final TextEditingController confirmPasswordController =
//         TextEditingController();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sign Up'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             const Text(
//               'Sign Up',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(
//                 labelText: 'E-mail Address',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.grey,
//                     width: 1.0,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.blue,
//                     width: 2.0,
//                   ),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: passwordController,
//               decoration: const InputDecoration(
//                 labelText: 'Password',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.grey,
//                     width: 1.0,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.blue,
//                     width: 2.0,
//                   ),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: confirmPasswordController,
//               decoration: const InputDecoration(
//                 labelText: 'Confirm Password',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.grey,
//                     width: 1.0,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.blue,
//                     width: 2.0,
//                   ),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 try {
//                   final email = emailController.text.trim();
//                   final password = passwordController.text.trim();
//                   final confirmPassword = confirmPasswordController.text.trim();

//                   if (password != confirmPassword) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Passwords do not match')),
//                     );
//                     return;
//                   }

//                   await FirebaseAuth.instance.createUserWithEmailAndPassword(
//                     email: email,
//                     password: password,
//                   );
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Sign up successful')),
//                   );
//                 } on FirebaseAuthException catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Error: ${e.message}')),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(40.0),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//               child: const Text('Sign Up'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SignInScreen extends StatelessWidget {
//   const SignInScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController emailController = TextEditingController();
//     final TextEditingController passwordController = TextEditingController();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sign In'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             const Text(
//               'Sign In',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(
//                 labelText: 'E-mail Address',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.grey,
//                     width: 1.0,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.blue,
//                     width: 2.0,
//                   ),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: passwordController,
//               decoration: const InputDecoration(
//                 labelText: 'Password',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.grey,
//                     width: 1.0,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.blue,
//                     width: 2.0,
//                   ),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 try {
//                   final email = emailController.text.trim();
//                   final password = passwordController.text.trim();

//                   await FirebaseAuth.instance.signInWithEmailAndPassword(
//                     email: email,
//                     password: password,
//                   );
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Sign in successful')),
//                   );
//                 } on FirebaseAuthException catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Error: ${e.message}')),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(40.0),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//               child: const Text('Sign In'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MyDrawer extends StatelessWidget {
//   final Function(int) onMenuItemSelected;

//   const MyDrawer({Key? key, required this.onMenuItemSelected})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: <Widget>[
//           const DrawerHeader(
//             decoration: BoxDecoration(
//               color: Colors.blue,
//             ),
//             child: Text(
//               'Menu',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//               ),
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.login),
//             title: const Text('Sign In'),
//             onTap: () {
//               onMenuItemSelected(0);
//               Navigator.pop(context);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.app_registration),
//             title: const Text('Sign Up'),
//             onTap: () {
//               onMenuItemSelected(1);
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }







// ---------------------------------

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   if (kIsWeb) {
//     await Firebase.initializeApp(
//       options: const FirebaseOptions(
//         apiKey: "AIzaSyAM_hf_KMph6CmVDH-Euzx2VGDIl3eo8ts",
//         authDomain: "YOUR_AUTH_DOMAIN",
//         projectId: "fir-authentication-3282f",
//         storageBucket: "YOUR_STORAGE_BUCKET",
//         messagingSenderId: "453653438317",
//         appId: "1:453653438317:android:15b911a78398239fd0c464",
//         measurementId: "YOUR_MEASUREMENT_ID",
//       ),
//     );
//   } else {
//     await Firebase.initializeApp();
//   }

//   final themeMode = await getThemeMode();
//   runApp(MyApp(themeMode: themeMode));
// }

// Future<ThemeMode> getThemeMode() async {
//   final prefs = await SharedPreferences.getInstance();
//   final isDarkMode = prefs.getBool('isDarkMode') ?? false;
//   return isDarkMode ? ThemeMode.dark : ThemeMode.light;
// }

// class MyApp extends StatelessWidget {
//   final ThemeMode themeMode;

//   const MyApp({super.key, required this.themeMode});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//       ),
//       darkTheme: ThemeData.dark(),
//       themeMode: themeMode,
//       home: const MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _selectedIndex = 0;
//   late ThemeMode _themeMode;

//   static const List<Widget> _widgetOptions = <Widget>[
//     SignInScreen(),
//     SignUpScreen(),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadThemeMode();
//   }

//   Future<void> _loadThemeMode() async {
//     final themeMode = await getThemeMode();
//     setState(() {
//       _themeMode = themeMode;
//     });
//   }

//   void _toggleTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     final isDarkMode = _themeMode == ThemeMode.dark;
//     setState(() {
//       _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
//     });
//     await prefs.setBool('isDarkMode', !isDarkMode);
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Flutter Demo Home Page'),
//         actions: <Widget>[
//           IconButton(
//             icon: Icon(
//               _themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
//             ),
//             onPressed: _toggleTheme,
//           ),
//         ],
//       ),
//       body: Center(
//         child: _widgetOptions.elementAt(_selectedIndex),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.login),
//             label: 'Sign In',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.app_registration),
//             label: 'Sign Up',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.blue,
//         onTap: _onItemTapped,
//       ),
//       drawer: MyDrawer(onMenuItemSelected: _onItemTapped),
//     );
//   }
// }

// class SignUpScreen extends StatelessWidget {
//   const SignUpScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController emailController = TextEditingController();
//     final TextEditingController passwordController = TextEditingController();
//     final TextEditingController confirmPasswordController =
//         TextEditingController();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sign Up'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             const Text(
//               'Sign Up',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(
//                 labelText: 'E-mail Address',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.grey,
//                     width: 1.0,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.blue,
//                     width: 2.0,
//                   ),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: passwordController,
//               decoration: const InputDecoration(
//                 labelText: 'Password',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.grey,
//                     width: 1.0,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.blue,
//                     width: 2.0,
//                   ),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: confirmPasswordController,
//               decoration: const InputDecoration(
//                 labelText: 'Confirm Password',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.grey,
//                     width: 1.0,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.blue,
//                     width: 2.0,
//                   ),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 final String email = emailController.text;
//                 final String password = passwordController.text;
//                 final String confirmPassword = confirmPasswordController.text;

//                 if (password == confirmPassword) {
//                   bool success = await AuthService()
//                       .signUpWithEmailAndPassword(email, password);
//                   if (success) {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const HomeScreen()),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Sign up failed')),
//                     );
//                   }
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Passwords do not match')),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(40.0),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//               child: const Text(
//                 'Sign Up',
//                 style: TextStyle(
//                   fontSize: 18,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SignInScreen extends StatelessWidget {
//   const SignInScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController emailController = TextEditingController();
//     final TextEditingController passwordController = TextEditingController();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sign In'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             const Text(
//               'Sign In',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(
//                 labelText: 'E-mail Address',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.grey,
//                     width: 1.0,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.blue,
//                     width: 2.0,
//                   ),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: passwordController,
//               decoration: const InputDecoration(
//                 labelText: 'Password',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.grey,
//                     width: 1.0,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.blue,
//                     width: 2.0,
//                   ),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 final String email = emailController.text;
//                 final String password = passwordController.text;

//                 bool success = await AuthService()
//                     .signInWithEmailAndPassword(email, password);
//                 if (success) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => const HomeScreen()),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Sign in failed')),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(40.0),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//               child: const Text(
//                 'Sign In',
//                 style: TextStyle(
//                   fontSize: 18,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 bool success = await AuthService().signInWithGoogle();
//                 if (success) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => const HomeScreen()),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Google sign in failed')),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(40.0),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//               child: const Text(
//                 'Sign In with Google',
//                 style: TextStyle(
//                   fontSize: 18,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 bool success = await AuthService().signInWithFacebook();
//                 if (success) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => const HomeScreen()),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Facebook sign in failed')),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(40.0),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//               child: const Text(
//                 'Sign In with Facebook',
//                 style: TextStyle(
//                   fontSize: 18,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MyDrawer extends StatelessWidget {
//   final Function(int) onMenuItemSelected;

//   const MyDrawer({super.key, required this.onMenuItemSelected});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: <Widget>[
//           const DrawerHeader(
//             decoration: BoxDecoration(
//               color: Colors.blue,
//             ),
//             child: Text(
//               'Menu',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//               ),
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.login),
//             title: const Text('Sign In'),
//             onTap: () {
//               onMenuItemSelected(0);
//               Navigator.pop(context);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.app_registration),
//             title: const Text('Sign Up'),
//             onTap: () {
//               onMenuItemSelected(1);
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//       ),
//       body: const Center(
//         child: Text('Welcome! You are signed in.'),
//       ),
//     );
//   }
// }

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   final FacebookAuth _facebookAuth = FacebookAuth.instance;

//   Future<bool> signInWithEmailAndPassword(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//           email: email, password: password);
//       return userCredential.user != null;
//     } catch (e) {
//       print('Error signing in with email and password: $e');
//       return false;
//     }
//   }

//   Future<bool> signUpWithEmailAndPassword(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth
//           .createUserWithEmailAndPassword(email: email, password: password);
//       return userCredential.user != null;
//     } catch (e) {
//       print('Error signing up with email and password: $e');
//       return false;
//     }
//   }

//   Future<bool> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         return false;
//       }
//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//       UserCredential userCredential =
//           await _auth.signInWithCredential(credential);
//       return userCredential.user != null;
//     } catch (e) {
//       print('Error signing in with Google: $e');
//       return false;
//     }
//   }

//   Future<bool> signInWithFacebook() async {
//     try {
//       final LoginResult result = await _facebookAuth.login();
//       if (result.status == LoginStatus.success) {
//         final AccessToken accessToken = result.accessToken!;
//         final AuthCredential credential =
//             FacebookAuthProvider.credential(accessToken.token);
//         UserCredential userCredential =
//             await _auth.signInWithCredential(credential);
//         return userCredential.user != null;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       print('Error signing in with Facebook: $e');
//       return false;
//     }
//   }

//   Future<void> signOut() async {
//     await _auth.signOut();
//     await _googleSignIn.signOut();
//     await _facebookAuth.logOut();
//   }
// }




// --------------------------------
















// // ========================================================

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:firebase_core/firebase_core.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   if (kIsWeb) {
//     await Firebase.initializeApp(
//       options: FirebaseOptions(
//         apiKey: "AIzaSyAM_hf_KMph6CmVDH-Euzx2VGDIl3eo8ts",
//         authDomain: "YOUR_AUTH_DOMAIN",
//         projectId: "fir-authentication-3282f",
//         storageBucket: "YOUR_STORAGE_BUCKET",
//         messagingSenderId: "453653438317",
//         appId: "1:453653438317:android:15b911a78398239fd0c464",
//         measurementId: "YOUR_MEASUREMENT_ID",
//       ),
//     );
//   } else {
//     await Firebase.initializeApp();
//   }
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _selectedIndex = 0;

//   static const List<Widget> _widgetOptions = <Widget>[
//     SignInScreen(),
//     SignUpScreen(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Flutter Demo Home Page'),
//       ),
//       body: Center(
//         child: _widgetOptions.elementAt(_selectedIndex),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.login),
//             label: 'Sign In',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.app_registration),
//             label: 'Sign Up',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.blue,
//         onTap: _onItemTapped,
//       ),
//       drawer: MyDrawer(onMenuItemSelected: _onItemTapped),
//     );
//   }
// }

// class SignUpScreen extends StatelessWidget {
//   const SignUpScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController emailController = TextEditingController();
//     final TextEditingController passwordController = TextEditingController();
//     final TextEditingController confirmPasswordController =
//         TextEditingController();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sign Up'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             const Text(
//               'Sign Up',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(
//                 labelText: 'E-mail Address',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.grey,
//                     width: 1.0,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.blue,
//                     width: 2.0,
//                   ),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: passwordController,
//               decoration: const InputDecoration(
//                 labelText: 'Password',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.grey,
//                     width: 1.0,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.blue,
//                     width: 2.0,
//                   ),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: confirmPasswordController,
//               decoration: const InputDecoration(
//                 labelText: 'Confirm Password',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.grey,
//                     width: 1.0,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.blue,
//                     width: 2.0,
//                   ),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 final String email = emailController.text;
//                 final String password = passwordController.text;
//                 final String confirmPassword = confirmPasswordController.text;

//                 if (password == confirmPassword) {
//                   bool success = await AuthService()
//                       .signUpWithEmailAndPassword(email, password);
//                   if (success) {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const HomeScreen()),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Sign up failed')),
//                     );
//                   }
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Passwords do not match')),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(40.0),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//               child: const Text(
//                 'Sign Up',
//                 style: TextStyle(
//                   fontSize: 18,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SignInScreen extends StatelessWidget {
//   const SignInScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController emailController = TextEditingController();
//     final TextEditingController passwordController = TextEditingController();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sign In'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(
//                 labelText: 'E-mail Address',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.grey,
//                     width: 1.0,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.blue,
//                     width: 2.0,
//                   ),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: passwordController,
//               decoration: const InputDecoration(
//                 labelText: 'Password',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.grey,
//                     width: 1.0,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(40.0)),
//                   borderSide: BorderSide(
//                     color: Colors.blue,
//                     width: 2.0,
//                   ),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 final String email = emailController.text;
//                 final String password = passwordController.text;

//                 bool success = await AuthService()
//                     .signInWithEmailAndPassword(email, password);
//                 if (success) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => const HomeScreen()),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Sign in failed')),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(40.0),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//               child: const Text(
//                 'Sign In',
//                 style: TextStyle(
//                   fontSize: 18,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.login),
//               label: const Text('Sign in with Google'),
//               onPressed: () async {
//                 bool success = await AuthService().signInWithGoogle();
//                 if (success) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => const HomeScreen()),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Google sign in failed')),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(40.0),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.facebook),
//               label: const Text('Sign in with Facebook'),
//               onPressed: () async {
//                 bool success = await AuthService().signInWithFacebook();
//                 if (success) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => const HomeScreen()),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Facebook sign in failed')),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(40.0),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 25.0,
//                   vertical: 20.0,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//         actions: <Widget>[
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await AuthService().signOut();
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => const MyHomePage()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: const Center(
//         child: Text('Welcome to the Home Screen!'),
//       ),
//     );
//   }
// }

// class MyDrawer extends StatelessWidget {
//   final Function(int) onMenuItemSelected;

//   const MyDrawer({super.key, required this.onMenuItemSelected});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: <Widget>[
//           DrawerHeader(
//             decoration: const BoxDecoration(
//               color: Colors.blue,
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const <Widget>[
//                 Text(
//                   'Flutter Demo',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.login),
//             title: const Text('Sign In'),
//             onTap: () {
//               onMenuItemSelected(0);
//               Navigator.pop(context);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.app_registration),
//             title: const Text('Sign Up'),
//             onTap: () {
//               onMenuItemSelected(1);
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<bool> signInWithEmailAndPassword(String email, String password) async {
//     try {
//       await _auth.signInWithEmailAndPassword(email: email, password: password);
//       return true;
//     } catch (e) {
//       print(e);
//       return false;
//     }
//   }

//   Future<bool> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//       if (googleUser == null) {
//         return false;
//       }
//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//       await _auth.signInWithCredential(credential);
//       return true;
//     } catch (e) {
//       print(e);
//       return false;
//     }
//   }

//   Future<bool> signInWithFacebook() async {
//     try {
//       final LoginResult result = await FacebookAuth.instance.login();
//       if (result.status == LoginStatus.success) {
//         final AccessToken accessToken = result.accessToken!;
//         final AuthCredential credential =
//             FacebookAuthProvider.credential(accessToken.token);
//         await _auth.signInWithCredential(credential);
//         return true;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       print(e);
//       return false;
//     }
//   }

//   Future<bool> signUpWithEmailAndPassword(String email, String password) async {
//     try {
//       await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//       return true;
//     } catch (e) {
//       print(e);
//       return false;
//     }
//   }

//   Future<void> signOut() async {
//     await _auth.signOut();
//   }
// }
