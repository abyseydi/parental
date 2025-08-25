import 'package:flutter/material.dart';

class CustomButtons {
  // Bouton Élémentaire
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
    required Color textcolor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(200, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: TextStyle(color: textcolor)),
    );
  }

  // Bouton Secondaire (à contours)
  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
    Color borderColor = Colors.blue,
    Color textColor = Colors.blue,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(width: 2, color: borderColor),
        minimumSize: Size(200, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }

  // Bouton Icône
  static Widget iconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.blue,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
    );
  }
}
