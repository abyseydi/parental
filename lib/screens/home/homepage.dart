import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:perantal/utils/colors.dart';
import 'package:perantal/widgets/app_bar.dart';
import 'package:perantal/widgets/ctg.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // ... your existing code

  int currentStep = 1;
  String? _selectedConnectionMethod;
  late AnimationController _controller;

  final TextEditingController _patientController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _nerfNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _communeController = TextEditingController();
  final TextEditingController _midwifeNameController = TextEditingController();
  final TextEditingController _doctorNameController = TextEditingController();

  double responsiveWidth(double percentage) {
    return SizeConfig.screenWidth * percentage;
  }

  double responsiveHeight(double percentage) {
    return SizeConfig.screenHeight * percentage;
  }

  @override
  void dispose() {
    _patientController.dispose();
    _birthDateController.dispose();
    _nerfNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _regionController.dispose();
    _communeController.dispose();
    _midwifeNameController.dispose();
    _doctorNameController.dispose();
    _controller.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Le 'vsync: this' est maintenant valide
    _controller = AnimationController(
      vsync: this, // Le 'this' fait référence au mixin
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: AppColors.k_background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: responsiveHeight(0.02)),
            _buildStepIndicator(),
            SizedBox(height: responsiveHeight(0.04)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsiveWidth(0.05)),
              child: _getStepContent(),
            ),
            SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.k_primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(90),
          bottomRight: Radius.circular(90),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: responsiveWidth(0.05)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Image.asset(
              'assets/img/logo.jpg',
              height: responsiveHeight(0.1),
              width: responsiveWidth(0.1),
            ),
          ),
          Expanded(
            child: Text(
              'PERANTAL',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Icon(
            Icons.notifications_none,
            color: AppColors.k_background,
            size: responsiveHeight(0.04),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        int stepNumber = index + 1;
        bool isActive = stepNumber == currentStep;
        bool isCompleted = stepNumber < currentStep;

        return GestureDetector(
          onTap: () {
            setState(() {
              currentStep = stepNumber;
            });
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 12),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.k_primary
                  : (isCompleted
                        ? AppColors.k_primary.withOpacity(0.5)
                        : AppColors.k_background),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? AppColors.k_primary : AppColors.k_primary,
                width: 2,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.k_primary.withOpacity(0.3),
                        offset: Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.k_primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _getStepContent() {
    switch (currentStep) {
      case 1:
        return _buildStepOne();
      case 2:
        return _buildStepTwo();
      case 3:
        return _buildStepThree();
      case 4:
        return _buildStepFour();
      default:
        return Container();
    }
  }

  Widget _buildStepOne() {
    return _buildStepCard(
      title: 'Sélectionner le mode de connexion',
      content: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedConnectionMethod = 'Wi-Fi';
              });
            },
            child: Card(
              elevation: _selectedConnectionMethod == 'Wi-Fi' ? 8 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: _selectedConnectionMethod == 'Wi-Fi'
                      ? AppColors.k_primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(Icons.wifi, size: 40, color: AppColors.k_primary),
                    SizedBox(width: 20),
                    Text(
                      'Connexion Wi-Fi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedConnectionMethod = 'Bluetooth';
              });
            },
            child: Card(
              elevation: _selectedConnectionMethod == 'Bluetooth' ? 8 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: _selectedConnectionMethod == 'Bluetooth'
                      ? AppColors.k_primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(Icons.bluetooth, size: 40, color: AppColors.k_primary),
                    SizedBox(width: 20),
                    Text(
                      'Connexion Bluetooth',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      actions: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: () {
              setState(() {
                currentStep--;
              });
            },
            child: Text('Précédent'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.k_primary,
              side: BorderSide(color: AppColors.k_primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _selectedConnectionMethod != null
                ? () {
                    // if (_selectedConnectionMethod == 'Wi-Fi') {
                    //   OpenSettings.openWIFISetting();
                    // } else if (_selectedConnectionMethod == 'Bluetooth') {
                    //   OpenSettings.openBluetoothSetting();
                    // }

                    setState(() {
                      currentStep++;
                    });
                  }
                : null, // Le bouton est désactivé si rien n'est sélectionné
            child: Text('Suivant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.k_primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTwo() {
    return _buildStepCard(
      title: 'Informations de la patiente',
      content: Column(
        children: [
          TextField(
            controller: _patientController,
            decoration: InputDecoration(
              labelText: 'Nom de la patiente',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.k_primary),
              ),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _birthDateController,
            decoration: InputDecoration(
              labelText: 'Âge de la patiente',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.k_primary),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          TextField(
            controller: _nerfNameController,
            decoration: InputDecoration(
              labelText: 'Nom de la nerf',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.k_primary),
              ),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Adresse',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.k_primary),
              ),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Téléphone',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.k_primary),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 16),
          TextField(
            controller: _regionController,
            decoration: InputDecoration(
              labelText: 'Région',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.k_primary),
              ),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _communeController,
            decoration: InputDecoration(
              labelText: 'Commune',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.k_primary),
              ),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _midwifeNameController,
            decoration: InputDecoration(
              labelText: 'Nom de la sage-femme',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.k_primary),
              ),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _doctorNameController,
            decoration: InputDecoration(
              labelText: 'Nom du médecin',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.k_primary),
              ),
            ),
          ),
        ],
      ),
      actions: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              // Action pour réinitialiser
            },
            child: Text('Réinitialiser'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_patientController.text.isNotEmpty &&
                  _birthDateController.text.isNotEmpty &&
                  _nerfNameController.text.isNotEmpty &&
                  _addressController.text.isNotEmpty &&
                  _phoneController.text.isNotEmpty &&
                  _regionController.text.isNotEmpty &&
                  _communeController.text.isNotEmpty &&
                  _midwifeNameController.text.isNotEmpty &&
                  _doctorNameController.text.isNotEmpty) {
                setState(() {
                  currentStep++;
                });
              } else {
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text(
                //       'Veuillez remplir tous les champs obligatoires.',
                //     ),
                //   ),
                // );
                setState(() {
                  currentStep++;
                });
              }
            },
            child: Text('Suivant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.k_primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepThree() {
    return _buildStepCard(
      title: 'Resultats du CTG',
      content: Column(
        children: [
          Lottie.asset(
            'assets/img/ctg.json',
            width: responsiveWidth(1),
            height: responsiveHeight(0.08),
            fit: BoxFit.contain,
          ),
          SizedBox(height: 30),
        ],
      ),
      actions: _buildNavigationButtons(),
    );
  }

  Widget _buildStepFour() {
    return _buildStepCard(
      title: 'Téléchargement de documents',
      content: Column(
        children: [
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                // Logique d'upload
              },
              icon: Icon(Icons.cloud_upload_outlined),
              label: Text('Uploader un fichier'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.k_primary,
                side: BorderSide(color: AppColors.k_primary),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: _buildNavigationButtons(),
    );
  }

  Widget _buildStepFive() {
    return _buildStepCard(
      title: 'Résumé',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow(label: 'Nom', value: _patientController.text),
          _buildSummaryRow(label: 'Âge', value: _birthDateController.text),
          // Vous pouvez ajouter d'autres champs ici
        ],
      ),
      actions: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: () {
              setState(() {
                currentStep--;
              });
            },
            child: Text('Précédent'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.k_primary,
              side: BorderSide(color: AppColors.k_primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _showConfirmationDialog();
            },
            child: Text('Confirmer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.k_primary,
              foregroundColor: AppColors.k_primary,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String title,
    required Widget content,
    required Widget actions,
  }) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.k_primary,
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 24),
          content,
          SizedBox(height: 24),
          actions,
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: () {
            setState(() {
              currentStep--;
            });
          },
          child: Text('Précédent'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.k_primary,
            side: BorderSide(color: AppColors.k_primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              currentStep++;
            });
          },
          child: Text('Suivant'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.k_primary,
            foregroundColor: AppColors.k_background,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(value, style: TextStyle(fontSize: 16, color: Colors.black54)),
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Soumission réussie 🎉'),
        content: Text('Les données ont été enregistrées avec succès.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                currentStep = 1;
                _patientController.clear();
                _birthDateController.clear();
              });
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
