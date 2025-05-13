import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import 'package:uuid/uuid.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _houseController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _entranceController = TextEditingController();
  final _floorController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;
  Address? _editingAddress;

  @override
  void dispose() {
    _streetController.dispose();
    _houseController.dispose();
    _apartmentController.dispose();
    _entranceController.dispose();
    _floorController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showAddAddressDialog() {
    // Reset controllers
    _streetController.clear();
    _houseController.clear();
    _apartmentController.clear();
    _entranceController.clear();
    _floorController.clear();
    _noteController.clear();
    _isDefault = false;
    _editingAddress = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        // Create a StatefulBuilder to manage state changes within the modal
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return _buildAddressForm(setModalState);
          }
        );
      },
    );
  }

  void _showEditAddressDialog(Address address) {
    _streetController.text = address.street;
    _houseController.text = address.house;
    _apartmentController.text = address.apartment ?? '';
    _entranceController.text = address.entrance ?? '';
    _floorController.text = address.floor != null ? address.floor.toString() : '';
    _noteController.text = address.note ?? '';
    _isDefault = address.isDefault;
    _editingAddress = address;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        // Create a StatefulBuilder to manage state changes within the modal
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return _buildAddressForm(setModalState);
          }
        );
      },
    );
  }

  Widget _buildAddressForm([StateSetter? modalSetState]) {
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
                  _editingAddress != null ? 'Редактировать адрес' : 'Добавить адрес',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _streetController,
                  decoration: InputDecoration(
                    labelText: 'Улица',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите улицу';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _houseController,
                        decoration: InputDecoration(
                          labelText: 'Дом',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите номер дома';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _apartmentController,
                        decoration: InputDecoration(
                          labelText: 'Квартира',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _entranceController,
                        decoration: InputDecoration(
                          labelText: 'Подъезд',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _floorController,
                        decoration: InputDecoration(
                          labelText: 'Этаж',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Комментарий для курьера',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 15),
                CheckboxListTile(
                  title: const Text('Сделать адресом по умолчанию'),
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
                              
                              try {
                                final userProvider = Provider.of<UserProvider>(context, listen: false);
                                
                                final newAddress = Address(
                                  id: _editingAddress?.id ?? const Uuid().v4(),
                                  street: _streetController.text.trim(),
                                  house: _houseController.text.trim(),
                                  apartment: _apartmentController.text.isEmpty 
                                      ? null 
                                      : _apartmentController.text.trim(),
                                  entrance: _entranceController.text.isEmpty 
                                      ? null 
                                      : _entranceController.text.trim(),
                                  floor: _floorController.text.isEmpty 
                                      ? null 
                                      : int.tryParse(_floorController.text.trim()),
                                  note: _noteController.text.isEmpty 
                                      ? null 
                                      : _noteController.text.trim(),
                                  isDefault: _isDefault,
                                );
                                
                                if (_editingAddress != null) {
                                  // Обновляем существующий адрес
                                  await userProvider.updateAddress(newAddress);
                                } else {
                                  // Добавляем новый адрес используя прямой метод
                                  await userProvider.directAddAddress(newAddress);
                                }
                                
                                if (mounted) {
                                  Navigator.pop(context);
                                  // Force a rebuild of the entire screen to reflect changes
                                  setState(() {});
                                  
                                  // Установка таймера для автоматического выхода из состояния загрузки
                                  Future.delayed(const Duration(seconds: 1), () {
                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  });
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        _editingAddress != null 
                                            ? 'Адрес обновлен' 
                                            : 'Адрес добавлен'
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
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
                      _isLoading 
                          ? 'Сохранение...' 
                          : (_editingAddress != null ? 'Обновить' : 'Добавить'),
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
          'Адреса доставки',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          final addresses = user?.addresses ?? [];
          
          return Column(
            children: [
              Expanded(
                child: addresses.isEmpty
                    ? Center(
                        child: Text(
                          'У вас пока нет сохраненных адресов',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          final address = addresses[index];
                          return _buildAddressCard(address);
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _showAddAddressDialog,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          ) 
                        : const Icon(Icons.add),
                    label: Text(
                      _isLoading ? 'Загрузка...' : 'Добавить новый адрес',
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
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddressCard(Address address) {
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
                const Icon(
                  Icons.location_on,
                  color: Colors.deepOrange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${address.street}, ${address.house}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (address.isDefault)
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
            const SizedBox(height: 8),
            if (address.apartment != null || address.entrance != null || address.floor != null)
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  [
                    if (address.apartment != null) 'Кв. ${address.apartment}',
                    if (address.entrance != null) 'Подъезд ${address.entrance}',
                    if (address.floor != null) 'Этаж ${address.floor}',
                  ].join(', '),
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            if (address.note != null && address.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 4),
                child: Text(
                  'Примечание: ${address.note}',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!address.isDefault)
                  TextButton.icon(
                    onPressed: () async {
                      try {
                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                        await userProvider.setDefaultAddress(address.id);
                        
                        if (mounted) {
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Адрес установлен по умолчанию'),
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
                  onPressed: () => _showEditAddressDialog(address),
                  icon: const Icon(Icons.edit),
                  color: Colors.blue,
                ),
                IconButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Удалить адрес?'),
                        content: const Text('Вы уверены, что хотите удалить этот адрес?'),
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
                        await userProvider.removeAddress(address.id);
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Адрес удален'),
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