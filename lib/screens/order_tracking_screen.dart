import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/courier.dart' as courier_model;
import '../models/courier_message.dart';
import '../models/order.dart';
import '../services/courier_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String courierId;

  const OrderTrackingScreen({
    Key? key,
    required this.orderId,
    required this.courierId,
  }) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  final CourierService _courierService = CourierService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  courier_model.Courier? _courier;
  List<courier_model.CourierMessage> _messages = [];
  Duration? _estimatedTime;
  bool _isRatingDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _initializeMap() async {
    final route = await _courierService.getCourierRoute(widget.orderId);
    _updateMapRoute(route);
    
    _courierService.trackCourierLocation(widget.courierId).listen((location) {
      _updateCourierLocation(location);
    });
  }

  void _updateMapRoute(List<LatLng> route) {
    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: route,
          color: Colors.blue,
          width: 5,
        ),
      };
    });
  }

  void _updateCourierLocation(LatLng location) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('courier'),
          position: location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: 'Курьер',
            snippet: 'В пути',
          ),
        ),
        Marker(
          markerId: const MarkerId('destination'),
          position: _markers.firstWhere((m) => m.markerId.value == 'destination').position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(
            title: 'Пункт назначения',
          ),
        ),
      };
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(location),
    );
  }

  void _updateMarkers(LatLng courierLocation, LatLng destination) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('courier'),
          position: courierLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: 'Курьер',
            snippet: 'В пути',
          ),
        ),
        Marker(
          markerId: const MarkerId('destination'),
          position: destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(
            title: 'Пункт назначения',
          ),
        ),
      };
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = courier_model.CourierMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      orderId: widget.orderId,
      senderId: 'user1',
      sender: courier_model.MessageSender.user,
      text: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    _courierService.sendMessage(widget.orderId, message.text);
    setState(() {
      _messages.add(message);
    });
    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showRatingDialog() {
    if (_isRatingDialogOpen) return;
    _isRatingDialogOpen = true;

    double rating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Оцените курьера',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() => rating = index + 1.0);
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Комментарий (необязательно)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _isRatingDialogOpen = false;
              },
              child: Text(
                'Отмена',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _courierService.rateCourier(
                  widget.courierId,
                  rating,
                  commentController.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  _isRatingDialogOpen = false;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Спасибо за вашу оценку!',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Отправить',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Отслеживание заказа',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_courier != null)
            IconButton(
              icon: const Icon(Icons.star_outline),
              onPressed: _showRatingDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: const LatLng(55.7558, 37.6173),
                zoom: 15,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_courier != null) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: _courier!.avatarUrl != null
                            ? NetworkImage(_courier!.avatarUrl!)
                            : null,
                        child: _courier!.avatarUrl == null
                            ? Text(
                                _courier!.name.substring(0, 1).toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _courier!.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${_courier!.vehicleType} ${_courier!.vehicleNumber}',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone),
                        color: Colors.deepOrange,
                        onPressed: () {
                          // TODO: Реализовать звонок курьеру
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _courier!.rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_courier!.completedDeliveries} доставок',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
                if (_estimatedTime != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.deepOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Примерное время доставки: ${_estimatedTime!.inMinutes} мин',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isUser = message.sender == courier_model.MessageSender.user;

                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Colors.deepOrange
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              message.text,
                              style: GoogleFonts.poppins(
                                color: isUser ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, -2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Написать сообщение...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send),
                          color: Colors.deepOrange,
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 