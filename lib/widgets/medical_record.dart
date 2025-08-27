import 'package:flutter/material.dart';

class MedicalRecordDialog extends StatefulWidget {
  @override
  _MedicalRecordDialogState createState() => _MedicalRecordDialogState();
}

class _MedicalRecordDialogState extends State<MedicalRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  String nomPatiente = '';
  String agePatiente = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Remplir le dossier médical'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Nom de la patiente'),
              validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              onSaved: (value) => nomPatiente = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Âge de la patiente'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              onSaved: (value) => agePatiente = value!,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            final form = _formKey.currentState;
            if (form != null && form.validate()) {
              form.save();
              Navigator.of(
                context,
              ).pop({'nom': nomPatiente, 'age': agePatiente});
            }
          },
          child: Text('Valider'),
        ),
      ],
    );
  }
}
