import '../models/food_item.dart';
import '../models/restaurant.dart';

class MockData {
  // Список категорий
  static final List<String> categories = [
    'Бургеры',
    'Пицца',
    'Суши',
    'Десерты',
    'Салаты',
    'Супы',
    'Напитки',
    'Завтраки',
    'Шашлык',
    'Вегетарианское',
    'Паста',
    'Стейки',
  ];
  
  // Список ресторанов
  static final List<Restaurant> restaurants = [
    Restaurant(
      id: '1',
      name: 'Бургер Хаус',
      description: 'Лучшие бургеры в городе с сочными котлетами и свежими ингредиентами.',
      imageUrl: 'https://images.unsplash.com/photo-1561758033-d89a9ad46330',
      coverImageUrl: 'https://images.unsplash.com/photo-1561758033-7e924f619b47',
      categories: ['Бургеры', 'Фастфуд', 'Американская'],
      rating: 4.7,
      reviewCount: 248,
      address: 'ул. Пушкина, 25, Москва',
      isOpen: true,
      deliveryTime: '30-45 мин',
      deliveryFee: 99,
      minOrderAmount: 500,
      workingHours: WorkingHours(
        schedule: {
          'monday': DayHours(open: '10:00', close: '22:00'),
          'tuesday': DayHours(open: '10:00', close: '22:00'),
          'wednesday': DayHours(open: '10:00', close: '22:00'),
          'thursday': DayHours(open: '10:00', close: '22:00'),
          'friday': DayHours(open: '10:00', close: '23:00'),
          'saturday': DayHours(open: '11:00', close: '23:00'),
          'sunday': DayHours(open: '11:00', close: '22:00'),
        },
      ),
      contactInfo: ContactInfo(
        phone: '+7 (999) 123-45-67',
        email: 'info@burgerhouse.ru',
        website: 'https://burgerhouse.ru',
        socialMedia: {
          'instagram': '@burgerhouse_ru',
          'facebook': 'burgerhouse_ru',
        },
      ),
      isFeatured: true,
    ),
    
    Restaurant(
      id: '2',
      name: 'Пицца Мания',
      description: 'Итальянская пицца на тонком тесте, приготовленная в дровяной печи.',
      imageUrl: 'https://images.unsplash.com/photo-1593560708920-61dd98c46a4e',
      coverImageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591',
      categories: ['Пицца', 'Итальянская', 'Паста'],
      rating: 4.5,
      reviewCount: 186,
      address: 'ул. Ленина, 42, Москва',
      isOpen: true,
      deliveryTime: '40-60 мин',
      deliveryFee: 199,
      minOrderAmount: 700,
      workingHours: WorkingHours(
        schedule: {
          'monday': DayHours(open: '11:00', close: '23:00'),
          'tuesday': DayHours(open: '11:00', close: '23:00'),
          'wednesday': DayHours(open: '11:00', close: '23:00'),
          'thursday': DayHours(open: '11:00', close: '23:00'),
          'friday': DayHours(open: '11:00', close: '00:00'),
          'saturday': DayHours(open: '11:00', close: '00:00'),
          'sunday': DayHours(open: '12:00', close: '23:00'),
        },
      ),
      contactInfo: ContactInfo(
        phone: '+7 (999) 765-43-21',
        email: 'order@pizzamania.ru',
        website: 'https://pizzamania.ru',
        socialMedia: {
          'instagram': '@pizzamania_ru',
          'facebook': 'pizzamania_ru',
        },
      ),
      isFeatured: true,
    ),
    
    Restaurant(
      id: '3',
      name: 'Суши Мастер',
      description: 'Традиционные и авторские суши, роллы и другие блюда японской кухни.',
      imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c',
      coverImageUrl: 'https://images.unsplash.com/photo-1611143669185-af224c5e3252',
      categories: ['Суши', 'Японская', 'Азиатская'],
      rating: 4.8,
      reviewCount: 324,
      address: 'Проспект Мира, 78, Москва',
      isOpen: true,
      deliveryTime: '50-70 мин',
      deliveryFee: 299,
      minOrderAmount: 1000,
      workingHours: WorkingHours(
        schedule: {
          'monday': DayHours(open: '12:00', close: '22:00'),
          'tuesday': DayHours(open: '12:00', close: '22:00'),
          'wednesday': DayHours(open: '12:00', close: '22:00'),
          'thursday': DayHours(open: '12:00', close: '22:00'),
          'friday': DayHours(open: '12:00', close: '23:00'),
          'saturday': DayHours(open: '12:00', close: '23:00'),
          'sunday': DayHours(open: '12:00', close: '22:00'),
        },
      ),
      contactInfo: ContactInfo(
        phone: '+7 (999) 111-22-33',
        email: 'info@sushimaster.ru',
        website: 'https://sushimaster.ru',
        socialMedia: {
          'instagram': '@sushimaster_ru',
          'facebook': 'sushimaster_ru',
        },
      ),
      isFeatured: false,
    ),
  ];
  
  // Список всех блюд
  static final List<FoodItem> allFoods = [
    // Блюда ресторана "Бургер Хаус"
    FoodItem(
      id: '101',
      name: 'Классический бургер',
      description: 'Сочная говяжья котлета, свежий салат, помидоры, огурцы, красный лук и наш фирменный соус.',
      price: 379,
      imageUrl: 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90',
      restaurantId: '1',
      categories: ['Бургеры', 'Фастфуд'],
      rating: 4.7,
      reviewCount: 152,
      preparationTime: 15,
      isVegetarian: false,
      isSpicy: false,
      options: [
        FoodOption(
          name: 'Дополнительные ингредиенты',
          choices: [
            FoodOptionChoice(name: 'Дополнительный сыр', priceAdd: 50),
            FoodOptionChoice(name: 'Бекон', priceAdd: 80),
            FoodOptionChoice(name: 'Жареные грибы', priceAdd: 70),
            FoodOptionChoice(name: 'Халапеньо', priceAdd: 50),
          ],
          required: false,
          maxChoices: 4,
        ),
        FoodOption(
          name: 'Размер порции',
          choices: [
            FoodOptionChoice(name: 'Стандартный'),
            FoodOptionChoice(name: 'Большой', priceAdd: 150),
          ],
          required: true,
          maxChoices: 1,
        ),
      ],
      isAvailable: true,
      isFeatured: true,
    ),
    
    FoodItem(
      id: '102',
      name: 'Двойной чизбургер',
      description: 'Две говяжьих котлеты, двойной сыр чеддер, маринованные огурцы, красный лук, салат и соус.',
      price: 459,
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
      restaurantId: '1',
      categories: ['Бургеры', 'Фастфуд'],
      rating: 4.8,
      reviewCount: 98,
      preparationTime: 18,
      isVegetarian: false,
      isSpicy: false,
      options: [
        FoodOption(
          name: 'Дополнительные ингредиенты',
          choices: [
            FoodOptionChoice(name: 'Дополнительный сыр', priceAdd: 50),
            FoodOptionChoice(name: 'Бекон', priceAdd: 80),
            FoodOptionChoice(name: 'Жареные грибы', priceAdd: 70),
            FoodOptionChoice(name: 'Халапеньо', priceAdd: 50),
          ],
          required: false,
          maxChoices: 4,
        ),
      ],
      isAvailable: true,
      isFeatured: true,
    ),
    
    // Блюда ресторана "Пицца Мания"
    FoodItem(
      id: '201',
      name: 'Маргарита',
      description: 'Классическая итальянская пицца с томатным соусом, моцареллой и свежим базиликом.',
      price: 529,
      imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002',
      restaurantId: '2',
      categories: ['Пицца', 'Итальянская'],
      rating: 4.5,
      reviewCount: 112,
      preparationTime: 20,
      isVegetarian: true,
      isSpicy: false,
      options: [
        FoodOption(
          name: 'Размер',
          choices: [
            FoodOptionChoice(name: '25 см'),
            FoodOptionChoice(name: '30 см', priceAdd: 100),
            FoodOptionChoice(name: '35 см', priceAdd: 200),
          ],
          required: true,
          maxChoices: 1,
        ),
        FoodOption(
          name: 'Тип теста',
          choices: [
            FoodOptionChoice(name: 'Тонкое'),
            FoodOptionChoice(name: 'Традиционное'),
            FoodOptionChoice(name: 'С сырным бортом', priceAdd: 120),
          ],
          required: true,
          maxChoices: 1,
        ),
      ],
      isAvailable: true,
      isFeatured: false,
    ),
    
    FoodItem(
      id: '202',
      name: 'Пепперони',
      description: 'Томатный соус, моцарелла и пикантная пепперони. Классика, которую любят все.',
      price: 629,
      imageUrl: 'https://images.unsplash.com/photo-1593504049359-74330189a345',
      restaurantId: '2',
      categories: ['Пицца', 'Итальянская'],
      rating: 4.7,
      reviewCount: 165,
      preparationTime: 20,
      isVegetarian: false,
      isSpicy: true,
      options: [
        FoodOption(
          name: 'Размер',
          choices: [
            FoodOptionChoice(name: '25 см'),
            FoodOptionChoice(name: '30 см', priceAdd: 100),
            FoodOptionChoice(name: '35 см', priceAdd: 200),
          ],
          required: true,
          maxChoices: 1,
        ),
        FoodOption(
          name: 'Тип теста',
          choices: [
            FoodOptionChoice(name: 'Тонкое'),
            FoodOptionChoice(name: 'Традиционное'),
            FoodOptionChoice(name: 'С сырным бортом', priceAdd: 120),
          ],
          required: true,
          maxChoices: 1,
        ),
      ],
      isAvailable: true,
      isFeatured: true,
    ),
    
    // Блюда ресторана "Суши Мастер"
    FoodItem(
      id: '301',
      name: 'Филадельфия',
      description: 'Классический ролл с нежным лососем, сливочным сыром и авокадо.',
      price: 499,
      imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351',
      restaurantId: '3',
      categories: ['Суши', 'Японская'],
      rating: 4.9,
      reviewCount: 235,
      preparationTime: 15,
      isVegetarian: false,
      isSpicy: false,
      options: [
        FoodOption(
          name: 'Размер',
          choices: [
            FoodOptionChoice(name: '4 шт.', priceAdd: -100),
            FoodOptionChoice(name: '8 шт.'),
            FoodOptionChoice(name: '12 шт.', priceAdd: 150),
          ],
          required: true,
          maxChoices: 1,
        ),
      ],
      isAvailable: true,
      isFeatured: true,
    ),
    
    FoodItem(
      id: '302',
      name: 'Набор "Суши Mix"',
      description: 'Ассорти из 32 лучших роллов нашего ресторана - идеально для компании.',
      price: 1699,
      imageUrl: 'https://images.unsplash.com/photo-1617196701537-7329482cc9fe',
      restaurantId: '3',
      categories: ['Суши', 'Японская', 'Сеты'],
      rating: 4.8,
      reviewCount: 87,
      preparationTime: 30,
      isVegetarian: false,
      isSpicy: true,
      options: [
        FoodOption(
          name: 'Острота васаби',
          choices: [
            FoodOptionChoice(name: 'Стандартная'),
            FoodOptionChoice(name: 'Острая'),
            FoodOptionChoice(name: 'Без васаби'),
          ],
          required: true,
          maxChoices: 1,
        ),
      ],
      isAvailable: true,
      isFeatured: false,
    ),
  ];
  
  // Популярные блюда
  static final List<FoodItem> popularFoods = [
    allFoods.firstWhere((food) => food.id == '101'),
    allFoods.firstWhere((food) => food.id == '202'),
    allFoods.firstWhere((food) => food.id == '301'),
    allFoods.firstWhere((food) => food.id == '102'),
  ];
  
  // Рекомендованные блюда
  static final List<FoodItem> recommendedFoods = [
    allFoods.firstWhere((food) => food.id == '202'),
    allFoods.firstWhere((food) => food.id == '102'),
    allFoods.firstWhere((food) => food.id == '301'),
  ];
} 
import '../models/restaurant.dart';

class MockData {
  // Список категорий
  static final List<String> categories = [
    'Бургеры',
    'Пицца',
    'Суши',
    'Десерты',
    'Салаты',
    'Супы',
    'Напитки',
    'Завтраки',
    'Шашлык',
    'Вегетарианское',
    'Паста',
    'Стейки',
  ];
  
  // Список ресторанов
  static final List<Restaurant> restaurants = [
    Restaurant(
      id: '1',
      name: 'Бургер Хаус',
      description: 'Лучшие бургеры в городе с сочными котлетами и свежими ингредиентами.',
      imageUrl: 'https://images.unsplash.com/photo-1561758033-d89a9ad46330',
      coverImageUrl: 'https://images.unsplash.com/photo-1561758033-7e924f619b47',
      categories: ['Бургеры', 'Фастфуд', 'Американская'],
      rating: 4.7,
      reviewCount: 248,
      address: 'ул. Пушкина, 25, Москва',
      isOpen: true,
      deliveryTime: '30-45 мин',
      deliveryFee: 99,
      minOrderAmount: 500,
      workingHours: WorkingHours(
        schedule: {
          'monday': DayHours(open: '10:00', close: '22:00'),
          'tuesday': DayHours(open: '10:00', close: '22:00'),
          'wednesday': DayHours(open: '10:00', close: '22:00'),
          'thursday': DayHours(open: '10:00', close: '22:00'),
          'friday': DayHours(open: '10:00', close: '23:00'),
          'saturday': DayHours(open: '11:00', close: '23:00'),
          'sunday': DayHours(open: '11:00', close: '22:00'),
        },
      ),
      contactInfo: ContactInfo(
        phone: '+7 (999) 123-45-67',
        email: 'info@burgerhouse.ru',
        website: 'https://burgerhouse.ru',
        socialMedia: {
          'instagram': '@burgerhouse_ru',
          'facebook': 'burgerhouse_ru',
        },
      ),
      isFeatured: true,
    ),
    
    Restaurant(
      id: '2',
      name: 'Пицца Мания',
      description: 'Итальянская пицца на тонком тесте, приготовленная в дровяной печи.',
      imageUrl: 'https://images.unsplash.com/photo-1593560708920-61dd98c46a4e',
      coverImageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591',
      categories: ['Пицца', 'Итальянская', 'Паста'],
      rating: 4.5,
      reviewCount: 186,
      address: 'ул. Ленина, 42, Москва',
      isOpen: true,
      deliveryTime: '40-60 мин',
      deliveryFee: 199,
      minOrderAmount: 700,
      workingHours: WorkingHours(
        schedule: {
          'monday': DayHours(open: '11:00', close: '23:00'),
          'tuesday': DayHours(open: '11:00', close: '23:00'),
          'wednesday': DayHours(open: '11:00', close: '23:00'),
          'thursday': DayHours(open: '11:00', close: '23:00'),
          'friday': DayHours(open: '11:00', close: '00:00'),
          'saturday': DayHours(open: '11:00', close: '00:00'),
          'sunday': DayHours(open: '12:00', close: '23:00'),
        },
      ),
      contactInfo: ContactInfo(
        phone: '+7 (999) 765-43-21',
        email: 'order@pizzamania.ru',
        website: 'https://pizzamania.ru',
        socialMedia: {
          'instagram': '@pizzamania_ru',
          'facebook': 'pizzamania_ru',
        },
      ),
      isFeatured: true,
    ),
    
    Restaurant(
      id: '3',
      name: 'Суши Мастер',
      description: 'Традиционные и авторские суши, роллы и другие блюда японской кухни.',
      imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c',
      coverImageUrl: 'https://images.unsplash.com/photo-1611143669185-af224c5e3252',
      categories: ['Суши', 'Японская', 'Азиатская'],
      rating: 4.8,
      reviewCount: 324,
      address: 'Проспект Мира, 78, Москва',
      isOpen: true,
      deliveryTime: '50-70 мин',
      deliveryFee: 299,
      minOrderAmount: 1000,
      workingHours: WorkingHours(
        schedule: {
          'monday': DayHours(open: '12:00', close: '22:00'),
          'tuesday': DayHours(open: '12:00', close: '22:00'),
          'wednesday': DayHours(open: '12:00', close: '22:00'),
          'thursday': DayHours(open: '12:00', close: '22:00'),
          'friday': DayHours(open: '12:00', close: '23:00'),
          'saturday': DayHours(open: '12:00', close: '23:00'),
          'sunday': DayHours(open: '12:00', close: '22:00'),
        },
      ),
      contactInfo: ContactInfo(
        phone: '+7 (999) 111-22-33',
        email: 'info@sushimaster.ru',
        website: 'https://sushimaster.ru',
        socialMedia: {
          'instagram': '@sushimaster_ru',
          'facebook': 'sushimaster_ru',
        },
      ),
      isFeatured: false,
    ),
  ];
  
  // Список всех блюд
  static final List<FoodItem> allFoods = [
    // Блюда ресторана "Бургер Хаус"
    FoodItem(
      id: '101',
      name: 'Классический бургер',
      description: 'Сочная говяжья котлета, свежий салат, помидоры, огурцы, красный лук и наш фирменный соус.',
      price: 379,
      imageUrl: 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90',
      restaurantId: '1',
      categories: ['Бургеры', 'Фастфуд'],
      rating: 4.7,
      reviewCount: 152,
      preparationTime: 15,
      isVegetarian: false,
      isSpicy: false,
      options: [
        FoodOption(
          name: 'Дополнительные ингредиенты',
          choices: [
            FoodOptionChoice(name: 'Дополнительный сыр', priceAdd: 50),
            FoodOptionChoice(name: 'Бекон', priceAdd: 80),
            FoodOptionChoice(name: 'Жареные грибы', priceAdd: 70),
            FoodOptionChoice(name: 'Халапеньо', priceAdd: 50),
          ],
          required: false,
          maxChoices: 4,
        ),
        FoodOption(
          name: 'Размер порции',
          choices: [
            FoodOptionChoice(name: 'Стандартный'),
            FoodOptionChoice(name: 'Большой', priceAdd: 150),
          ],
          required: true,
          maxChoices: 1,
        ),
      ],
      isAvailable: true,
      isFeatured: true,
    ),
    
    FoodItem(
      id: '102',
      name: 'Двойной чизбургер',
      description: 'Две говяжьих котлеты, двойной сыр чеддер, маринованные огурцы, красный лук, салат и соус.',
      price: 459,
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
      restaurantId: '1',
      categories: ['Бургеры', 'Фастфуд'],
      rating: 4.8,
      reviewCount: 98,
      preparationTime: 18,
      isVegetarian: false,
      isSpicy: false,
      options: [
        FoodOption(
          name: 'Дополнительные ингредиенты',
          choices: [
            FoodOptionChoice(name: 'Дополнительный сыр', priceAdd: 50),
            FoodOptionChoice(name: 'Бекон', priceAdd: 80),
            FoodOptionChoice(name: 'Жареные грибы', priceAdd: 70),
            FoodOptionChoice(name: 'Халапеньо', priceAdd: 50),
          ],
          required: false,
          maxChoices: 4,
        ),
      ],
      isAvailable: true,
      isFeatured: true,
    ),
    
    // Блюда ресторана "Пицца Мания"
    FoodItem(
      id: '201',
      name: 'Маргарита',
      description: 'Классическая итальянская пицца с томатным соусом, моцареллой и свежим базиликом.',
      price: 529,
      imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002',
      restaurantId: '2',
      categories: ['Пицца', 'Итальянская'],
      rating: 4.5,
      reviewCount: 112,
      preparationTime: 20,
      isVegetarian: true,
      isSpicy: false,
      options: [
        FoodOption(
          name: 'Размер',
          choices: [
            FoodOptionChoice(name: '25 см'),
            FoodOptionChoice(name: '30 см', priceAdd: 100),
            FoodOptionChoice(name: '35 см', priceAdd: 200),
          ],
          required: true,
          maxChoices: 1,
        ),
        FoodOption(
          name: 'Тип теста',
          choices: [
            FoodOptionChoice(name: 'Тонкое'),
            FoodOptionChoice(name: 'Традиционное'),
            FoodOptionChoice(name: 'С сырным бортом', priceAdd: 120),
          ],
          required: true,
          maxChoices: 1,
        ),
      ],
      isAvailable: true,
      isFeatured: false,
    ),
    
    FoodItem(
      id: '202',
      name: 'Пепперони',
      description: 'Томатный соус, моцарелла и пикантная пепперони. Классика, которую любят все.',
      price: 629,
      imageUrl: 'https://images.unsplash.com/photo-1593504049359-74330189a345',
      restaurantId: '2',
      categories: ['Пицца', 'Итальянская'],
      rating: 4.7,
      reviewCount: 165,
      preparationTime: 20,
      isVegetarian: false,
      isSpicy: true,
      options: [
        FoodOption(
          name: 'Размер',
          choices: [
            FoodOptionChoice(name: '25 см'),
            FoodOptionChoice(name: '30 см', priceAdd: 100),
            FoodOptionChoice(name: '35 см', priceAdd: 200),
          ],
          required: true,
          maxChoices: 1,
        ),
        FoodOption(
          name: 'Тип теста',
          choices: [
            FoodOptionChoice(name: 'Тонкое'),
            FoodOptionChoice(name: 'Традиционное'),
            FoodOptionChoice(name: 'С сырным бортом', priceAdd: 120),
          ],
          required: true,
          maxChoices: 1,
        ),
      ],
      isAvailable: true,
      isFeatured: true,
    ),
    
    // Блюда ресторана "Суши Мастер"
    FoodItem(
      id: '301',
      name: 'Филадельфия',
      description: 'Классический ролл с нежным лососем, сливочным сыром и авокадо.',
      price: 499,
      imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351',
      restaurantId: '3',
      categories: ['Суши', 'Японская'],
      rating: 4.9,
      reviewCount: 235,
      preparationTime: 15,
      isVegetarian: false,
      isSpicy: false,
      options: [
        FoodOption(
          name: 'Размер',
          choices: [
            FoodOptionChoice(name: '4 шт.', priceAdd: -100),
            FoodOptionChoice(name: '8 шт.'),
            FoodOptionChoice(name: '12 шт.', priceAdd: 150),
          ],
          required: true,
          maxChoices: 1,
        ),
      ],
      isAvailable: true,
      isFeatured: true,
    ),
    
    FoodItem(
      id: '302',
      name: 'Набор "Суши Mix"',
      description: 'Ассорти из 32 лучших роллов нашего ресторана - идеально для компании.',
      price: 1699,
      imageUrl: 'https://images.unsplash.com/photo-1617196701537-7329482cc9fe',
      restaurantId: '3',
      categories: ['Суши', 'Японская', 'Сеты'],
      rating: 4.8,
      reviewCount: 87,
      preparationTime: 30,
      isVegetarian: false,
      isSpicy: true,
      options: [
        FoodOption(
          name: 'Острота васаби',
          choices: [
            FoodOptionChoice(name: 'Стандартная'),
            FoodOptionChoice(name: 'Острая'),
            FoodOptionChoice(name: 'Без васаби'),
          ],
          required: true,
          maxChoices: 1,
        ),
      ],
      isAvailable: true,
      isFeatured: false,
    ),
  ];
  
  // Популярные блюда
  static final List<FoodItem> popularFoods = [
    allFoods.firstWhere((food) => food.id == '101'),
    allFoods.firstWhere((food) => food.id == '202'),
    allFoods.firstWhere((food) => food.id == '301'),
    allFoods.firstWhere((food) => food.id == '102'),
  ];
  
  // Рекомендованные блюда
  static final List<FoodItem> recommendedFoods = [
    allFoods.firstWhere((food) => food.id == '202'),
    allFoods.firstWhere((food) => food.id == '102'),
    allFoods.firstWhere((food) => food.id == '301'),
  ];
} 