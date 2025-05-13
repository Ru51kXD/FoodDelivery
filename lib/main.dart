import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'providers/food_provider.dart';
import 'providers/user_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/home_screen.dart';
import 'screens/loading_screen.dart';
import 'widgets/safe_image.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/delivery_address_screen.dart';
import 'screens/payment_methods_screen.dart';
import 'screens/bonus_program_screen.dart';

// Добавляем глобальный обработчик исключений
FlutterErrorDetails? _lastErrorDetails;
// Флаг для определения, запущены ли мы на эмуляторе
bool _isEmulator = false;

void main() async {
  // Убедимся, что Flutter инициализирован
  WidgetsFlutterBinding.ensureInitialized();
  
  // На Android проверяем, запущены ли мы на эмуляторе
  if (Platform.isAndroid) {
    _isEmulator = await _checkIfEmulator();
    
    // Устанавливаем режим эмулятора для SafeImage
    setEmulatorMode(_isEmulator);
    
    // Для эмуляторов отключаем некоторые тяжелые эффекты
    if (_isEmulator) {
      // Снижаем качество рендеринга для эмулятора
      debugPaintSizeEnabled = false;
      debugPaintBaselinesEnabled = false;
      debugPaintLayerBordersEnabled = false;
      debugPaintPointersEnabled = false;
      debugRepaintRainbowEnabled = false;
    }
    
    // Принудительно активируем skia renderer для Android
    if (Platform.isAndroid) {
      try {
        const MethodChannel('flutter/skia').invokeMethod('enable', "true");
      } catch (e) {
        print('Failed to enable Skia: $e');
      }
    }
  }
  
  // Оптимизируем производительность отрисовки
  WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = false;
  
  // Отключаем анимации во время первичной загрузки
  timeDilation = 0.8; // Немного замедляем для плавности
  
  // Оптимизация для отрисовки - предотвращает лишние перерисовки
  if (!kReleaseMode) {
    // Включаем только для дебага - помогает отслеживать перерисовки
    debugRepaintRainbowEnabled = false;
    debugPrintMarkNeedsLayoutStacks = false;
    debugPrintMarkNeedsPaintStacks = false;
  }
  
  // Добавляем оптимизацию для ожидания первого кадра
  await Future.delayed(Duration.zero);
  
  // Предварительная инициализация платформенных каналов
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Оптимизируем UI для лучшей производительности
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );
  
  // Устанавливаем цвет статус-бара
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  
  // Обработка ошибок рендеринга
  FlutterError.onError = (FlutterErrorDetails details) {
    // Сохраняем последнюю ошибку для возможной отправки на сервер
    _lastErrorDetails = details;
    
    // Выводим ошибку в консоль
    FlutterError.presentError(details);
    
    // Игнорируем все OpenGL ошибки на эмуляторе
    if (_isEmulator && 
        (details.exception.toString().contains('OpenGL') ||
         details.exception.toString().contains('GL_') ||
         details.exception.toString().contains('EGL'))) {
      print('Ignoring OpenGL error on emulator: ${details.exception}');
      return;
    }
    
    // Не падаем, если это графические ошибки
    if (details.exception.toString().contains('image') == false &&
        details.exception.toString().contains('rendering') == false &&
        details.exception.toString().contains('texture') == false &&
        details.exception.toString().contains('OpenGL') == false &&
        details.exception.toString().contains('shader') == false &&
        details.exception.toString().contains('EGL') == false) {
      // В релизном режиме просто логируем, но не падаем
      if (kReleaseMode) {
        print('Error: ${details.exception}');
      } else {
        // В дебаг режиме можно упасть
        // Но не для OpenGL ошибок на эмуляторе
        if (!Platform.isAndroid || !details.exception.toString().contains('GL_')) {
          // exit(1); // Не делаем exit, это приведет к краху приложения
          print('Critical error: ${details.exception}');
        }
      }
    }
  };
  
  // Настройка изолятов для фоновой работы
  if (Platform.isAndroid || Platform.isIOS) {
    // Отключаем политику безопасности веб-изображений для избежания ошибок
    HttpOverrides.global = MyHttpOverrides();
  }
  
  // Устанавливаем обработчик для ошибок in-flight
  PlatformDispatcher.instance.onError = (error, stack) {
    // Игнорируем все OpenGL ошибки на эмуляторе
    if (_isEmulator && 
        (error.toString().contains('OpenGL') ||
         error.toString().contains('GL_') ||
         error.toString().contains('EGL'))) {
      print('Ignoring OpenGL error on emulator: $error');
      return true;
    }
    
    print('Error caught by platform dispatcher: $error');
    return true; // true = error handled
  };
  
  // Устанавливаем лимит кадров, чтобы избежать "janky frames"
  if (kReleaseMode) {
    // В релизе стараемся поддерживать стабильные 60fps
    await SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: 'Доставка еды',
        primaryColor: Colors.deepOrange.value,
      ),
    );
  }
  
  // Предзагружаем общие ресурсы для предотвращения задержек первой отрисовки
  if (Platform.isAndroid) {
    await _preloadCommonResources();
  }
  
  // Теперь запускаем приложение
  runApp(const MyApp());
}

// Проверка, запущены ли мы на эмуляторе
Future<bool> _checkIfEmulator() async {
  try {
    final result = await const MethodChannel('flutter/platform')
        .invokeMethod<String>('getSystemProperty', 'ro.build.characteristics');
    return result?.contains('emulator') == true;
  } catch (e) {
    print('Error checking if emulator: $e');
    return false;
  }
}

// Предзагрузка общих ресурсов для предотвращения задержек первой отрисовки
Future<void> _preloadCommonResources() async {
  try {
    final canvas = ui.Canvas(ui.PictureRecorder());
    
    // Создаем простые графические примитивы для загрузки шрифтов и базовых ресурсов
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(const Offset(100, 100), 50, paint);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), paint);
    
    // Ожидаем фрейм для принудительной загрузки ресурсов
    await Future.delayed(const Duration(milliseconds: 16));
  } catch (e) {
    print('Ошибка предзагрузки ресурсов: $e');
  }
}

// Класс для обхода ограничений безопасности при загрузке изображений
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

// Оптимизированное построение приложения с отложенной инициализацией тяжелых компонентов
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ленивая загрузка тем и локализаций
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      builder: (context, _) {
        // Отключаем отладочную сетку в режиме релиза
        return MaterialApp(
          title: 'Доставка еды',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: Colors.deepOrange,
              secondary: Colors.deepOrangeAccent,
            ),
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'Roboto',
            useMaterial3: true,
          ),
          routes: {
            '/': (context) => const SplashScreen(),
            '/welcome': (context) => const WelcomeScreen(),
            '/register': (context) => const RegisterScreen(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/delivery_addresses': (context) => const DeliveryAddressScreen(),
            '/payment_methods': (context) => const PaymentMethodsScreen(),
            '/bonus_program': (context) => const BonusProgramScreen(),
          },
          initialRoute: '/',
        );
      },
    );
  }
}

// Экран для проверки аутентификации
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Добавляем небольшую задержку для отображения сплеш-экрана
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.init();
    
    if (!mounted) return;
    
    // Если пользователь аутентифицирован и это не гостевой аккаунт, 
    // то переходим на главный экран, иначе на экран регистрации
    if (userProvider.isLoggedIn && userProvider.user?.email != 'guest@example.com') {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // Вместо экрана приветствия сразу показываем экран регистрации
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const RegisterScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepOrange.shade400,
              Colors.deepOrange.shade700,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fastfood,
                size: 80.0,
                color: Colors.white,
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Доставка еды',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48.0),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Оптимизированный экран загрузки
class OptimizedLoadingScreen extends StatefulWidget {
  const OptimizedLoadingScreen({Key? key}) : super(key: key);

  @override
  State<OptimizedLoadingScreen> createState() => _OptimizedLoadingScreenState();
}

class _OptimizedLoadingScreenState extends State<OptimizedLoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isInitialized = false;
  Completer<void> _initCompleter = Completer<void>();
  
  @override
  void initState() {
    super.initState();
    
    // Инициализируем анимацию загрузки
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    // Инициализируем провайдеры поэтапно для уменьшения нагрузки
    _initializeProvidersInStages();
  }
  
  Future<void> _initializeProvidersInStages() async {
    try {
      // Шаг 1: Первичная загрузка UI без данных
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Шаг 2: Инициализация провайдеров последовательно чтобы избежать блокировки UI
      await Future.microtask(() {
        final foodProvider = Provider.of<FoodProvider>(context, listen: false);
        // Используем оптимизированный метод инициализации
        foodProvider.initData();
      });
      
      // Шаг 3: Мониторинг заполнения базы
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);
      
      // Ждем пока база заполнится или пройдет 10 секунд
      int attempts = 0;
      while (foodProvider.isPopulatingDatabase && attempts < 100) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      
      // Пауза для обработки первого блока данных
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Шаг 4: Инициализируем пользовательские данные (менее критичные)
      await Future.microtask(() {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.init();
      });
      
      // Даем немного времени на отображение загрузочного экрана и завершение инициализации
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        
        // Переходим на главный экран с плавной анимацией
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (_, __, ___) => const HomeScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      }
      
      _initCompleter.complete();
    } catch (e) {
      print('Error during initialization: $e');
      _initCompleter.completeError(e);
      // В случае ошибки все равно перейдем на главный экран
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Получаем информацию о заполнении базы данных
    final foodProvider = Provider.of<FoodProvider>(context);
    final bool isPopulatingDatabase = foodProvider.isPopulatingDatabase;
    final double progress = foodProvider.databasePopulationProgress;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepOrange.shade400,
              Colors.deepOrange.shade700,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo - используем более легкий вариант
              const Icon(
                Icons.fastfood,
                size: 80.0,
                color: Colors.white,
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Доставка еды',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48.0),
              // Показываем индикатор загрузки с анимацией
              if (isPopulatingDatabase) 
                // Показываем прогресс заполнения базы
                Column(
                  children: [
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Подготовка данных... ${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              else
                // Показываем обычный индикатор загрузки
                SizedBox(
                  width: 48.0,
                  height: 48.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
