import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../models/order.dart' hide PaymentMethod;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Заполняем поля данными пользователя
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user != null) {
        _nameController.text = userProvider.user!.name;
        _emailController.text = userProvider.user!.email;
        _phoneController.text = userProvider.user!.phoneNumber;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      try {
        await userProvider.updateUserInfo(
          name: _nameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Профиль успешно обновлен',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          _toggleEditMode();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Ошибка при обновлении профиля: $e',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text(
          'Профиль',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit, 
              color: Colors.deepOrange,
            ),
            onPressed: _isEditing ? _saveProfile : _toggleEditMode,
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
              ),
            );
          }

          final user = userProvider.user;
          if (user == null) {
            return _buildNotLoggedInView();
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: _isEditing ? _buildEditForm(user) : _buildProfileInfo(user),
          );
        },
      ),
    );
  }
  
  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.deepOrange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              size: 80,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Вы не авторизованы',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Войдите в аккаунт, чтобы увидеть профиль',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Здесь будет логика для входа
              // Вместо createDefaultUser используем login
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              userProvider.login(email: 'demo@example.com', password: 'password123');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Войти',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(User user) {
    return Column(
      children: [
        // Верхняя карточка с аватаром и основной информацией
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              // Аватар пользователя
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.deepOrange.withOpacity(0.2),
                    width: 4,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          user.name.substring(0, 1).toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              
              // Имя пользователя
              Text(
                user.name,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Инфо о пользователе
              _buildInfoItem(Icons.email, user.email),
              const SizedBox(height: 8),
              _buildInfoItem(Icons.phone, user.phoneNumber),
            ],
          ),
        ),
        
        // Адреса доставки
        _buildSectionCard(
          title: 'Адреса доставки',
          icon: Icons.location_on,
          content: user.addresses.isEmpty
              ? _buildEmptyStateMessage('У вас нет сохраненных адресов')
              : Column(
                  children: user.addresses.map((address) => 
                    _buildAddressItem(address)
                  ).toList(),
                ),
          actionButton: TextButton.icon(
            icon: const Icon(Icons.add, color: Colors.deepOrange),
            label: Text(
              'Добавить адрес',
              style: GoogleFonts.poppins(
                color: Colors.deepOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () {
              // Логика добавления адреса
            },
          ),
        ),
        
        // Способы оплаты
        _buildSectionCard(
          title: 'Способы оплаты',
          icon: Icons.payment,
          content: user.paymentMethods.isEmpty
              ? _buildEmptyStateMessage('У вас нет сохраненных способов оплаты')
              : Column(
                  children: user.paymentMethods.map((method) => 
                    _buildPaymentMethodItem(method)
                  ).toList(),
                ),
          actionButton: TextButton.icon(
            icon: const Icon(Icons.add, color: Colors.deepOrange),
            label: Text(
              'Добавить способ оплаты',
              style: GoogleFonts.poppins(
                color: Colors.deepOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () {
              // Логика добавления способа оплаты
            },
          ),
        ),
        
        // История заказов
        _buildSectionCard(
          title: 'История заказов',
          icon: Icons.receipt_long,
          content: user.orders.isEmpty
              ? _buildEmptyStateMessage('У вас нет истории заказов')
              : Column(
                  children: user.orders.map((order) => 
                    _buildOrderItem(order)
                  ).toList(),
                ),
          actionButton: null,
        ),
        
        // Кнопка выхода
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: Text(
              'Выйти из аккаунта',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () {
              // Логика выхода из аккаунта
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              userProvider.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget content,
    Widget? actionButton,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.deepOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          content,
          if (actionButton != null) const SizedBox(height: 8),
          if (actionButton != null) actionButton,
        ],
      ),
    );
  }
  
  Widget _buildEmptyStateMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: GoogleFonts.poppins(
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  Widget _buildAddressItem(Address address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: address.isDefault ? Colors.deepOrange.withOpacity(0.3) : Colors.grey.shade200,
          width: address.isDefault ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.home,
            color: address.isDefault ? Colors.deepOrange : Colors.grey[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      address.title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (address.isDefault)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'По умолчанию',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  address.fullAddress,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            color: Colors.grey[400],
            onPressed: () {
              // Логика редактирования адреса
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentMethodItem(PaymentMethod method) {
    // Определяем иконку в зависимости от типа платежа
    IconData icon;
    switch (method.type) {
      case PaymentType.card:
        icon = Icons.credit_card;
        break;
      case PaymentType.applepay:
        icon = Icons.apple;
        break;
      case PaymentType.googlepay:
        icon = Icons.g_mobiledata;
        break;
      case PaymentType.cash:
      default:
        icon = Icons.money;
        break;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: method.isDefault ? Colors.deepOrange.withOpacity(0.3) : Colors.grey.shade200,
          width: method.isDefault ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: method.isDefault ? Colors.deepOrange : Colors.grey[700],
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      method.title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (method.isDefault)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'По умолчанию',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                if (method.type == PaymentType.card)
                  Text(
                    '•••• •••• •••• ${method.last4}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            color: Colors.grey[400],
            onPressed: () {
              // Показываем опции для карты
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderItem(Order order) {
    // Определяем цвет статуса
    Color statusColor;
    switch (order.status) {
      case OrderStatus.delivered:
        statusColor = Colors.green;
        break;
      case OrderStatus.delivering:
        statusColor = Colors.blue;
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        break;
      case OrderStatus.pending:
      default:
        statusColor = Colors.orange;
        break;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Переход к деталям заказа
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Заказ #${order.id}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order.statusText,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Дата: ${order.createdAt.toString().substring(0, 10)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Сумма: ${order.totalAmount.toStringAsFixed(0)} ₽',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditForm(User user) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.deepOrange.withOpacity(0.2),
                        width: 4,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? Text(
                              user.name.substring(0, 1).toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Поля формы
            Text(
              'Имя',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Введите ваше имя',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите имя';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            Text(
              'Email',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Введите ваш email',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите email';
                }
                if (!value.contains('@')) {
                  return 'Введите корректный email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            Text(
              'Номер телефона',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Введите номер телефона',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите номер телефона';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            
            // Кнопки
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _toggleEditMode,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Colors.deepOrange),
                    ),
                    child: Text(
                      'Отмена',
                      style: GoogleFonts.poppins(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Сохранить',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 