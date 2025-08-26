import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:perantal/screens/settings/notification.dart';
import 'dart:math';

import 'package:perantal/utils/colors.dart';
import 'package:perantal/widgets/app_bar.dart';
import 'package:csv/csv.dart';

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
  int currentStep = 1;
  String? _selectedConnectionMethod;
  late AnimationController _controller;
  bool _isLoading = false;
  bool _showButton = true;
  InterpretationResult _interpretationResult = InterpretationResult.unknown;

  final TextEditingController _patientController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _nerfNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _communeController = TextEditingController();
  final TextEditingController _midwifeNameController = TextEditingController();
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _csvController = TextEditingController();
  List<List<dynamic>> _csvData = [];
  List<dynamic>? _selectedRandomRow;
  List<dynamic>? _filteredDataRow;
  List<dynamic>? _filteredHeaders;
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  void _fetchAndDisplayData(String cdvCode) {
    final List<String> dataPairs = cdvCode.split(';');
    Map<String, String> dataMap = {};
    for (String pair in dataPairs) {
      List<String> parts = pair.split(':');
      if (parts.length == 2) {
        dataMap[parts[0].trim()] = parts[1].trim();
      }
    }

    setState(() {
      _patientController.text = dataMap['Nom'] ?? '';
      _addressController.text = dataMap['Adresse'] ?? '';
      _phoneController.text = dataMap['Tel'] ?? '';
    });
  }

  Future<void> _loadCsvData() async {
    setState(() {
      _isLoading = true;
      _showButton = false;
    });

    await Future.delayed(const Duration(seconds: 3));

    try {
      final String csvString = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/data/data.csv');
      final csvConverter = CsvToListConverter();
      final List<List<dynamic>> result = csvConverter.convert(csvString);

      if (result.length > 1) {
        final random = Random();
        final int randomIndex = random.nextInt(result.length - 1) + 1;

        setState(() {
          _csvData = result;
          _selectedRandomRow = result[randomIndex];
          // Pass both the full data and the selected row to the filter function
          _filterData(_csvData, _selectedRandomRow!);

          if (_filteredDataRow != null && _filteredHeaders != null) {
            _interpretationResult = _interpretData(
              _filteredDataRow!,
              _filteredHeaders!,
            );
          }
        });
      } else {
        setState(() {
          _csvData = result;
          _selectedRandomRow = null;
          _filteredDataRow = null;
          _filteredHeaders = null;
        });
      }
    } catch (e) {
      print('Erreur lors de la lecture du fichier CSV : $e');
      setState(() {
        _selectedRandomRow = null;
        _filteredDataRow = null;
        _filteredHeaders = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
            Container(
              width: responsiveWidth(1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_buildStepIndicator()],
              ),
            ),
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Notifications()),
              );
            },
            child: Icon(
              Icons.notifications_none,
              color: AppColors.k_background,
              size: responsiveHeight(0.04),
            ),
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
            margin: EdgeInsets.symmetric(horizontal: 20),
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
                : null,
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
          // TextField(
          //   controller: _nerfNameController,
          //   decoration: InputDecoration(
          //     labelText: 'Nom de la nerf',
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(10),
          //       borderSide: BorderSide(color: Colors.grey[300]!),
          //     ),
          //     focusedBorder: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(10),
          //       borderSide: BorderSide(color: AppColors.k_primary),
          //     ),
          //   ),
          // ),
          // SizedBox(height: 16),
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
      title: 'Résultats du CTG',
      content: Column(
        children: [
          if (_isLoading)
            Column(
              children: [
                Lottie.asset(
                  'assets/img/ctg.json',
                  width: responsiveWidth(1),
                  height: responsiveHeight(0.08),
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 10),
                Text(
                  'Chargement en cours...',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _isLoading ? null : _loadCsvData,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: AppColors.k_primary, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Icon(Icons.list, size: 40, color: AppColors.k_primary),
                        SizedBox(width: 20),
                        Text(
                          'Afficher',
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
          SizedBox(height: 30),

          if (!_isLoading &&
              _filteredDataRow != null &&
              _filteredHeaders != null)
            _buildDataCard(headers: _filteredHeaders!, data: _filteredDataRow!),

          if (!_isLoading &&
              (_filteredDataRow == null || _filteredHeaders == null))
            Text('Appuyez sur "Afficher" pour charger les données.'),
        ],
      ),
      actions: _buildNavigationButtons(),
    );
  }

  Widget _buildDataCard({
    required List<dynamic> headers,
    required List<dynamic> data,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(data.length, (colIndex) {
            if (colIndex >= headers.length) {
              return Container();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${headers[colIndex]}:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  '${data[colIndex]}',
                  style: TextStyle(color: Colors.black87),
                ),
                if (colIndex < data.length - 1) SizedBox(height: 16),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStepFour() {
    return _buildStepCard(
      title: 'Interprétation IA',
      content: Column(
        children: [
          if (_interpretationResult == InterpretationResult.unknown)
            Text(
              'Appuyez sur "Afficher" à l\'étape précédente pour générer l\'analyse.',
              style: TextStyle(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          if (_interpretationResult != InterpretationResult.unknown)
            Column(
              children: [
                Text(
                  'Résultat de l\'analyse :',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAnimatedInterpretationBall(
                      result: InterpretationResult.ok,
                      currentInterpretation: _interpretationResult,
                      color: Colors.green,
                      label: 'OK',
                    ),
                    _buildAnimatedInterpretationBall(
                      result: InterpretationResult.alert,
                      currentInterpretation: _interpretationResult,
                      color: Colors.orange,
                      label: 'Alerte',
                    ),
                    _buildAnimatedInterpretationBall(
                      result: InterpretationResult.danger,
                      currentInterpretation: _interpretationResult,
                      color: Colors.red,
                      label: 'Danger',
                    ),
                  ],
                ),
                SizedBox(height: 30),
                _buildInterpretationText(_interpretationResult),
              ],
            ),
        ],
      ),
      actions: _buildNavigationButtons(),
    );
  }

  Widget _buildInterpretationText(InterpretationResult result) {
    String text;
    switch (result) {
      case InterpretationResult.ok:
        text =
            'Tout est en ordre : les indicateurs sont conformes aux normes de référence. Continuez la surveillance habituelle.';
        break;
      case InterpretationResult.alert:
        text =
            'Niveau d\'alerte : certains indicateurs sont hors des valeurs normales. Une attention particulière est recommandée.';
        break;
      case InterpretationResult.danger:
        text =
            'Situation d\'urgence: une prise en charge immediate est requise. Les indicateurs vitaux sont en dehors des seuils critiques.';
        break;
      default:
        text = '';
    }

    return Text(
      text,
      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
      textAlign: TextAlign.center,
    );
  }

  // Créez une nouvelle méthode pour construire le widget d'interprétation
  Widget _buildInterpretationResult() {
    late Color color;
    late String text;

    switch (_interpretationResult) {
      case InterpretationResult.ok:
        color = Colors.green;
        text = 'Tout est en ordre : OK';
        break;
      case InterpretationResult.alert:
        color = Colors.yellow[700]!;
        text = 'Attention, niveau Alerte';
        break;
      case InterpretationResult.danger:
        color = Colors.red;
        text = 'Danger : Urgence !';
        break;
      case InterpretationResult.unknown:
      default:
        color = Colors.grey;
        text = 'Interprétation non disponible.';
        break;
    }

    return Column(
      children: [
        Icon(Icons.circle, size: 100, color: color),
        SizedBox(height: 16),
        Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAnimatedInterpretationBall({
    required InterpretationResult result,
    required InterpretationResult currentInterpretation,
    required Color color,
    required String label,
  }) {
    final isSelected = result == currentInterpretation;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: isSelected ? 1.0 : 0.3,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: isSelected ? 90 : 80,
            height: isSelected ? 90 : 80,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.circle,
                color: Colors.white,
                size: isSelected ? 40 : 30,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? color : Colors.grey[600],
            ),
          ),
        ],
      ),
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

  // void _filterData(List<List<dynamic>> allData, List<dynamic> row) {
  //   if (allData.isEmpty) return;

  //   final headers = allData[0];
  //   final startHeader = 'baseline value';
  //   final endHeader = 'date_analyse';

  //   int startIndex = headers.indexOf(startHeader);
  //   int endIndex = headers.indexOf(endHeader);

  //   if (startIndex == -1 || endIndex == -1 || startIndex > endIndex) {
  //     print('Champs de début ou de fin non trouvés.');
  //     setState(() {
  //       _filteredDataRow = null;
  //       _filteredHeaders = null;
  //     });
  //     return;
  //   }

  //   // Extraction des en-têtes et des données filtrées
  //   List<dynamic> newHeaders = headers.sublist(startIndex, endIndex + 1);
  //   List<dynamic> newRow = row.sublist(startIndex, endIndex + 1);

  //   setState(() {
  //     _filteredHeaders = newHeaders;
  //     _filteredDataRow = newRow;
  //   });
  // }
  void _filterData(List<List<dynamic>> allData, List<dynamic> row) {
    if (allData.isEmpty) return;

    final headers = allData[0];
    final startHeader = 'baseline value';
    final endHeader = 'date_analyse';

    int startIndex = headers.indexOf(startHeader);
    int endIndex = headers.indexOf(endHeader);

    if (startIndex == -1 || endIndex == -1 || startIndex > endIndex) {
      print('Champs de début ou de fin non trouvés.');
      setState(() {
        _filteredDataRow = null;
        _filteredHeaders = null;
      });
      return;
    }

    // Extraction des en-têtes et des données filtrées
    List<dynamic> newHeaders = headers.sublist(startIndex, endIndex + 1);
    List<dynamic> newRow = row.sublist(startIndex, endIndex + 1);

    setState(() {
      _filteredHeaders = newHeaders;
      _filteredDataRow = newRow;
    });
  }

  InterpretationResult _interpretData(
    List<dynamic> data,
    List<dynamic> headers,
  ) {
    // Trouvez l'indice de la colonne 'baseline value'
    final int baselineIndex = headers.indexOf('baseline value');

    if (baselineIndex == -1 || baselineIndex >= data.length) {
      return InterpretationResult.unknown;
    }

    // Convertissez la valeur en nombre (assurez-vous que la valeur est bien un nombre)
    final dynamic baselineValue = data[baselineIndex];
    if (baselineValue is! num) {
      return InterpretationResult.unknown;
    }

    // Logique d'interprétation (vous pouvez ajuster ces seuils selon vos besoins)
    if (baselineValue > 150) {
      return InterpretationResult.danger;
    } else if (baselineValue >= 130) {
      return InterpretationResult.alert;
    } else {
      return InterpretationResult.ok;
    }
  }
}

enum InterpretationResult { ok, alert, danger, unknown }
