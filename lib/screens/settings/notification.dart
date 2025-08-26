import 'package:flutter/material.dart';
import 'package:perantal/utils/colors.dart';
import 'package:perantal/widgets/app_bar.dart';
import 'package:intl/intl.dart';

// Définissez une classe pour représenter une notification
class NotificationModel {
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final IconData icon;

  NotificationModel({
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.icon = Icons.notifications_none,
  });
}

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  // Liste de notifications fictives pour la démonstration
  final List<NotificationModel> _notifications = [
    NotificationModel(
      title: 'Analyse CTG prête',
      message: 'L\'analyse du CTG de la patiente N. Prénom est disponible.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
      icon: Icons.check_circle_outline,
    ),
    NotificationModel(
      title: 'Rappel de rendez-vous',
      message: 'Rendez-vous avec la patiente A. Béranger demain à 10h00.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      icon: Icons.calendar_today_outlined,
    ),
    NotificationModel(
      title: 'Mise à jour de l\'application',
      message:
          'Une nouvelle version est disponible. Mettez à jour pour de nouvelles fonctionnalités.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      icon: Icons.system_update_alt_outlined,
    ),
    NotificationModel(
      title: 'Alerte d\'urgence !',
      message:
          'Un indicateur vital est en dehors des seuils critiques. Vérifiez le dossier de la patiente M. Dubois.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      icon: Icons.warning_amber_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: AppColors.k_background,
      body: Column(
        children: [
          // L'en-tête pour le titre de la page
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Génère la liste de notifications
                    ..._notifications.map((notification) {
                      return _buildNotificationCard(notification);
                    }).toList(),
                    const SizedBox(height: 20),
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
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(
                  context,
                ); // Cette ligne permet de revenir à la page précédente
              },
              child: Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            SizedBox(width: 50),
            Padding(
              padding: EdgeInsets.only(right: 80),
              child: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.k_background,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: notification.isRead
          ? Colors.white
          : Colors.blue[50], // Couleur pour les notifications non lues
      child: ListTile(
        leading: Icon(
          notification.icon,
          color: notification.isRead ? Colors.grey : AppColors.k_primary,
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(notification.timestamp),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.k_primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          // Logique pour marquer la notification comme lue et naviguer
          setState(() {
            // Un exemple simple: ne change l'état que si elle n'est pas lue
            if (!notification.isRead) {
              // Dans une vraie application, vous mettez à jour votre modèle de données
              // notification.isRead = true; // Non modifiable, car final. Il faudrait recréer l'objet
            }
          });
        },
      ),
    );
  }
}
