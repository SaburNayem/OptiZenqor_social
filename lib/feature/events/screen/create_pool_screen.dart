import 'package:flutter/material.dart';

import '../../../core/navigation/app_get.dart';
import '../../../core/constants/app_colors.dart';

class CreatePoolScreen extends StatefulWidget {
  const CreatePoolScreen({super.key});

  @override
  State<CreatePoolScreen> createState() => _CreatePoolScreenState();
}

class _CreatePoolScreenState extends State<CreatePoolScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();
  final TextEditingController _benefitController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _limitController.dispose();
    _benefitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hexFFF9FCFD,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black87),
          onPressed: () => AppGet.back(),
        ),
        title: const Text(
          'Create Pool',
          style: TextStyle(
            color: AppColors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pool setup',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Create a ticket pool, supporter tier, or group package for this event.',
                    style: TextStyle(color: AppColors.grey600),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _nameController,
                    label: 'Pool name',
                    icon: Icons.group_outlined,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          controller: _amountController,
                          label: 'Amount',
                          icon: Icons.attach_money,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          controller: _limitController,
                          label: 'Limit',
                          icon: Icons.confirmation_num_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    controller: _benefitController,
                    label: 'Perks or benefit',
                    icon: Icons.workspace_premium_outlined,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.hexFFEFFBFD,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.hexFFB2EBF2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Examples',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 10),
                  _PoolExampleRow(
                    title: 'Early bird',
                    detail: '\$30 • 50 spots • first-release pricing',
                  ),
                  SizedBox(height: 8),
                  _PoolExampleRow(
                    title: 'VIP circle',
                    detail: '\$250 • 8 spots • lounge access + merch',
                  ),
                  SizedBox(height: 8),
                  _PoolExampleRow(
                    title: 'Group pack',
                    detail: '\$120 • 10 packs • four-person entry',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.hexFF26C6DA,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text('Save pool'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.hexFF26C6DA),
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: AppColors.hexFFF9FCFD,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    final amount = _amountController.text.trim();
    final limit = _limitController.text.trim();
    final benefit = _benefitController.text.trim();

    if (name.isEmpty || amount.isEmpty || limit.isEmpty) {
      AppGet.snackbar(
        'Pool incomplete',
        'Add pool name, amount, and limit before saving.',
      );
      return;
    }

    AppGet.back(
      result: <String, String>{
        'name': name,
        'amount': amount,
        'limit': limit,
        'benefit': benefit,
      },
    );
  }
}

class _PoolExampleRow extends StatelessWidget {
  const _PoolExampleRow({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.hexFF00ACC1,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(
                context,
              ).style.copyWith(color: AppColors.grey700),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.black87,
                  ),
                ),
                TextSpan(text: detail),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
