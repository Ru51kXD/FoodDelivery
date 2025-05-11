import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../providers/user_provider.dart';
import 'home_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    // Using postFrameCallback to avoid calling provider methods during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initApp();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // No longer calling _initApp here to avoid build-time notification errors
  }

  Future<void> _initApp() async {
    try {
      // Инициализируем данные провайдеров
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Параллельная инициализация
      await Future.wait([
        foodProvider.initData(),
        userProvider.init(),
      ]);
      
      // После успешной инициализации переходим на главный экран
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const HomeScreen()),
        );
      }
    } catch (e) {
      print("Error initializing app: $e");
      // Все равно переходим на главный экран, так как у нас есть запасные мок-данные
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Логотип
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.white,
                size: 60,
              ),
            ),
            
            // Название приложения
            Text(
              'Доставка еды',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            
            const SizedBox(height: 50),
            
            // Индикатор загрузки
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Текст загрузки
            const Text(
              'Загрузка вкусностей...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 