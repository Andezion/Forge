import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/theme_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AiConfigScreen extends StatefulWidget {
  const AiConfigScreen({super.key});

  @override
  State<AiConfigScreen> createState() => _AiConfigScreenState();
}

class _AiConfigScreenState extends State<AiConfigScreen> {
  late final TextEditingController _keyController;
  bool _obscure = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing =
        Provider.of<SettingsService>(context, listen: false).groqApiKey ?? '';
    _keyController = TextEditingController(text: existing);
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final settings = Provider.of<SettingsService>(context, listen: false);
    await settings.setGroqApiKey(_keyController.text.trim());
    setState(() => _isSaving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API key saved')),
    );
  }

  Future<void> _remove() async {
    _keyController.clear();
    final settings = Provider.of<SettingsService>(context, listen: false);
    await settings.setGroqApiKey(null);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API key removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColor = Provider.of<AppColor>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColor.color,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          'AI Config',
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(appColor.color),
            const SizedBox(height: 24),
            Text('Your Groq API Key', style: AppTextStyles.h4),
            const SizedBox(height: 8),
            TextField(
              controller: _keyController,
              obscureText: _obscure,
              style: AppTextStyles.body1,
              decoration: InputDecoration(
                hintText: 'gsk_...',
                hintStyle:
                    AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: appColor.color, width: 2),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _keyController.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColor.color,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Save', style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _remove,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Remove'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildStatusTile(appColor.color),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Color accent) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: accent),
                const SizedBox(width: 8),
                Text('How to get a free API key', style: AppTextStyles.h4),
              ],
            ),
            const SizedBox(height: 12),
            _step(
              '1',
              'Go to console.groq.com and sign up (it\'s free)',
              accent,
            ),
            _step('2', 'Open "API Keys" in the left menu', accent),
            _step('3', 'Click "Create API Key", give it a name', accent),
            _step('4', 'Copy the key and paste it here', accent),
            const SizedBox(height: 8),
            Text(
              'The free tier is generous — plenty for personal use.',
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _step(String num, String text, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: accent,
            child: Text(
              num,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.body2)),
        ],
      ),
    );
  }

  Widget _buildStatusTile(Color accent) {
    final key = Provider.of<SettingsService>(context).groqApiKey;
    final hasKey = key != null && key.isNotEmpty;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          hasKey ? Icons.check_circle : Icons.cancel,
          color: hasKey ? Colors.green : AppColors.error,
        ),
        title: Text(
          hasKey ? 'API key is configured' : 'No API key set',
          style: AppTextStyles.body1,
        ),
        subtitle: hasKey
            ? Text(
                '${key.substring(0, key.length.clamp(0, 8))}••••••••',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              )
            : Text(
                'AI features will not work without a key',
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
      ),
    );
  }
}
