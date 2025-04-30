import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'screens/home_screen.dart';
import 'screens/restaurant_details_screen.dart';
import 'screens/food_details_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'providers/food_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Установка ориентации приложения
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Загрузка переменных окружения
  try {
    await dotenv.load();
    print("Dotenv loaded successfully");
  } catch (e) {
    print("Error loading .env file: $e");
  }
  
  // Инициализация Stripe
  try {
    final stripePubKey = dotenv.get('STRIPE_PUBLISHABLE_KEY', fallback: 'pk_test_default');
    if (stripePubKey != 'pk_test_your_key_here' && stripePubKey != 'pk_test_default') {
      Stripe.publishableKey = stripePubKey;
      await Stripe.instance.applySettings();
      print("Stripe initialized successfully");
    } else {
      print("Using default Stripe key or placeholder detected");
    }
  } catch (e) {
    print("Error initializing Stripe: $e");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Еда Доставка',
        debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            primary: Colors.deepOrange,
            secondary: Colors.orange,
            background: Colors.grey[50]!,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
        onGenerateRoute: (settings) {
          if (settings.name == '/home') {
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          } else if (settings.name?.startsWith('/restaurant/') ?? false) {
            final restaurantId = settings.name!.split('/').last;
            return MaterialPageRoute(
              builder: (_) => RestaurantDetailsScreen(restaurantId: restaurantId),
            );
          } else if (settings.name?.startsWith('/food/') ?? false) {
            final foodId = settings.name!.split('/').last;
            return MaterialPageRoute(
              builder: (_) => FoodDetailsScreen(foodId: foodId),
            );
          } else if (settings.name == '/cart') {
            return MaterialPageRoute(builder: (_) => const CartScreen());
          } else if (settings.name == '/checkout') {
            return MaterialPageRoute(builder: (_) => const CheckoutScreen());
          } else if (settings.name == '/profile') {
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          }
          return null;
        },
      ),
    );
  }
}
