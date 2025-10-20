// import 'package:flutter/material.dart';

// import 'package:perantal/widgets/bottom_nav_bar.dart';

// class App extends StatelessWidget {
//   const App({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: MainScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:perantal/screens/auth/auth.dart';
import 'package:perantal/utils/size_config.dart';
import 'package:perantal/widgets/bottom_nav_bar.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perantal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // ⚠️ Initialise SizeConfig ici pour toute l'app
      builder: (context, child) {
        SizeConfig.init(context);
        return child!;
      },
      initialRoute: '/auth',
      routes: {'/auth': (_) => Auth(), '/home': (_) => MainScreen()},
    );
  }
}
