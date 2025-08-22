import 'package:flutter/material.dart';
import 'package:perantal/utils/colors.dart';
import 'package:perantal/utils/size_config.dart';
import 'package:perantal/widgets/app_bar.dart';



class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
double responsiveWidth(double percentage) {
  return SizeConfig.screenWidth * percentage;
}

double responsiveHeight(double percentage) {
  return SizeConfig.screenHeight * percentage;
}

  @override
  Widget build(BuildContext context) {
   SizeConfig.init(context); // Initialiser ici

  return Scaffold(
      appBar: CustomAppBar(
     ),
     backgroundColor: AppColors.k_background,
    body: Column(
      children: [
    Container(
    height: responsiveHeight(0.2),
     decoration: BoxDecoration(
   color: AppColors.k_primary,
  borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(90),    
       bottomRight: Radius.circular(90), 
    ),  ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
      Padding(
         padding:  EdgeInsets.only(left: responsiveWidth(0.05)),
        child: SizedBox(height: 60, width: 60,child:   Image.asset('assets/img/logo.jpg'),),
      ),
      Text('Informations de la patiente'), Padding(
        padding:  EdgeInsets.only(right: responsiveWidth(0.05)),
        child: Icon(Icons.notifications, size: 30,),
      )
    ],),)        ]
    ),
  );
  }
}
