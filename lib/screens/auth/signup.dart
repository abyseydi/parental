import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perantal/utils/colors.dart';
import 'package:perantal/utils/size_config.dart';
import 'package:perantal/widgets/bottom_nav_bar.dart'; // <-- pour MainScreen

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameCtrl = TextEditingController();
  final _lastnameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePw = true;
  bool _obscurePw2 = true;
  bool _loading = false;
  bool _acceptTerms = false; // décoché par défaut

  double responsiveWidth(double p) => SizeConfig.screenWidth * p;
  double responsiveHeight(double p) => SizeConfig.screenHeight * p;

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(() {
      if ((_formKey.currentState?.mounted ?? false)) {
        _formKey.currentState!.validate();
      }
    });
  }

  @override
  void dispose() {
    _firstnameCtrl.dispose();
    _lastnameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok || !_acceptTerms) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez accepter les conditions.")),
        );
      }
      return;
    }

    setState(() => _loading = true);
    try {
      // TODO: Appeler ton backend / Firebase ici
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      await _showSuccessAndGoHome(); // <-- pop-up + navigation vers MainScreen
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Échec de l'inscription.")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Pop-up de succès stylé, puis navigation vers MainScreen
  Future<void> _showSuccessAndGoHome() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Check dans un cercle
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.k_primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 40,
                    color: AppColors.k_primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Compte créé !",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Votre compte a été créé avec succès.\nBienvenue sur Perantal.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop(); // fermer le pop-up
                      // Aller sur MainScreen et nettoyer la pile
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => MainScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text("Aller au tableau de bord"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.k_primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==== POP-UP CGU (Bottom Sheet) ====
  Future<void> _showLegalPopup() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final h = MediaQuery.of(ctx).size.height;
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollCtrl) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: const [
                      Icon(Icons.policy_outlined, color: AppColors.k_primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Conditions d’utilisation & Politique de confidentialité",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: Scrollbar(
                    controller: scrollCtrl,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: scrollCtrl,
                      primary: false,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: h * 0.5),
                        child: _legalContent(),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.k_primary),
                          ),
                          child: const Text(
                            "Fermer",
                            style: TextStyle(color: AppColors.k_primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _acceptTerms = true);
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.k_primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("J’ai lu et j’accepte"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _legalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "1. Objet du service",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        SizedBox(height: 6),
        Text(
          "Perantal permet l’inscription, la gestion de compte et l’accès à des fonctionnalités "
          "de suivi et d’analyse. Les données fournies doivent être exactes et à jour.",
        ),
        SizedBox(height: 14),
        Text(
          "2. Données personnelles & confidentialité",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        SizedBox(height: 6),
        Text(
          "Nous collectons des informations d’identification (nom, email, téléphone) et des données "
          "d’usage afin d’améliorer le service. Vos données ne sont ni vendues ni partagées à des tiers "
          "sans base légale ou votre consentement explicite, sauf obligations légales.",
        ),
        SizedBox(height: 8),
        Text(
          "Vous disposez de droits d’accès, de rectification et de suppression de vos données. "
          "Pour exercer ces droits, contactez le support via la rubrique Aide/Support.",
        ),
        SizedBox(height: 14),
        Text(
          "3. Sécurité",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        SizedBox(height: 6),
        Text(
          "Nous mettons en œuvre des mesures techniques et organisationnelles pour protéger vos données. "
          "Vous êtes responsable de la confidentialité de votre mot de passe et de l’activité de votre compte.",
        ),
        SizedBox(height: 14),
        Text(
          "4. Usage acceptable",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        SizedBox(height: 6),
        Text(
          "Il est interdit d’utiliser l’application pour des activités illicites, de tenter d’accéder "
          "sans autorisation à des systèmes, ou d’entraver le bon fonctionnement des services.",
        ),
        SizedBox(height: 14),
        Text(
          "5. Limitation de responsabilité",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        SizedBox(height: 6),
        Text(
          "Le service est fourni “en l’état”. Nous ne garantissons pas l’absence d’erreurs ni "
          "l’exhaustivité des informations. En cas d’interruption ou de perte de données, notre "
          "responsabilité ne saurait être engagée au-delà des limites prévues par la loi.",
        ),
        SizedBox(height: 14),
        Text(
          "6. Conservation & suppression",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        SizedBox(height: 6),
        Text(
          "Les données sont conservées pendant la durée nécessaire à la fourniture du service et "
          "pour respecter les obligations légales. Vous pouvez demander la suppression de votre compte.",
        ),
        SizedBox(height: 14),
        Text(
          "7. Modifications",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        SizedBox(height: 6),
        Text(
          "Les présentes conditions peuvent évoluer. Vous serez informé(e) en cas de changements "
          "importants. La poursuite d’utilisation vaut acceptation des nouvelles conditions.",
        ),
        SizedBox(height: 14),
        Text(
          "8. Contact",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        SizedBox(height: 6),
        Text(
          "Pour toute question relative à la confidentialité ou aux conditions, veuillez nous contacter "
          "via la section Aide/Support de l’application.",
        ),
        SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppColors.k_background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 50),
                  SizedBox(
                    height: responsiveHeight(0.1),
                    width: 250,
                    child: Image.asset("assets/img/logo.jpg"),
                  ),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            "Inscription",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.k_primary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Nom
                          TextFormField(
                            controller: _firstnameCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: _decoration(
                              "Nom",
                              Icons.person_outline,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? "Champ requis"
                                : null,
                          ),
                          const SizedBox(height: 12),

                          // Prénom
                          TextFormField(
                            controller: _lastnameCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: _decoration(
                              "Prénom",
                              Icons.person_outline,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? "Champ requis"
                                : null,
                          ),
                          const SizedBox(height: 12),

                          // Email
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'\s')),
                            ],
                            decoration: _decoration(
                              "Email",
                              Icons.email_outlined,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return "Champ requis";
                              final email = v.trim();
                              final ok = RegExp(
                                r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$",
                              ).hasMatch(email);
                              return ok ? null : "Email invalide";
                            },
                          ),
                          const SizedBox(height: 12),

                          // Téléphone
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(15),
                            ],
                            decoration: _decoration(
                              "Téléphone",
                              Icons.phone_outlined,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Champ requis";
                              final d = v;
                              if (d.length < 8 || d.length > 15)
                                return "Numéro invalide (8–15 chiffres)";
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Mot de passe
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePw,
                            textInputAction: TextInputAction.next,
                            decoration:
                                _decoration(
                                  "Mot de passe",
                                  Icons.lock_outline,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePw
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () => setState(
                                      () => _obscurePw = !_obscurePw,
                                    ),
                                  ),
                                ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Champ requis";
                              if (v.length < 6) return "Au moins 6 caractères";
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Confirmation
                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: _obscurePw2,
                            textInputAction: TextInputAction.done,
                            decoration:
                                _decoration(
                                  "Confirmer le mot de passe",
                                  Icons.lock_outline,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePw2
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () => setState(
                                      () => _obscurePw2 = !_obscurePw2,
                                    ),
                                  ),
                                ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Champ requis";
                              if (v != _passwordCtrl.text)
                                return "Les mots de passe ne correspondent pas";
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),

                          // Conditions
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _acceptTerms,
                                onChanged: (_) => _showLegalPopup(),
                                fillColor:
                                    MaterialStateProperty.resolveWith<Color>((
                                      states,
                                    ) {
                                      if (states.contains(
                                        MaterialState.selected,
                                      ))
                                        return AppColors.k_primary;
                                      return Colors.grey.shade400;
                                    }),
                                checkColor: Colors.white,
                                side: BorderSide(
                                  color: _acceptTerms
                                      ? AppColors.k_primary
                                      : Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: InkWell(
                                  onTap: _showLegalPopup,
                                  child: Text(
                                    "J’accepte les conditions d’utilisation et la politique de confidentialité.",
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: _acceptTerms
                                          ? Colors.black
                                          : AppColors.k_primary,
                                      decoration: _acceptTerms
                                          ? TextDecoration.none
                                          : TextDecoration.underline,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CTA
                  SizedBox(
                    width: 250,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.k_primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "CRÉER MON COMPTE",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Lien Connexion
                  SizedBox(
                    width: 250,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          width: 1,
                          color: AppColors.k_primary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "DÉJÀ UN COMPTE ? CONNEXION",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.k_primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: AppColors.k_primary),
      ),
    );
  }
}
