import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/user_provider.dart';
import 'home_screen.dart';
import 'auth/register_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  String _statusMessage = "Инициализация...";
  bool _hasError = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    
    // Настройка анимации
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
    
    // Инициализация данных и переход на главный экран
    _initializeAppData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeAppData() async {
    try {
      // Получаем провайдеры
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Инициализируем данные последовательно для лучшей диагностики
      setState(() {
        _statusMessage = "Загрузка данных о ресторанах и блюдах...";
      });
      
      try {
        await foodProvider.initData();
        print("FoodProvider initialized successfully");
      } catch (e) {
        print("Error initializing FoodProvider: $e");
        throw Exception("Ошибка загрузки данных о ресторанах: $e");
      }
      
      setState(() {
        _statusMessage = "Загрузка корзины...";
      });
      
      try {
        await cartProvider.initCart();
        print("CartProvider initialized successfully");
      } catch (e) {
        print("Error initializing CartProvider: $e");
        throw Exception("Ошибка загрузки корзины: $e");
      }
      
      setState(() {
        _statusMessage = "Загрузка данных пользователя...";
      });
      
      try {
        await userProvider.initUser();
        print("UserProvider initialized successfully");
      } catch (e) {
        print("Error initializing UserProvider: $e");
        throw Exception("Ошибка загрузки данных пользователя: $e");
      }
      
      setState(() {
        _statusMessage = "Готово!";
      });
      
      // Добавляем небольшую задержку для полного отображения анимации
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        // Проверяем авторизован ли пользователь
        if (userProvider.isLoggedIn && userProvider.user?.email != 'guest@example.com') {
          // Если пользователь авторизован, переходим на главный экран
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          // Если пользователь не авторизован, переходим на экран регистрации
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          );
        }
      }
    } catch (error) {
      setState(() {
        _hasError = true;
        _errorMessage = error.toString();
        _statusMessage = "Ошибка инициализации";
      });
      print("Error in _initializeAppData: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _logoAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Логотип приложения
              Icon(
                Icons.restaurant_menu,
                size: 120,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              // Название приложения
              Text(
                'Еда Доставка',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              // Статус загрузки
              Text(
                _statusMessage,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              // Индикатор загрузки или сообщение об ошибке
              if (_hasError)
                Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                          _errorMessage = "";
                          _statusMessage = "Повторная инициализация...";
                        });
                        _initializeAppData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: Text('Повторить'),
                    ),
                  ],
                )
              else
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 