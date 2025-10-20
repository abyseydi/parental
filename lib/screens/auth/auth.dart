import 'package:flutter/material.dart';
import 'package:perantal/screens/auth/signup.dart';
import 'package:perantal/utils/colors.dart';
import 'package:perantal/utils/size_config.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  double responsiveWidth(double percentage) =>
      SizeConfig.screenWidth * percentage;

  double responsiveHeight(double percentage) =>
      SizeConfig.screenHeight * percentage;

  @override
  Widget build(BuildContext context) {
    // ⚠️ initialise SizeConfig ici
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppColors.k_background,
      body: Center(
        // ← centrer toute la colonne
        child: Column(
          mainAxisSize: MainAxisSize.min, // évite de prendre toute la hauteur
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: responsiveHeight(0.25),
              width: 250,
              child: Image.asset("assets/img/logo.jpg"),
            ),
            SizedBox(height: responsiveHeight(0.2), width: 250),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(250, 50),
                backgroundColor: AppColors.k_primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'INSCRIPTION',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                fixedSize: const Size(250, 50),
                side: const BorderSide(width: 1, color: AppColors.k_primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'CONNEXION',
                style: TextStyle(color: AppColors.k_primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
