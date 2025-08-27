import 'package:flutter/material.dart';

import 'package:perantal/utils/colors.dart';
import 'package:perantal/utils/size_config.dart';

class Auth extends StatelessWidget {
  double responsiveWidth(double percentage) {
    return SizeConfig.screenWidth * percentage;
  }

  double responsiveHeight(double percentage) {
    return SizeConfig.screenHeight * percentage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: responsiveHeight(0.6),
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.k_background, AppColors.k_primary],
              ),
            ),
            child: Center(
              child: Text(
                'PERANTAL',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              fixedSize: Size(250, 50),
              backgroundColor: Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('INSCRIPTION', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              fixedSize: Size(250, 50),
              side: BorderSide(width: 1, color: Color(0xFF4CAF50)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'CONNEXION',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }
}
