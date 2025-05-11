import 'package:flutter/material.dart';
import '../models/promo_code.dart';
import '../services/loyalty_service.dart';

class PromoCodeInput extends StatefulWidget {
  final double orderAmount;
  final Function(PromoCode?) onPromoCodeApplied;
  final Function(String) onError;

  const PromoCodeInput({
    Key? key,
    required this.orderAmount,
    required this.onPromoCodeApplied,
    required this.onError,
  }) : super(key: key);

  @override
  _PromoCodeInputState createState() => _PromoCodeInputState();
}

class _PromoCodeInputState extends State<PromoCodeInput> {
  final _promoCodeController = TextEditingController();
  final _loyaltyService = LoyaltyService();
  bool _isLoading = false;
  PromoCode? _appliedPromoCode;

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  Future<void> _applyPromoCode() async {
    final code = _promoCodeController.text.trim();
    if (code.isEmpty) {
      widget.onError('Введите промокод');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final promoCode = await _loyaltyService.validateAndApplyPromoCode(
        code,
        widget.orderAmount,
      );

      setState(() {
        _appliedPromoCode = promoCode;
        _isLoading = false;
      });

      widget.onPromoCodeApplied(promoCode);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      widget.onError(e.toString());
    }
  }

  void _removePromoCode() {
    setState(() {
      _appliedPromoCode = null;
      _promoCodeController.clear();
    });
    widget.onPromoCodeApplied(null);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Промокод',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_appliedPromoCode == null)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promoCodeController,
                      decoration: const InputDecoration(
                        hintText: 'Введите промокод',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : ElevatedButton(
                          onPressed: _applyPromoCode,
                          child: const Text('Применить'),
                        ),
                ],
              )
            else
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _appliedPromoCode!.code,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _appliedPromoCode!.discountText,
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _removePromoCode,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 