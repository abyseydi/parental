// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:perantal/screens/settings/notification.dart';
// import 'dart:math';

// import 'package:perantal/utils/colors.dart';
// import 'package:perantal/widgets/app_bar.dart';
// import 'package:csv/csv.dart';

// class SizeConfig {
//   static late MediaQueryData _mediaQueryData;
//   static late double screenWidth;
//   static late double screenHeight;

//   void init(BuildContext context) {
//     _mediaQueryData = MediaQuery.of(context);
//     screenWidth = _mediaQueryData.size.width;
//     screenHeight = _mediaQueryData.size.height;
//   }

//   @override
//   Size get preferredSize => Size.fromHeight(kToolbarHeight);
// }

// class HomePage extends StatefulWidget {
//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage>
//     with SingleTickerProviderStateMixin {
//   int currentStep = 1;
//   String? _selectedConnectionMethod;
//   late AnimationController _controller;
//   bool _isLoading = false;
//   InterpretationResult _interpretationResult = InterpretationResult.unknown;
//   bool _showResultAnimation = false;
//   final TextEditingController _patientController = TextEditingController();
//   final TextEditingController _birthDateController = TextEditingController();
//   final TextEditingController _nerfNameController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _regionController = TextEditingController();
//   final TextEditingController _communeController = TextEditingController();
//   final TextEditingController _midwifeNameController = TextEditingController();
//   final TextEditingController _doctorNameController = TextEditingController();
//   bool _step4ShowingIntro = false; // on affiche l’animation Lottie ?
//   bool _step4IntroPlayed =
//       false; // l’animation a déjà été jouée pour ces résultats ?

//   List<List<dynamic>> _csvData = [];
//   List<dynamic>? _selectedRandomRow;
//   List<dynamic>? _filteredDataRow;
//   List<dynamic>? _filteredHeaders;
//   double responsiveWidth(double percentage) {
//     return SizeConfig.screenWidth * percentage;
//   }

//   double responsiveHeight(double percentage) {
//     return SizeConfig.screenHeight * percentage;
//   }

//   @override
//   void dispose() {
//     _patientController.dispose();
//     _birthDateController.dispose();
//     _nerfNameController.dispose();
//     _addressController.dispose();
//     _phoneController.dispose();
//     _regionController.dispose();
//     _communeController.dispose();
//     _midwifeNameController.dispose();
//     _doctorNameController.dispose();
//     _controller.dispose();

//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 5),
//     );
//   }

//   Future<void> _loadCsvData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     await Future.delayed(const Duration(seconds: 1));

//     try {
//       final String csvString = await DefaultAssetBundle.of(
//         context,
//       ).loadString('assets/data/data.csv');

//       // Détection simple du délimiteur
//       final String firstLine = csvString.split('\n').first;
//       final String detectedDelimiter =
//           firstLine.contains(';') && !firstLine.contains(',') ? ';' : ',';

//       final csvConverter = CsvToListConverter(
//         fieldDelimiter: detectedDelimiter,
//         shouldParseNumbers: false, // on gère nous-mêmes plus tard
//       );

//       final List<List<dynamic>> result = csvConverter.convert(csvString);

//       if (result.length > 1) {
//         final random = Random();
//         final int randomIndex = random.nextInt(result.length - 1) + 1;

//         setState(() {
//           _csvData = result;
//           _selectedRandomRow = result[randomIndex];

//           _filterData(_csvData, _selectedRandomRow!);

//           if (_filteredDataRow != null && _filteredHeaders != null) {
//             _interpretationResult = _interpretData(
//               _filteredDataRow!,
//               _filteredHeaders!,
//             );
//           }

//           _step4IntroPlayed = false;
//           _showResultAnimation = false;
//         });
//       } else {
//         setState(() {
//           _csvData = result;
//           _selectedRandomRow = null;
//           _filteredDataRow = null;
//           _filteredHeaders = null;
//         });
//       }
//     } catch (e) {
//       print('Erreur lors de la lecture du fichier CSV : $e');
//       setState(() {
//         _selectedRandomRow = null;
//         _filteredDataRow = null;
//         _filteredHeaders = null;
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);

//     return Scaffold(
//       appBar: CustomAppBar(),
//       backgroundColor: AppColors.k_background,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             _buildHeader(),
//             SizedBox(height: responsiveHeight(0.02)),
//             Container(
//               width: responsiveWidth(1),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [_buildStepIndicator()],
//               ),
//             ),
//             SizedBox(height: responsiveHeight(0.04)),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: responsiveWidth(0.05)),
//               child: _getStepContent(),
//             ),
//             SizedBox(height: 60),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.k_primary,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(90),
//           bottomRight: Radius.circular(90),
//         ),
//       ),
//       padding: EdgeInsets.symmetric(horizontal: responsiveWidth(0.05)),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(15.0),
//             child: Image.asset(
//               'assets/img/logo.jpg',
//               height: responsiveHeight(0.1),
//               width: responsiveWidth(0.1),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               'PERANTAL',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => Notifications()),
//               );
//             },
//             child: Icon(
//               Icons.notifications_none,
//               color: AppColors.k_background,
//               size: responsiveHeight(0.04),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStepIndicator() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(4, (index) {
//         int stepNumber = index + 1;
//         bool isActive = stepNumber == currentStep;
//         bool isCompleted = stepNumber < currentStep;

//         return GestureDetector(
//           onTap: () {
//             setState(() {
//               currentStep = stepNumber;
//             });
//           },
//           child: AnimatedContainer(
//             duration: Duration(milliseconds: 300),
//             margin: EdgeInsets.symmetric(horizontal: 20),
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               color: isActive
//                   ? AppColors.k_primary
//                   : (isCompleted
//                         ? AppColors.k_primary.withOpacity(0.5)
//                         : AppColors.k_background),
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: isActive ? AppColors.k_primary : AppColors.k_primary,
//                 width: 2,
//               ),
//               boxShadow: isActive
//                   ? [
//                       BoxShadow(
//                         color: AppColors.k_primary.withOpacity(0.3),
//                         offset: Offset(0, 4),
//                         blurRadius: 8,
//                       ),
//                     ]
//                   : [],
//             ),
//             child: Center(
//               child: Text(
//                 '$stepNumber',
//                 style: TextStyle(
//                   color: isActive ? Colors.white : AppColors.k_primary,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _getStepContent() {
//     switch (currentStep) {
//       case 1:
//         return _buildStepOne();
//       case 2:
//         return _buildStepTwo();
//       case 3:
//         return _buildStepThree();
//       case 4:
//         return _buildStepFour();
//       default:
//         return Container();
//     }
//   }

//   Widget _buildStepOne() {
//     return _buildStepCard(
//       title: 'Sélectionner le mode de connexion',
//       content: Column(
//         children: [
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 _selectedConnectionMethod = 'Wi-Fi';
//               });
//             },
//             child: Card(
//               elevation: _selectedConnectionMethod == 'Wi-Fi' ? 8 : 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 side: BorderSide(
//                   color: _selectedConnectionMethod == 'Wi-Fi'
//                       ? AppColors.k_primary
//                       : Colors.transparent,
//                   width: 2,
//                 ),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Row(
//                   children: [
//                     Icon(Icons.wifi, size: 40, color: AppColors.k_primary),
//                     SizedBox(width: 20),
//                     Text(
//                       'Connexion Wi-Fi',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 20),
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 _selectedConnectionMethod = 'Bluetooth';
//               });
//             },
//             child: Card(
//               elevation: _selectedConnectionMethod == 'Bluetooth' ? 8 : 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 side: BorderSide(
//                   color: _selectedConnectionMethod == 'Bluetooth'
//                       ? AppColors.k_primary
//                       : Colors.transparent,
//                   width: 2,
//                 ),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Row(
//                   children: [
//                     Icon(Icons.bluetooth, size: 40, color: AppColors.k_primary),
//                     SizedBox(width: 20),
//                     Text(
//                       'Connexion Bluetooth',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       actions: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           OutlinedButton(
//             onPressed: () {
//               setState(() {
//                 currentStep--;
//               });
//             },
//             child: Text('Précédent'),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: AppColors.k_primary,
//               side: BorderSide(color: AppColors.k_primary),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: _selectedConnectionMethod != null
//                 ? () {
//                     // if (_selectedConnectionMethod == 'Wi-Fi') {
//                     //   OpenSettings.openWIFISetting();
//                     // } else if (_selectedConnectionMethod == 'Bluetooth') {
//                     //   OpenSettings.openBluetoothSetting();
//                     // }

//                     setState(() {
//                       currentStep++;
//                     });
//                   }
//                 : null,
//             child: Text('Suivant'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.k_primary,
//               foregroundColor: Colors.white,
//               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStepTwo() {
//     return _buildStepCard(
//       title: 'Informations de la patiente',
//       content: Column(
//         children: [
//           TextField(
//             controller: _patientController,
//             decoration: InputDecoration(
//               labelText: 'Nom de la patiente',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: Colors.grey[300]!),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: AppColors.k_primary),
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           TextField(
//             controller: _birthDateController,
//             decoration: InputDecoration(
//               labelText: 'Âge de la patiente',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: Colors.grey[300]!),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: AppColors.k_primary),
//               ),
//             ),
//             keyboardType: TextInputType.number,
//           ),
//           SizedBox(height: 16),

//           TextField(
//             controller: _addressController,
//             decoration: InputDecoration(
//               labelText: 'Adresse',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: Colors.grey[300]!),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: AppColors.k_primary),
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           TextField(
//             controller: _phoneController,
//             decoration: InputDecoration(
//               labelText: 'Téléphone',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: Colors.grey[300]!),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: AppColors.k_primary),
//               ),
//             ),
//             keyboardType: TextInputType.phone,
//           ),
//           SizedBox(height: 16),
//           TextField(
//             controller: _regionController,
//             decoration: InputDecoration(
//               labelText: 'Région',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: Colors.grey[300]!),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: AppColors.k_primary),
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           TextField(
//             controller: _communeController,
//             decoration: InputDecoration(
//               labelText: 'Commune',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: Colors.grey[300]!),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: AppColors.k_primary),
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           TextField(
//             controller: _midwifeNameController,
//             decoration: InputDecoration(
//               labelText: 'Nom de la sage-femme',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: Colors.grey[300]!),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: AppColors.k_primary),
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           TextField(
//             controller: _doctorNameController,
//             decoration: InputDecoration(
//               labelText: 'Nom du médecin',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: Colors.grey[300]!),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: AppColors.k_primary),
//               ),
//             ),
//           ),
//         ],
//       ),
//       actions: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           TextButton(
//             onPressed: () {
//               // Action pour réinitialiser
//             },
//             child: Text('Réinitialiser'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (_patientController.text.isNotEmpty &&
//                   _birthDateController.text.isNotEmpty &&
//                   _nerfNameController.text.isNotEmpty &&
//                   _addressController.text.isNotEmpty &&
//                   _phoneController.text.isNotEmpty &&
//                   _regionController.text.isNotEmpty &&
//                   _communeController.text.isNotEmpty &&
//                   _midwifeNameController.text.isNotEmpty &&
//                   _doctorNameController.text.isNotEmpty) {
//                 setState(() {
//                   currentStep++;
//                 });
//               } else {
//                 // ScaffoldMessenger.of(context).showSnackBar(
//                 //   SnackBar(
//                 //     content: Text(
//                 //       'Veuillez remplir tous les champs obligatoires.',
//                 //     ),
//                 //   ),
//                 // );
//                 setState(() {
//                   currentStep++;
//                 });
//               }
//             },
//             child: Text('Suivant'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.k_primary,
//               foregroundColor: Colors.white,
//               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStepThree() {
//     return _buildStepCard(
//       title: 'Résultats du CTG',
//       content: Column(
//         children: [
//           if (_isLoading)
//             Column(
//               children: [
//                 Lottie.asset(
//                   'assets/img/ctg.json',
//                   width: responsiveWidth(1),
//                   height: responsiveHeight(0.08),
//                   fit: BoxFit.contain,
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   'Chargement en cours...',
//                   style: TextStyle(fontStyle: FontStyle.italic),
//                 ),
//               ],
//             ),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               GestureDetector(
//                 onTap: _isLoading ? null : _loadCsvData,
//                 child: Card(
//                   elevation: 8,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                     side: BorderSide(color: AppColors.k_primary, width: 2),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Row(
//                       children: [
//                         Icon(Icons.list, size: 40, color: AppColors.k_primary),
//                         SizedBox(width: 20),
//                         Text(
//                           'Afficher',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 30),

//           if (!_isLoading &&
//               _filteredDataRow != null &&
//               _filteredHeaders != null)
//             Container(
//               height: 300,
//               child: SingleChildScrollView(
//                 child: _buildDataCard(
//                   headers: _filteredHeaders!,
//                   data: _filteredDataRow!,
//                 ),
//               ),
//             ),

//           if (!_isLoading &&
//               (_filteredDataRow == null || _filteredHeaders == null))
//             Text('Appuyez sur "Afficher" pour charger les données.'),
//         ],
//       ),
//       actions: _buildNavigationButtons(),
//     );
//   }

//   Widget _buildDataCard({
//     required List<dynamic> headers,
//     required List<dynamic> data,
//   }) {
//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: List.generate(data.length, (colIndex) {
//             if (colIndex >= headers.length) {
//               return Container();
//             }
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '${headers[colIndex]}:',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   '${data[colIndex]}',
//                   style: TextStyle(color: Colors.black87),
//                 ),
//                 if (colIndex < data.length - 1) SizedBox(height: 16),
//               ],
//             );
//           }),
//         ),
//       ),
//     );
//   }

//   Widget _buildStepFour() {
//     if (_interpretationResult != InterpretationResult.unknown &&
//         !_step4IntroPlayed &&
//         !_step4ShowingIntro) {
//       Future.microtask(() {
//         if (!mounted) return;
//         setState(() {
//           _step4ShowingIntro = true;
//         });
//         Future.delayed(const Duration(seconds: 3), () {
//           if (!mounted) return;
//           setState(() {
//             _step4ShowingIntro = false;
//             _step4IntroPlayed = true;
//             _showResultAnimation = true;
//           });
//         });
//       });
//     }

//     return _buildStepCard(
//       title: 'Interprétation',
//       content: Column(
//         children: [
//           if (_interpretationResult == InterpretationResult.unknown)
//             Text(
//               'Appuyez sur "Afficher" à l\'étape précédente pour générer l\'analyse.',
//               style: const TextStyle(fontStyle: FontStyle.italic),
//               textAlign: TextAlign.center,
//             ),

//           // 1) Splash Lottie de 3s
//           if (_interpretationResult != InterpretationResult.unknown &&
//               _step4ShowingIntro)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16.0),
//               child: Lottie.asset(
//                 'assets/img/ctg.json', // ← remplace par ton fichier
//                 width: responsiveWidth(0.8),
//                 height: responsiveHeight(0.25),
//                 fit: BoxFit.contain,
//               ),
//             ),

//           // 2) Résultat après l’intro (avec fondu)
//           if (_interpretationResult != InterpretationResult.unknown &&
//               !_step4ShowingIntro)
//             AnimatedOpacity(
//               opacity: _showResultAnimation ? 1.0 : 0.0,
//               duration: const Duration(milliseconds: 600),
//               child: Column(
//                 children: [
//                   const Text(
//                     'Résultat de l\'analyse :',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildAnimatedInterpretationBall(
//                         result: InterpretationResult.ok,
//                         currentInterpretation: _interpretationResult,
//                         color: Colors.green,
//                         label: 'OK',
//                       ),
//                       _buildAnimatedInterpretationBall(
//                         result: InterpretationResult.alert,
//                         currentInterpretation: _interpretationResult,
//                         color: Colors.orange,
//                         label: 'Alerte',
//                       ),
//                       _buildAnimatedInterpretationBall(
//                         result: InterpretationResult.danger,
//                         currentInterpretation: _interpretationResult,
//                         color: Colors.red,
//                         label: 'Urgence',
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 30),
//                   _buildInterpretationText(_interpretationResult),
//                 ],
//               ),
//             ),
//         ],
//       ),
//       actions: _buildNavigationButtons(),
//     );
//   }

//   Widget _buildInterpretationText(InterpretationResult result) {
//     String text;
//     Color textColor;
//     Color containerColor;

//     switch (result) {
//       case InterpretationResult.ok:
//         text =
//             'Tout est en ordre : les indicateurs sont conformes aux normes de référence. Continuez la surveillance habituelle.';
//         textColor = Colors.green[800]!;
//         containerColor = Colors.green[50]!;
//         break;
//       case InterpretationResult.alert:
//         text =
//             'Niveau d\'alerte : certains indicateurs sont hors des valeurs normales. Une attention particulière est recommandée.';
//         textColor = Colors.orange[800]!;
//         containerColor = Colors.orange[50]!;
//         break;
//       case InterpretationResult.danger:
//         text =
//             'Situation d\'urgence: une prise en charge immediate est requise. Les indicateurs vitaux sont en dehors des seuils critiques. veuillez contacter le medecin traitant.';
//         textColor = Colors.red[800]!;
//         containerColor = Colors.red[50]!;
//         break;
//       default:
//         text = '';
//         textColor = Colors.grey[600]!;
//         containerColor = Colors.grey[200]!;
//         break;
//     }

//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       margin: const EdgeInsets.symmetric(horizontal: 16.0),
//       decoration: BoxDecoration(
//         color: containerColor,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: textColor.withOpacity(0.5)),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 16,
//           fontStyle: FontStyle.italic,
//           fontWeight: FontWeight.bold,
//           color: textColor,
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }

//   Widget _buildAnimatedInterpretationBall({
//     required InterpretationResult result,
//     required InterpretationResult currentInterpretation,
//     required Color color,
//     required String label,
//   }) {
//     final isSelected = result == currentInterpretation;

//     return AnimatedOpacity(
//       duration: const Duration(milliseconds: 500),
//       opacity: isSelected ? 1.0 : 0.3,
//       child: Column(
//         children: [
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 500),
//             width: isSelected ? 90 : 80,
//             height: isSelected ? 90 : 80,
//             decoration: BoxDecoration(
//               color: color,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 if (isSelected)
//                   BoxShadow(
//                     color: color.withOpacity(0.6),
//                     blurRadius: 15,
//                     spreadRadius: 3,
//                   ),
//               ],
//             ),
//             child: Center(
//               child: Icon(
//                 Icons.circle,
//                 color: Colors.white,
//                 size: isSelected ? 40 : 30,
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: isSelected ? color : Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStepCard({
//     required String title,
//     required Widget content,
//     required Widget actions,
//   }) {
//     return Container(
//       padding: EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.k_primary,
//             offset: Offset(0, 4),
//             blurRadius: 10,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           SizedBox(height: 24),
//           content,
//           SizedBox(height: 24),
//           actions,
//         ],
//       ),
//     );
//   }

//   Widget _buildNavigationButtons() {
//     final bool isLastStep = currentStep >= 4;

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         // Précédent
//         OutlinedButton(
//           onPressed: currentStep > 1
//               ? () {
//                   setState(() {
//                     currentStep = (currentStep > 1) ? currentStep - 1 : 1;
//                   });
//                 }
//               : null,
//           child: const Text('Précédent'),
//           style: OutlinedButton.styleFrom(
//             foregroundColor: AppColors.k_primary,
//             side: BorderSide(color: AppColors.k_primary),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//           ),
//         ),

//         // À droite : soit Suivant, soit Réinitialiser + Accueil
//         if (!isLastStep)
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 currentStep++;
//               });
//             },
//             child: const Text('Suivant'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.k_primary,
//               foregroundColor: AppColors.k_background,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//           )
//         else
//           Row(
//             children: [
//               const SizedBox(width: 12),

//               // Accueil
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     currentStep = 1;

//                     _patientController.clear();
//                     _birthDateController.clear();
//                     _nerfNameController.clear();
//                     _addressController.clear();
//                     _phoneController.clear();
//                     _regionController.clear();
//                     _communeController.clear();
//                     _midwifeNameController.clear();
//                     _doctorNameController.clear();

//                     _csvData = [];
//                     _selectedRandomRow = null;
//                     _filteredDataRow = null;
//                     _filteredHeaders = null;
//                     _interpretationResult = InterpretationResult.unknown;
//                   });
//                 },
//                 child: const Text('Réinitialiser'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.k_primary,
//                   foregroundColor: AppColors.k_background,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 12,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//       ],
//     );
//   }

//   void _filterData(List<List<dynamic>> allData, List<dynamic> row) {
//     if (allData.isEmpty) return;

//     final List<dynamic> rawHeaders = allData[0];
//     final List<String> headers = rawHeaders
//         .map((h) => h.toString().trim().toLowerCase())
//         .toList();

//     // Variantes possibles
//     final List<String> baselineCandidates = [
//       'baseline value',
//       'baseline_value',
//       'baseline',
//       'baselinevalue',
//     ];
//     final List<String> dateCandidates = [
//       'date_analyse',
//       'date analyse',
//       'date analyse ctg',
//       'date',
//       'analysis_date',
//     ];

//     int _findHeaderIndex(List<String> candidates) {
//       for (final cand in candidates) {
//         final idx = headers.indexOf(cand);
//         if (idx != -1) return idx;
//       }
//       return -1;
//     }

//     final int startIndex = _findHeaderIndex(baselineCandidates);
//     final int endIndex = _findHeaderIndex(dateCandidates);

//     if (startIndex == -1 || endIndex == -1 || startIndex > endIndex) {
//       print('Champs de début ou de fin non trouvés.');
//       print('En-têtes détectés: $headers'); // **Debug utile**
//       setState(() {
//         _filteredDataRow = null;
//         _filteredHeaders = null;
//       });
//       return;
//     }

//     final List<dynamic> newHeaders = rawHeaders.sublist(
//       startIndex,
//       endIndex + 1,
//     );
//     final List<dynamic> newRow = row.sublist(startIndex, endIndex + 1);

//     setState(() {
//       _filteredHeaders = newHeaders;
//       _filteredDataRow = newRow;
//     });
//   }

//   InterpretationResult _interpretData(
//     List<dynamic> data,
//     List<dynamic> headers,
//   ) {
//     final List<String> normHeaders = headers
//         .map((h) => h.toString().trim().toLowerCase())
//         .toList();

//     int baselineIndex = normHeaders.indexOf('baseline value');
//     if (baselineIndex == -1)
//       baselineIndex = normHeaders.indexOf('baseline_value');
//     if (baselineIndex == -1) baselineIndex = normHeaders.indexOf('baseline');
//     if (baselineIndex == -1)
//       baselineIndex = normHeaders.indexOf('baselinevalue');

//     if (baselineIndex == -1 || baselineIndex >= data.length) {
//       return InterpretationResult.unknown;
//     }

//     final dynamic rawVal = data[baselineIndex];

//     num? _toNum(dynamic v) {
//       if (v is num) return v;
//       if (v is String) {
//         final s = v.trim().replaceAll(' ', '');
//         final s2 = s.contains(',') && !s.contains('.')
//             ? s.replaceAll(',', '.')
//             : s;
//         return num.tryParse(s2);
//       }
//       return null;
//     }

//     final num? baselineValue = _toNum(rawVal);
//     if (baselineValue == null) return InterpretationResult.unknown;

//     if (baselineValue > 150) {
//       return InterpretationResult.danger;
//     } else if (baselineValue >= 130) {
//       return InterpretationResult.alert;
//     } else {
//       return InterpretationResult.ok;
//     }
//   }
// }

// enum InterpretationResult { ok, alert, danger, unknown }

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
  InterpretationResult _interpretationResult = InterpretationResult.unknown;
  bool _showResultAnimation = false;

  // --- Random result (StepFour) ---
  final Random _rng = Random();
  InterpretationResult? _lastRandomResult;

  final TextEditingController _patientController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _nerfNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _communeController = TextEditingController();
  final TextEditingController _midwifeNameController = TextEditingController();
  final TextEditingController _doctorNameController = TextEditingController();
  bool _step4ShowingIntro = false; // on affiche l’animation Lottie ?
  bool _step4IntroPlayed =
      false; // l’animation a déjà été jouée pour ces résultats ?

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

      // Détection simple du délimiteur
      final String firstLine = csvString.split('\n').first;
      final String detectedDelimiter =
          firstLine.contains(';') && !firstLine.contains(',') ? ';' : ',';

      final csvConverter = CsvToListConverter(
        fieldDelimiter: detectedDelimiter,
        shouldParseNumbers: false, // on gère nous-mêmes plus tard
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

              // --- reset StepFour pour relancer un tirage ---
              if (currentStep == 4) {
                _step4IntroPlayed = false;
                _step4ShowingIntro = false;
                _showResultAnimation = false;
                _interpretationResult = InterpretationResult.unknown;
              }
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
            Container(
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

  // ---- Random pick helper (StepFour) ----
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

    // Exclure le dernier résultat pour éviter deux fois de suite
    final filtered = options.where((r) => r != _lastRandomResult).toList();
    final choice = filtered[_rng.nextInt(filtered.length)];
    _lastRandomResult = choice;
    return choice;
  }

  Widget _buildStepFour() {
    // Tirage aléatoire à l'entrée sur StepFour (et relance de l'intro)
    if (!_step4IntroPlayed && !_step4ShowingIntro) {
      Future.microtask(() {
        if (!mounted) return;
        final next = _pickRandomResult(); // tirage ici
        setState(() {
          _interpretationResult = next;
          _step4ShowingIntro = true;
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted) return;
          setState(() {
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
          if (_interpretationResult == InterpretationResult.unknown &&
              !_step4ShowingIntro)
            Text(
              'Préparation de l’analyse...',
              style: const TextStyle(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),

          // 1) Splash Lottie de 3s
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

          // 2) Résultat après l’intro (avec fondu)
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
            'Tout est en ordre : les indicateurs sont conformes aux normes de référence. Continuez la surveillance habituelle.';
        textColor = Colors.green[800]!;
        containerColor = Colors.green[50]!;
        break;
      case InterpretationResult.alert:
        text =
            'Niveau d\'alerte : certains indicateurs sont hors des valeurs normales. Une attention particulière est recommandée.';
        textColor = Colors.orange[800]!;
        containerColor = Colors.orange[50]!;
        break;
      case InterpretationResult.danger:
        text =
            'Situation d\'urgence: une prise en charge immediate est requise. Les indicateurs vitaux sont en dehors des seuils critiques. veuillez contacter le medecin traitant.';
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
    final bool isLastStep = currentStep >= 4;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Précédent
        OutlinedButton(
          onPressed: currentStep > 1
              ? () {
                  setState(() {
                    currentStep = (currentStep > 1) ? currentStep - 1 : 1;
                  });
                }
              : null,
          child: const Text('Précédent'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.k_primary,
            side: BorderSide(color: AppColors.k_primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),

        // À droite : soit Suivant, soit Réinitialiser
        if (!isLastStep)
          ElevatedButton(
            onPressed: () {
              setState(() {
                currentStep++;
                if (currentStep == 4) {
                  // Reset StepFour pour forcer un nouveau tirage
                  _step4IntroPlayed = false;
                  _step4ShowingIntro = false;
                  _showResultAnimation = false;
                  _interpretationResult = InterpretationResult.unknown;
                }
              });
            },
            child: const Text('Suivant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.k_primary,
              foregroundColor: AppColors.k_background,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          )
        else
          Row(
            children: [
              const SizedBox(width: 12),

              // Réinitialiser l'assistant
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // remet l’assistant au début
                    currentStep = 1;

                    // vide les champs
                    _patientController.clear();
                    _birthDateController.clear();
                    _nerfNameController.clear();
                    _addressController.clear();
                    _phoneController.clear();
                    _regionController.clear();
                    _communeController.clear();
                    _midwifeNameController.clear();
                    _doctorNameController.clear();

                    // vide les données CSV / états
                    _csvData = [];
                    _selectedRandomRow = null;
                    _filteredDataRow = null;
                    _filteredHeaders = null;
                    _interpretationResult = InterpretationResult.unknown;

                    // Reset animations StepFour
                    _step4IntroPlayed = false;
                    _step4ShowingIntro = false;
                    _showResultAnimation = false;
                  });
                },
                child: const Text('Réinitialiser'),
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
              ),
            ],
          ),
      ],
    );
  }

  void _filterData(List<List<dynamic>> allData, List<dynamic> row) {
    if (allData.isEmpty) return;

    final List<dynamic> rawHeaders = allData[0];
    final List<String> headers = rawHeaders
        .map((h) => h.toString().trim().toLowerCase())
        .toList();

    // Variantes possibles
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
      print('En-têtes détectés: $headers'); // **Debug utile**
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
        // gère 150,2 -> 150.2
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
