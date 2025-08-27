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
  InterpretationResult _interpretationResult = InterpretationResult.unknown;
  bool _showResultAnimation = false;
  bool get _isStepThreeDataReady =>
      !_isLoading && _filteredDataRow != null && _filteredHeaders != null;

  final Random _rng = Random();
  InterpretationResult? _lastRandomResult;

  int _resetEpoch = 0;

  final TextEditingController _patientController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _nerfNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _communeController = TextEditingController();
  final TextEditingController _midwifeNameController = TextEditingController();
  final TextEditingController _doctorNameController = TextEditingController();

  bool _step4ShowingIntro = false;
  bool _step4IntroPlayed = false;

  List<List<dynamic>> _csvData = [];
  List<dynamic>? _selectedRandomRow;
  List<dynamic>? _filteredDataRow;
  List<dynamic>? _filteredHeaders;

  double responsiveWidth(double percentage) =>
      SizeConfig.screenWidth * percentage;
  double responsiveHeight(double percentage) =>
      SizeConfig.screenHeight * percentage;

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
      duration: const Duration(seconds: 5),
    );
  }

  Future<void> _loadCsvData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    try {
      final String csvString = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/data/data.csv');

      final String firstLine = csvString.split('\n').first;
      final String detectedDelimiter =
          firstLine.contains(';') && !firstLine.contains(',') ? ';' : ',';

      final csvConverter = CsvToListConverter(
        fieldDelimiter: detectedDelimiter,
        shouldParseNumbers: false,
      );

      final List<List<dynamic>> result = csvConverter.convert(csvString);

      if (result.length > 1) {
        final random = Random();
        final int randomIndex = random.nextInt(result.length - 1) + 1;

        setState(() {
          _csvData = result;
          _selectedRandomRow = result[randomIndex];

          _filterData(_csvData, _selectedRandomRow!);

          if (_filteredDataRow != null && _filteredHeaders != null) {
            _interpretationResult = _interpretData(
              _filteredDataRow!,
              _filteredHeaders!,
            );
          }

          _step4IntroPlayed = false;
          _showResultAnimation = false;
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
            SizedBox(
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
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.k_primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(90),
          bottomRight: Radius.circular(90),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: responsiveWidth(0.05)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Image(
              image: AssetImage('assets/img/logo.jpg'),
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
          ),
          const Expanded(
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
        final int stepNumber = index + 1;
        final bool isActive = stepNumber == currentStep;
        final bool isCompleted = stepNumber < currentStep;

        return GestureDetector(
          onTap: () {
            setState(() {
              currentStep = stepNumber;
              if (currentStep == 4) {
                _clearStepFourForNewPick();
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.k_primary
                  : (isCompleted
                        ? AppColors.k_primary.withOpacity(0.5)
                        : AppColors.k_background),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.k_primary, width: 2),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.k_primary.withOpacity(0.3),
                        offset: const Offset(0, 4),
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
        return const SizedBox.shrink();
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
              child: const Padding(
                padding: EdgeInsets.all(20.0),
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
          const SizedBox(height: 20),
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
              child: const Padding(
                padding: EdgeInsets.all(20.0),
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
                currentStep = (currentStep > 1) ? currentStep - 1 : 1;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.k_primary,
              side: BorderSide(color: AppColors.k_primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Précédent'),
          ),
          ElevatedButton(
            onPressed: _selectedConnectionMethod != null
                ? () {
                    setState(() {
                      currentStep++;
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.k_primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Suivant'),
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
            decoration: _inputDecoration('Nom de la patiente'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _birthDateController,
            decoration: _inputDecoration('Âge de la patiente'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            decoration: _inputDecoration('Adresse'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: _inputDecoration('Téléphone'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _regionController,
            decoration: _inputDecoration('Région'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _communeController,
            decoration: _inputDecoration('Commune'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _midwifeNameController,
            decoration: _inputDecoration('Nom de la sage-femme'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _doctorNameController,
            decoration: _inputDecoration('Nom du médecin'),
          ),
        ],
      ),
      actions: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(onPressed: () {}, child: const Text('Réinitialiser')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                currentStep++;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.k_primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Suivant'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.k_primary),
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
                const SizedBox(height: 10),
                const Text(
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
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Icon(Icons.list, size: 40),
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
          const SizedBox(height: 30),
          if (!_isLoading &&
              _filteredDataRow != null &&
              _filteredHeaders != null)
            SizedBox(
              height: 300,
              child: SingleChildScrollView(
                child: _buildDataCard(
                  headers: _filteredHeaders!,
                  data: _filteredDataRow!,
                ),
              ),
            ),
          if (!_isLoading &&
              (_filteredDataRow == null || _filteredHeaders == null))
            const Text('Appuyez sur "Afficher" pour charger les données.'),
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
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(data.length, (colIndex) {
            if (colIndex >= headers.length) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${headers[colIndex]}:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data[colIndex]}',
                  style: const TextStyle(color: Colors.black87),
                ),
                if (colIndex < data.length - 1) const SizedBox(height: 16),
              ],
            );
          }),
        ),
      ),
    );
  }

  InterpretationResult _pickRandomResult() {
    const options = [
      InterpretationResult.ok,
      InterpretationResult.alert,
      InterpretationResult.danger,
    ];

    if (_lastRandomResult == null) {
      final r = options[_rng.nextInt(options.length)];
      _lastRandomResult = r;
      return r;
    }

    final filtered = options.where((r) => r != _lastRandomResult).toList();
    final choice = filtered[_rng.nextInt(filtered.length)];
    _lastRandomResult = choice;
    return choice;
  }

  void _clearStepFourForNewPick() {
    _step4IntroPlayed = false;
    _step4ShowingIntro = false;
    _showResultAnimation = false;
    _interpretationResult = InterpretationResult.unknown;
  }

  Widget _buildStepFour() {
    if (!_step4IntroPlayed && !_step4ShowingIntro) {
      final int epochAtStart = _resetEpoch;
      Future.microtask(() {
        if (!mounted || epochAtStart != _resetEpoch) return;
        final next = _pickRandomResult();
        setState(() {
          if (epochAtStart != _resetEpoch) return;
          _interpretationResult = next;
          _step4ShowingIntro = true;
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted || epochAtStart != _resetEpoch) return;
          setState(() {
            if (epochAtStart != _resetEpoch) return;
            _step4ShowingIntro = false;
            _step4IntroPlayed = true;
            _showResultAnimation = true;
          });
        });
      });
    }

    return _buildStepCard(
      title: 'Interprétation',
      content: Column(
        children: [
          if (_step4ShowingIntro)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Lottie.asset(
                'assets/img/ctg.json',
                width: responsiveWidth(0.8),
                height: responsiveHeight(0.25),
                fit: BoxFit.contain,
              ),
            ),

          if (_interpretationResult != InterpretationResult.unknown &&
              !_step4ShowingIntro)
            AnimatedOpacity(
              opacity: _showResultAnimation ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 600),
              child: Column(
                children: [
                  const Text(
                    'Résultat de l\'analyse :',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
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
                        label: 'Urgence',
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildInterpretationText(_interpretationResult),
                ],
              ),
            ),

          if (_interpretationResult == InterpretationResult.unknown &&
              !_step4ShowingIntro)
            const Text(
              'Préparation de l’analyse...',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
        ],
      ),
      actions: _buildNavigationButtons(),
    );
  }

  Widget _buildInterpretationText(InterpretationResult result) {
    String text;
    Color textColor;
    Color containerColor;

    switch (result) {
      case InterpretationResult.ok:
        text =
            'Tout est en ordre : les indicateurs sont conformes aux normes de référence. '
            'Continuez la surveillance habituelle.';
        textColor = Colors.green[800]!;
        containerColor = Colors.green[50]!;
        break;
      case InterpretationResult.alert:
        text =
            'Niveau d\'alerte : certains indicateurs sont hors des valeurs normales. '
            'Une attention particulière est recommandée.';
        textColor = Colors.orange[800]!;
        containerColor = Colors.orange[50]!;
        break;
      case InterpretationResult.danger:
        text =
            'Situation d\'urgence : une prise en charge immédiate est requise. '
            'Les indicateurs vitaux sont en dehors des seuils critiques. Veuillez contacter le médecin traitant.';
        textColor = Colors.red[800]!;
        containerColor = Colors.red[50]!;
        break;
      default:
        text = '';
        textColor = Colors.grey[600]!;
        containerColor = Colors.grey[200]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: textColor.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        textAlign: TextAlign.center,
      ),
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
            child: const Center(
              child: Icon(Icons.circle, color: Colors.white, size: 40),
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

  Widget _buildStepCard({
    required String title,
    required Widget content,
    required Widget actions,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.k_primary,
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          content,
          const SizedBox(height: 24),
          actions,
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final bool isLastStep = currentStep >= 4;
    final bool isStepThree = currentStep == 3;

    final bool canGoNext =
        !isLastStep && (!isStepThree || _isStepThreeDataReady);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: currentStep > 1
              ? () {
                  setState(() {
                    currentStep = (currentStep > 1) ? currentStep - 1 : 1;
                    if (currentStep == 4) _clearStepFourForNewPick();
                  });
                }
              : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.k_primary,
            side: BorderSide(color: AppColors.k_primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Précédent'),
        ),

        if (!isLastStep)
          ElevatedButton(
            onPressed: canGoNext
                ? () {
                    setState(() {
                      currentStep++;
                      if (currentStep == 4) {
                        _clearStepFourForNewPick();
                      }
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.k_primary,
              foregroundColor: AppColors.k_background,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Suivant'),
          )
        else
          Row(
            children: [
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _hardReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.k_primary,
                  foregroundColor: AppColors.k_background,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Réinitialiser'),
              ),
            ],
          ),
      ],
    );
  }

  void _hardReset() {
    setState(() {
      _resetEpoch++;
      currentStep = 1;
      _selectedConnectionMethod = null;
      _isLoading = false;
      _interpretationResult = InterpretationResult.unknown;
      _showResultAnimation = false;
      _step4ShowingIntro = false;
      _step4IntroPlayed = false;
      _lastRandomResult = null;
      _patientController.clear();
      _birthDateController.clear();
      _nerfNameController.clear();
      _addressController.clear();
      _phoneController.clear();
      _regionController.clear();
      _communeController.clear();
      _midwifeNameController.clear();
      _doctorNameController.clear();
      _csvData = [];
      _selectedRandomRow = null;
      _filteredDataRow = null;
      _filteredHeaders = null;
    });
  }

  void _filterData(List<List<dynamic>> allData, List<dynamic> row) {
    if (allData.isEmpty) return;

    final List<dynamic> rawHeaders = allData[0];
    final List<String> headers = rawHeaders
        .map((h) => h.toString().trim().toLowerCase())
        .toList();

    final List<String> baselineCandidates = [
      'baseline value',
      'baseline_value',
      'baseline',
      'baselinevalue',
    ];
    final List<String> dateCandidates = [
      'date_analyse',
      'date analyse',
      'date analyse ctg',
      'date',
      'analysis_date',
    ];

    int _findHeaderIndex(List<String> candidates) {
      for (final cand in candidates) {
        final idx = headers.indexOf(cand);
        if (idx != -1) return idx;
      }
      return -1;
    }

    final int startIndex = _findHeaderIndex(baselineCandidates);
    final int endIndex = _findHeaderIndex(dateCandidates);

    if (startIndex == -1 || endIndex == -1 || startIndex > endIndex) {
      print('Champs de début ou de fin non trouvés.');
      print('En-têtes détectés: $headers');
      setState(() {
        _filteredDataRow = null;
        _filteredHeaders = null;
      });
      return;
    }

    final List<dynamic> newHeaders = rawHeaders.sublist(
      startIndex,
      endIndex + 1,
    );
    final List<dynamic> newRow = row.sublist(startIndex, endIndex + 1);

    setState(() {
      _filteredHeaders = newHeaders;
      _filteredDataRow = newRow;
    });
  }

  InterpretationResult _interpretData(
    List<dynamic> data,
    List<dynamic> headers,
  ) {
    final List<String> normHeaders = headers
        .map((h) => h.toString().trim().toLowerCase())
        .toList();

    int baselineIndex = normHeaders.indexOf('baseline value');
    if (baselineIndex == -1)
      baselineIndex = normHeaders.indexOf('baseline_value');
    if (baselineIndex == -1) baselineIndex = normHeaders.indexOf('baseline');
    if (baselineIndex == -1)
      baselineIndex = normHeaders.indexOf('baselinevalue');

    if (baselineIndex == -1 || baselineIndex >= data.length) {
      return InterpretationResult.unknown;
    }

    final dynamic rawVal = data[baselineIndex];

    num? _toNum(dynamic v) {
      if (v is num) return v;
      if (v is String) {
        final s = v.trim().replaceAll(' ', '');
        final s2 = s.contains(',') && !s.contains('.')
            ? s.replaceAll(',', '.')
            : s;
        return num.tryParse(s2);
      }
      return null;
    }

    final num? baselineValue = _toNum(rawVal);
    if (baselineValue == null) return InterpretationResult.unknown;

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
