import 'package:flutter/material.dart';
import '../models/loyalty_program.dart';
import '../services/loyalty_service.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({Key? key}) : super(key: key);

  @override
  _LoyaltyScreenState createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final LoyaltyService _loyaltyService = LoyaltyService();
  late Future<LoyaltyProgram> _loyaltyProgramFuture;
  late Future<List<LoyaltyReward>> _availableRewardsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // TODO: Заменить на реальный ID пользователя
    const userId = 'user123';
    _loyaltyProgramFuture = _loyaltyService.getUserLoyaltyProgram(userId);
    _availableRewardsFuture = _loyaltyService.getAvailableRewards(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Программа лояльности'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadData();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLoyaltyStatus(),
                const SizedBox(height: 24),
                _buildAvailableRewards(),
                const SizedBox(height: 24),
                _buildRewardHistory(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoyaltyStatus() {
    return FutureBuilder<LoyaltyProgram>(
      future: _loyaltyProgramFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Ошибка загрузки данных: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final loyaltyProgram = snapshot.data!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loyaltyProgram.tierText,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    _buildTierIcon(loyaltyProgram.tier),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Ваши бонусы: ${loyaltyProgram.points}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (loyaltyProgram.nextTier != null) ...[
                  Text(
                    'До следующего уровня: ${loyaltyProgram.pointsToNextTier} баллов',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: loyaltyProgram.progressToNextTier,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Ваши преимущества:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...loyaltyProgram.tierBenefits.map((benefit) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(child: Text(benefit)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvailableRewards() {
    return FutureBuilder<List<LoyaltyReward>>(
      future: _availableRewardsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Ошибка загрузки наград: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final rewards = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Доступные награды',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (rewards.isEmpty)
              const Center(
                child: Text('Нет доступных наград'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rewards.length,
                itemBuilder: (context, index) {
                  final reward = rewards[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(reward.title),
                      subtitle: Text(reward.description),
                      trailing: Text(
                        '${reward.pointsCost} баллов',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      onTap: () => _showRewardDetails(reward),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildRewardHistory() {
    return FutureBuilder<LoyaltyProgram>(
      future: _loyaltyProgramFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Ошибка загрузки истории: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final usedRewards = snapshot.data!.usedRewards;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'История наград',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (usedRewards.isEmpty)
              const Center(
                child: Text('История пуста'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: usedRewards.length,
                itemBuilder: (context, index) {
                  final reward = usedRewards[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(reward.title),
                      subtitle: Text(
                        'Использовано: ${_formatDate(reward.usedAt!)}',
                      ),
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildTierIcon(LoyaltyTier tier) {
    IconData iconData;
    Color color;

    switch (tier) {
      case LoyaltyTier.bronze:
        iconData = Icons.star;
        color = Colors.brown;
        break;
      case LoyaltyTier.silver:
        iconData = Icons.star;
        color = Colors.grey;
        break;
      case LoyaltyTier.gold:
        iconData = Icons.star;
        color = Colors.amber;
        break;
      case LoyaltyTier.platinum:
        iconData = Icons.star;
        color = Colors.blue;
        break;
    }

    return Icon(iconData, color: color, size: 32);
  }

  void _showRewardDetails(LoyaltyReward reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reward.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reward.description),
            const SizedBox(height: 16),
            Text(
              'Стоимость: ${reward.pointsCost} баллов',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Действует до: ${_formatDate(reward.validUntil)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Реализовать использование награды
              Navigator.pop(context);
            },
            child: const Text('Использовать'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
} 