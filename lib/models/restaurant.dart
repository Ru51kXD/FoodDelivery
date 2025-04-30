class Restaurant {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String coverImageUrl;
  final List<String> categories;
  final double rating;
  final int reviewCount;
  final String address;
  final bool isOpen;
  final String deliveryTime;
  final double deliveryFee;
  final double minOrderAmount;
  final WorkingHours workingHours;
  final ContactInfo contactInfo;
  final bool isFeatured;
  
  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.coverImageUrl,
    required this.categories,
    required this.rating,
    required this.reviewCount,
    required this.address,
    required this.isOpen,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.minOrderAmount,
    required this.workingHours,
    required this.contactInfo,
    this.isFeatured = false,
  });
  
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      coverImageUrl: json['coverImageUrl'],
      categories: List<String>.from(json['categories']),
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      address: json['address'],
      isOpen: json['isOpen'],
      deliveryTime: json['deliveryTime'],
      deliveryFee: json['deliveryFee'].toDouble(),
      minOrderAmount: json['minOrderAmount'].toDouble(),
      workingHours: WorkingHours.fromJson(json['workingHours']),
      contactInfo: ContactInfo.fromJson(json['contactInfo']),
      isFeatured: json['isFeatured'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'coverImageUrl': coverImageUrl,
      'categories': categories,
      'rating': rating,
      'reviewCount': reviewCount,
      'address': address,
      'isOpen': isOpen,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'minOrderAmount': minOrderAmount,
      'workingHours': workingHours.toJson(),
      'contactInfo': contactInfo.toJson(),
      'isFeatured': isFeatured,
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