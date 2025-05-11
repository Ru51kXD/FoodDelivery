class Restaurant {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String coverImageUrl;
  final double rating;
  final int reviewCount;
  final List<String> categories;
  final String address;
  final double deliveryFee;
  final int deliveryTime;
  final double minOrderAmount;
  final bool isOpen;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.coverImageUrl,
    required this.rating,
    required this.reviewCount,
    required this.categories,
    required this.address,
    required this.deliveryFee,
    required this.deliveryTime,
    required this.minOrderAmount,
    required this.isOpen,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      coverImageUrl: json['coverImageUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      categories: List<String>.from(json['categories'] as List),
      address: json['address'] as String,
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      deliveryTime: json['deliveryTime'] as int,
      minOrderAmount: (json['minOrderAmount'] as num).toDouble(),
      isOpen: json['isOpen'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'coverImageUrl': coverImageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'categories': categories,
      'address': address,
      'deliveryFee': deliveryFee,
      'deliveryTime': deliveryTime,
      'minOrderAmount': minOrderAmount,
      'isOpen': isOpen,
    };
  }
}

class WorkingHours {
  final Map<String, DayHours> schedule;
  
  WorkingHours({
    required this.schedule,
  });
  
  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    Map<String, DayHours> schedule = {};
    json.forEach((key, value) {
      schedule[key] = DayHours.fromJson(value);
    });
    return WorkingHours(schedule: schedule);
  }
  
  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};
    schedule.forEach((key, value) {
      result[key] = value.toJson();
    });
    return result;
  }
}

class DayHours {
  final String open;
  final String close;
  final bool isDayOff;
  
  DayHours({
    required this.open,
    required this.close,
    this.isDayOff = false,
  });
  
  factory DayHours.fromJson(Map<String, dynamic> json) {
    return DayHours(
      open: json['open'],
      close: json['close'],
      isDayOff: json['isDayOff'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'close': close,
      'isDayOff': isDayOff,
    };
  }
}

class ContactInfo {
  final String phone;
  final String email;
  final String website;
  final Map<String, String> socialMedia;
  
  ContactInfo({
    required this.phone,
    required this.email,
    this.website = '',
    this.socialMedia = const {},
  });
  
  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      phone: json['phone'],
      email: json['email'],
      website: json['website'] ?? '',
      socialMedia: Map<String, String>.from(json['socialMedia'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'email': email,
      'website': website,
      'socialMedia': socialMedia,
    };
  }
} 