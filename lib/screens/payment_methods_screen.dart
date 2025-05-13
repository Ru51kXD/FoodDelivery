import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import 'package:uuid/uuid.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;
  PaymentMethod? _editingMethod;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  // Safety method to prevent infinite loading
  void _startLoadingSafetyTimer() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isLoading) {
        print("Safety timer triggered - resetting loading state");
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Превышено время ожидания. Пожалуйста, попробуйте снова.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  void _showAddPaymentMethodDialog() {
    // Reset controllers
    _cardNumberController.clear();
    _cardHolderController.clear();
    _expiryController.clear();
    _cvvController.clear();
    _isDefault = false;
    _editingMethod = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        // Create a StatefulBuilder to manage state changes within the modal
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return _buildPaymentMethodForm(setModalState);
          }
        );
      },
    );
  }

  Widget _buildPaymentMethodForm([StateSetter? modalSetState]) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Добавить карту',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _cardNumberController,
                  decoration: InputDecoration(
                    labelText: 'Номер карты',
                    hintText: 'XXXX XXXX XXXX XXXX',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.credit_card),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите номер карты';
                    }
                    // Simple validation - real app would need more robust validation
                    if (value.replaceAll(' ', '').length < 16) {
                      return 'Введите корректный номер карты';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _cardHolderController,
                  decoration: InputDecoration(
                    labelText: 'Имя владельца',
                    hintText: 'IVAN IVANOV',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите имя владельца';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryController,
                        decoration: InputDecoration(
                          labelText: 'Срок действия',
                          hintText: 'MM/YY',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите срок';
                          }
                          // Simple MM/YY validation
                          if (!RegExp(r'^\d\d/\d\d$').hasMatch(value)) {
                            return 'Формат MM/YY';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          hintText: 'XXX',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.security),
                        ),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите CVV';
                          }
                          if (value.length < 3) {
                            return 'Минимум 3 цифры';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                CheckboxListTile(
                  title: const Text('Установить по умолчанию'),
                  value: _isDefault,
                  activeColor: Colors.deepOrange,
                  onChanged: (value) {
                    // Update both the screen state and modal state if provided
                    setState(() {
                      _isDefault = value ?? false;
                    });
                    if (modalSetState != null) {
                      modalSetState(() {
                        _isDefault = value ?? false;
                      });
                    }
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: false,
                  checkColor: Colors.white,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading 
                        ? null 
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              
                              // Start safety timer
                              _startLoadingSafetyTimer();
                              
                              try {
                                // Direct approach to adding a payment method
                                final userProvider = Provider.of<UserProvider>(context, listen: false);
                                final user = userProvider.user;
                                
                                if (user == null) {
                                  throw Exception('Пользователь не найден');
                                }
                                
                                // Extract card info
                                final cardNumber = _cardNumberController.text.replaceAll(' ', '');
                                final last4 = cardNumber.substring(cardNumber.length - 4);
                                final expiryParts = _expiryController.text.split('/');
                                
                                // Determine card brand
                                String cardBrand = 'Unknown';
                                if (cardNumber.startsWith('4')) {
                                  cardBrand = 'Visa';
                                } else if (cardNumber.startsWith('5')) {
                                  cardBrand = 'MasterCard';
                                } else if (cardNumber.startsWith('3')) {
                                  cardBrand = 'American Express';
                                }
                                
                                // Create new payment method
                                final newMethod = PaymentMethod(
                                  id: const Uuid().v4(),
                                  type: PaymentType.card,
                                  title: '$cardBrand •••• $last4',
                                  isDefault: _isDefault,
                                  cardBrand: cardBrand,
                                  last4: last4,
                                  expiryMonth: expiryParts[0],
                                  expiryYear: expiryParts[1],
                                  cardholderName: _cardHolderController.text.trim(),
                                );
                                
                                // Use the new direct method to add payment method
                                await userProvider.directAddPaymentMethod(newMethod);
                                
                                // Exit the bottom sheet
                                Navigator.pop(context);
                                
                                // Force a UI refresh
                                setState(() {
                                  _isLoading = false;
                                });
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Карта успешно добавлена'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                print('Error adding card: $e');
                                setState(() {
                                  _isLoading = false;
                                });
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Ошибка: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _isLoading ? 'Сохранение...' : 'Добавить карту',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Способы оплаты',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading 
        ? Center(
            child: CircularProgressIndicator(
              color: Colors.deepOrange,
            ),
          )
        : Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final user = userProvider.user;
            final paymentMethods = user?.paymentMethods ?? [];
            
            return Column(
              children: [
                Expanded(
                  child: paymentMethods.isEmpty
                      ? Center(
                          child: Text(
                            'У вас пока нет сохраненных способов оплаты',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: paymentMethods.length,
                          itemBuilder: (context, index) {
                            final method = paymentMethods[index];
                            return _buildPaymentMethodCard(method);
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showAddPaymentMethodDialog,
                          icon: const Icon(Icons.add),
                          label: Text(
                            'Добавить карту',
                            style: GoogleFonts.poppins(),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Add cash payment method
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Добавить наличные'),
                                content: const Text('Добавить оплату наличными как способ оплаты?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Отмена'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      try {
                                        setState(() {
                                          _isLoading = true; // Show loading state
                                        });
                                        
                                        // Start safety timer
                                        _startLoadingSafetyTimer();
                                        
                                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                                        
                                        final cashMethod = PaymentMethod(
                                          id: const Uuid().v4(),
                                          type: PaymentType.cash,
                                          title: 'Наличные',
                                          isDefault: userProvider.user?.paymentMethods.isEmpty ?? true,
                                        );
                                        
                                        // Use the direct method for adding payment method
                                        await userProvider.directAddPaymentMethod(cashMethod);
                                        
                                        if (mounted) {
                                          setState(() {
                                            _isLoading = false; // Hide loading state
                                          });
                                          
                                          // Delay to ensure database operation completes
                                          Future.delayed(Duration(milliseconds: 300), () {
                                            if (mounted) {
                                              // Refresh the screen state again after a delay
                                              setState(() {});
                                            }
                                          });
                                          
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Способ оплаты добавлен'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          setState(() {
                                            _isLoading = false; // Hide loading state
                                          });
                                          
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Ошибка: ${e.toString()}'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text('Добавить'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.payments),
                          label: Text(
                            'Добавить наличные',
                            style: GoogleFonts.poppins(),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.deepOrange,
                            side: const BorderSide(color: Colors.deepOrange),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    // Determine the icon based on payment type
    IconData methodIcon;
    if (method.type == PaymentType.card) {
      if (method.cardBrand == 'Visa') {
        methodIcon = Icons.credit_card;
      } else if (method.cardBrand == 'MasterCard') {
        methodIcon = Icons.credit_card;
      } else {
        methodIcon = Icons.credit_card;
      }
    } else if (method.type == PaymentType.cash) {
      methodIcon = Icons.payments;
    } else {
      methodIcon = Icons.payment;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  methodIcon,
                  color: Colors.deepOrange,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (method.type == PaymentType.card && method.expiryMonth != null && method.expiryYear != null)
                        Text(
                          'Действует до: ${method.expiryMonth}/${method.expiryYear}',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                if (method.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'По умолчанию',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!method.isDefault)
                  TextButton.icon(
                    onPressed: () async {
                      try {
                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                        await userProvider.setDefaultPaymentMethod(method.id);
                        
                        if (mounted) {
                          // Update UI after setting default payment method
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Установлен способ оплаты по умолчанию'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Ошибка: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('По умолчанию'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Удалить способ оплаты?'),
                        content: const Text('Вы уверены, что хотите удалить этот способ оплаты?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Отмена'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Удалить'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirm == true) {
                      try {
                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                        await userProvider.removePaymentMethod(method.id);
                        
                        if (mounted) {
                          // Force UI refresh after removing payment method
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Способ оплаты удален'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Ошибка: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 