import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BonusProgramScreen extends StatelessWidget {
  const BonusProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Бонусная программа',
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with current points
            _buildBonusHeader(context),
            
            const SizedBox(height: 16),
            
            // Bonus levels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Уровни программы',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildLevelCards(),
            
            const SizedBox(height: 24),
            
            // How to earn points
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Как получать бонусы',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildEarningPointsSection(),
            
            const SizedBox(height: 24),
            
            // How to use points
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Как использовать бонусы',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildUsingPointsSection(),
            
            const SizedBox(height: 24),
            
            // Program rules
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.deepOrange),
                          const SizedBox(width: 8),
                          Text(
                            'Правила программы',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Бонусы начисляются в течение 24 часов после доставки заказа\n'
                        '• Бонусы действительны в течение 6 месяцев с момента начисления\n'
                        '• Бонусы нельзя обменять на денежные средства\n'
                        '• Бонусы можно использовать при оформлении заказа\n'
                        '• При отмене заказа начисленные бонусы аннулируются',
                        style: GoogleFonts.poppins(
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBonusHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange.shade400, Colors.deepOrange.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ваши бонусы',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '1,250',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'бонусов',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  'Серебряный уровень',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'До золотого: 750',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.6,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLevelCards() {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildLevelCard(
            title: 'Базовый',
            points: '0-999',
            benefits: ['5% бонусов от заказов', 'Выгода до 500₸ в месяц'],
            color: Colors.blueGrey,
            isActive: false,
          ),
          _buildLevelCard(
            title: 'Серебряный',
            points: '1000-1999',
            benefits: ['7% бонусов от заказов', 'Выгода до 1000₸ в месяц', 'Бесплатная доставка раз в неделю'],
            color: Colors.deepOrange,
            isActive: true,
          ),
          _buildLevelCard(
            title: 'Золотой',
            points: '2000+',
            benefits: ['10% бонусов от заказов', 'Выгода до 2000₸ в месяц', 'Бесплатная доставка каждый день', 'Эксклюзивные предложения'],
            color: Colors.amber.shade700,
            isActive: false,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLevelCard({
    required String title,
    required String points,
    required List<String> benefits,
    required Color color,
    required bool isActive,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? color : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Colors.transparent : color.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive ? color.withOpacity(0.4) : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: isActive ? Colors.white : color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : color,
                ),
              ),
            ],
          ),
          Text(
            '$points бонусов',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isActive ? Colors.white.withOpacity(0.8) : Colors.grey[600],
            ),
          ),
          const Divider(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: benefits.map((benefit) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: isActive ? Colors.white : color,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          benefit,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isActive ? Colors.white : Colors.grey[800],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEarningPointsSection() {
    final earningOptions = [
      {
        'icon': Icons.restaurant_menu,
        'title': 'Заказ еды',
        'description': 'Получайте 1 бонус за каждые 10₸, потраченные на заказ еды',
      },
      {
        'icon': Icons.event_available,
        'title': 'Регулярные заказы',
        'description': 'Дополнительные 50 бонусов за 3 заказа в неделю',
      },
      {
        'icon': Icons.reviews,
        'title': 'Отзывы о заказах',
        'description': 'Получайте 20 бонусов за каждый оставленный отзыв',
      },
      {
        'icon': Icons.notifications_active,
        'title': 'Промо-акции',
        'description': 'Следите за специальными акциями для получения дополнительных бонусов',
      },
    ];
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: earningOptions.length,
      itemBuilder: (context, index) {
        final option = earningOptions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                option['icon'] as IconData,
                color: Colors.deepOrange,
              ),
            ),
            title: Text(
              option['title'] as String,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              option['description'] as String,
              style: GoogleFonts.poppins(
                fontSize: 13,
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildUsingPointsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shopping_cart,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Оплата заказов',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Используйте бонусы для оплаты до 50% стоимости заказа. 1 бонус = 1 тенге',
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Как использовать бонусы:',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildStepItem('1', 'Добавьте товары в корзину'),
                            _buildStepItem('2', 'Перейдите к оформлению заказа'),
                            _buildStepItem('3', 'Выберите «Оплатить бонусами»'),
                            _buildStepItem('4', 'Укажите количество бонусов'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStepItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.deepOrange,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 