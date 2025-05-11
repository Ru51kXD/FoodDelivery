import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/order_scheduling_service.dart';
import '../models/order.dart';

class OrderCalendarScreen extends StatefulWidget {
  const OrderCalendarScreen({Key? key}) : super(key: key);

  @override
  State<OrderCalendarScreen> createState() => _OrderCalendarScreenState();
}

class _OrderCalendarScreenState extends State<OrderCalendarScreen> {
  final OrderSchedulingService _schedulingService = OrderSchedulingService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Order>> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCalendarData();
  }

  Future<void> _loadCalendarData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final startDate = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
      final endDate = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
      
      final calendarData = await _schedulingService.getOrderCalendar(
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        _events = calendarData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при загрузке календаря: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Order> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  Widget _buildEventList(List<Order> events) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final order = events[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: order.getStatusColor().withOpacity(0.1),
              child: Icon(
                Icons.shopping_bag,
                color: order.getStatusColor(),
              ),
            ),
            title: Text(
              'Заказ #${order.id}',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  order.restaurantName,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            trailing: Text(
              order.getStatusText(),
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: order.getStatusColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              // TODO: Навигация к деталям заказа
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Календарь заказов',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2025, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                    _loadCalendarData();
                  },
                  eventLoader: _getEventsForDay,
                  calendarStyle: CalendarStyle(
                    markersMaxCount: 3,
                    markerDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    formatButtonTextStyle: GoogleFonts.roboto(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _selectedDay == null
                      ? Center(
                          child: Text(
                            'Выберите день',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : _getEventsForDay(_selectedDay!).isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Нет заказов на этот день',
                                    style: GoogleFonts.roboto(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _buildEventList(_getEventsForDay(_selectedDay!)),
                ),
              ],
            ),
    );
  }
} 