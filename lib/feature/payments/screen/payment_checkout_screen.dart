import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/payment_checkout_model.dart';
import '../repository/payment_repository.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  const PaymentCheckoutScreen({super.key, this.arguments});

  final Object? arguments;

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  final PaymentRepository _repository = PaymentRepository();
  bool _isLoading = false;
  String? _errorMessage;
  PaymentCheckoutModel? _checkout;

  @override
  void initState() {
    super.initState();
    final args = widget.arguments;
    if (args is Map) {
      _startPayment(args);
    }
  }

  Future<void> _startPayment(Map<dynamic, dynamic> args) async {
    if (_isLoading) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final checkout = await _repository.createPayment(
        itemType: args['itemType']?.toString() ?? 'premium_plan',
        itemId: args['itemId']?.toString(),
        title: args['title']?.toString() ?? 'Premium plan',
        description: args['description']?.toString(),
        amount:
            (num.tryParse(args['amount']?.toString() ?? '') ?? 0).toDouble(),
        currency: args['currency']?.toString() ?? 'BDT',
        region: args['region']?.toString() ?? 'local',
        customerName: args['customerName']?.toString() ?? '',
        customerEmail: args['customerEmail']?.toString() ?? '',
        customerPhone: args['customerPhone']?.toString() ?? '',
        city: args['city']?.toString(),
        country: args['country']?.toString(),
        metadata: args['metadata'] is Map<String, dynamic>
            ? args['metadata'] as Map<String, dynamic>
            : null,
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _checkout = checkout;
      });

      final Uri uri = Uri.parse(checkout.checkoutUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw StateError('Unable to open checkout.');
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshStatus() async {
    final checkout = _checkout;
    if (checkout == null) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final status = await _repository.getStatus(checkout.paymentId);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment status: ${status['status']}')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkout = _checkout;
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            checkout == null ? 'Preparing checkout' : 'Checkout opened',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            checkout == null
                ? 'The app will open the secure gateway checkout after the backend creates the payment.'
                : 'Return here after payment and refresh the status.',
          ),
          if (checkout != null) ...[
            const SizedBox(height: 16),
            Text('Payment ID: ${checkout.paymentId}'),
            Text('Gateway: ${checkout.gateway}'),
            Text('Amount: ${checkout.amount.toStringAsFixed(2)} ${checkout.currency}'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isLoading ? null : _refreshStatus,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh status'),
            ),
            TextButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => launchUrl(
                        Uri.parse(checkout.checkoutUrl),
                        mode: LaunchMode.externalApplication,
                      ),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Open checkout again'),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}
