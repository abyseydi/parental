import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perantal/utils/colors.dart';
import 'package:perantal/widgets/bottom_nav_bar.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final bool goHomeOnSuccess;
  final VoidCallback? onVerified;
  const OtpScreen({
    super.key,
    required this.phone,
    this.goHomeOnSuccess = true,
    this.onVerified,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final int _codeLength = 6;
  final List<TextEditingController> _ctrs = [];
  final List<FocusNode> _nodes = [];
  bool _verifying = false;

  int _seconds = 60;
  Timer? _timer;
  bool get _canResend => _seconds == 0;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _codeLength; i++) {
      _ctrs.add(TextEditingController());
      _nodes.add(FocusNode());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _nodes.first.requestFocus();
    });
    _startTimer();
  }

  @override
  void dispose() {
    for (final c in _ctrs) c.dispose();
    for (final n in _nodes) n.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          t.cancel();
        }
      });
    });
  }

  String _collectCode() => _ctrs.map((c) => c.text).join();

  Future<void> _verify() async {
    final code = _collectCode();
    if (code.length != _codeLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez saisir le code à 6 chiffres.")),
      );
      return;
    }
    setState(() => _verifying = true);
    try {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  "Code vérifié",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  "Le numéro ${ /* masquons un peu */ widget.phone.replaceAll(RegExp(r'.(?=.{2})'), '•')} est confirmé.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      if (widget.onVerified != null) {
                        widget.onVerified!();
                      } else if (widget.goHomeOnSuccess) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => MainScreen()),
                          (route) => false,
                        );
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.k_primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Continuer"),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Nouveau code envoyé à ${widget.phone}.")),
    );
    _startTimer();
  }

  void _handlePaste(String value) {
    final paste = value.replaceAll(RegExp(r'\D'), '');
    if (paste.isEmpty) return;
    for (int i = 0; i < _codeLength; i++) {
      _ctrs[i].text = i < paste.length ? paste[i] : '';
    }
    final filled = paste.length >= _codeLength;
    if (filled) {
      _nodes[_codeLength - 1].requestFocus();
    } else {
      _nodes[paste.length.clamp(0, _codeLength - 1)].requestFocus();
    }
    setState(() {});
  }

  Widget _buildBox(int i) {
    return SizedBox(
      width: 46,
      child: TextField(
        controller: _ctrs[i],
        focusNode: _nodes[i],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.k_primary),
          ),
        ),
        onChanged: (v) {
          if (v.isNotEmpty) {
            if (i < _codeLength - 1) {
              _nodes[i + 1].requestFocus();
            } else {
              _nodes[i].unfocus();
            }
          } else {
            if (i > 0) _nodes[i - 1].requestFocus();
          }
          setState(() {});
        },
        onSubmitted: (_) {
          if (i == _codeLength - 1) _verify();
        },
        enableInteractiveSelection: true,
        onTap: () async {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filled = _collectCode().length == _codeLength;

    return Scaffold(
      backgroundColor: AppColors.k_background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Vérification",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.k_primary.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sms_rounded,
                    size: 48,
                    color: AppColors.k_primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Entrez le code envoyé à",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.phone,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_codeLength, _buildBox),
                ),
                const SizedBox(height: 16),

                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onLongPress: () async {
                    final data = await Clipboard.getData('text/plain');
                    if (data?.text != null) _handlePaste(data!.text!);
                  },
                  child: const Text(
                    "Appui long pour coller le code",
                    style: TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_canResend)
                      Text(
                        "Renvoyer dans 00:${_seconds.toString().padLeft(2, '0')}",
                        style: const TextStyle(color: Colors.black54),
                      )
                    else
                      TextButton(
                        onPressed: _resend,
                        child: const Text("Renvoyer le code"),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: 260,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _verifying ? null : _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: filled
                          ? AppColors.k_primary
                          : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _verifying
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("VÉRIFIER"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
