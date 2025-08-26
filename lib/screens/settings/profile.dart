import 'package:flutter/material.dart';
import 'package:perantal/screens/settings/notification.dart';
import 'package:perantal/utils/colors.dart';
import 'package:perantal/widgets/app_bar.dart';

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

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  double responsiveWidth(double percentage) {
    return SizeConfig.screenWidth * percentage;
  }

  double responsiveHeight(double percentage) {
    return SizeConfig.screenHeight * percentage;
  }

  @override
  Widget build(BuildContext context) {
    // Initialise SizeConfig
    SizeConfig().init(context);

    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: AppColors.k_background,
      body: Column(
        children: [
          _buildHeader(), // L'en-tête est en dehors du SingleChildScrollView
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveWidth(0.05),
                ),
                child: Column(
                  children: [
                    SizedBox(height: responsiveHeight(0.04)),
                    _buildProfileHeader(),
                    const SizedBox(height: 30),
                    _buildInfoSection(),
                    const SizedBox(height: 20),
                    _buildActionSection(),
                    SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.k_primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(90),
          bottomRight: Radius.circular(90),
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            SizedBox(width: 50),
            Padding(
              padding: EdgeInsets.only(right: 80),
              child: Text(
                'PROFIL',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.k_background,
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
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Icon(
                  Icons.notifications_none,
                  color: AppColors.k_background,
                  size: responsiveHeight(0.04),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.person_outline,
            size: 80,
            color: AppColors.k_primary,
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Dibor SENE',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Sage-Femme',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            // Logique pour modifier le profil
          },
          icon: const Icon(Icons.edit, size: 20),
          label: const Text('Modifier le profil'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.k_primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Column(
        children: [
          _buildListTile(
            title: 'Mes patientes',
            icon: Icons.people_outline,
            onTap: () {},
          ),
          _buildDivider(),
          _buildListTile(
            title: 'Historique des CTG',
            icon: Icons.list_alt,
            onTap: () {},
          ),
          _buildDivider(),
          _buildListTile(
            title: 'Mes rendez-vous',
            icon: Icons.calendar_today_outlined,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Column(
        children: [
          _buildListTile(
            title: 'Paramètres de l\'application',
            icon: Icons.settings_outlined,
            onTap: () {},
          ),
          _buildDivider(),
          _buildListTile(
            title: 'Aide & support',
            icon: Icons.help_outline,
            onTap: () {},
          ),
          _buildDivider(),
          _buildListTile(
            title: 'Déconnexion',
            icon: Icons.logout,
            color: Colors.red,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(height: 1, color: Colors.grey[300]),
    );
  }
}
