class NotificationSettings {
  final bool orderUpdates;
  final bool promotions;
  final bool newRestaurants;
  final bool specialOffers;
  final bool deliveryStatus;
  final bool ratingReminders;
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;

  NotificationSettings({
    this.orderUpdates = true,
    this.promotions = true,
    this.newRestaurants = true,
    this.specialOffers = true,
    this.deliveryStatus = true,
    this.ratingReminders = true,
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.smsEnabled = false,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      orderUpdates: json['orderUpdates'] ?? true,
      promotions: json['promotions'] ?? true,
      newRestaurants: json['newRestaurants'] ?? true,
      specialOffers: json['specialOffers'] ?? true,
      deliveryStatus: json['deliveryStatus'] ?? true,
      ratingReminders: json['ratingReminders'] ?? true,
      pushEnabled: json['pushEnabled'] ?? true,
      emailEnabled: json['emailEnabled'] ?? true,
      smsEnabled: json['smsEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderUpdates': orderUpdates,
      'promotions': promotions,
      'newRestaurants': newRestaurants,
      'specialOffers': specialOffers,
      'deliveryStatus': deliveryStatus,
      'ratingReminders': ratingReminders,
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'smsEnabled': smsEnabled,
    };
  }

  NotificationSettings copyWith({
    bool? orderUpdates,
    bool? promotions,
    bool? newRestaurants,
    bool? specialOffers,
    bool? deliveryStatus,
    bool? ratingReminders,
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
  }) {
    return NotificationSettings(
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotions: promotions ?? this.promotions,
      newRestaurants: newRestaurants ?? this.newRestaurants,
      specialOffers: specialOffers ?? this.specialOffers,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      ratingReminders: ratingReminders ?? this.ratingReminders,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
    );
  }
} 