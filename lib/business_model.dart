class Business {
  final String name;
  final int? id;
  final String businessType;
  final String category;
  final String review;
  final String phone;
  final String address;
  final String services;
  final String addedValue;
  final String opinions;
  final String whatsapp;
  final String promotions;
  final String locationLink;
  final String eventDate;
  final String openingHours;
  final String prices;
  final String imagePaths; // New field for the image URL

  Business({
    this.id,
    required this.name,
    required this.businessType,
    required this.category,
    required this.review,
    required this.phone,
    required this.address,
    required this.services,
    required this.addedValue,
    required this.opinions,
    required this.whatsapp,
    required this.promotions,
    required this.locationLink,
    required this.eventDate,
    required this.openingHours,
    required this.prices,
    required this.imagePaths,
  });

  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'name': name,
      'businessType': businessType,
      'category': category,
      'review': review,
      'phone': phone,
      'address': address,
      'services': services,
      'addedValue': addedValue,
      'opinions': opinions,
      'whatsapp': whatsapp,
      'promotions': promotions,
      'locationLink': locationLink,
      'eventDate': eventDate,
      'openingHours': openingHours,
      'prices': prices,
      'imagePaths': imagePaths, 
    };
  }

  // From map to Business object
  factory Business.fromMap(Map<String, dynamic> map) {
    return Business(
      id:map["id"],
      name: map['name'],
      businessType: map['businessType'],
      category: map['category'],
      review: map['review'],
      phone: map['phone'],
      address: map['address'],
      services: map['services'],
      addedValue: map['addedValue'],
      opinions: map['opinions'],
      whatsapp: map['whatsapp'],
      promotions: map['promotions'],
      locationLink: map['locationLink'],
      eventDate: map['eventDate'],
      openingHours: map['openingHours'],
      prices: map['prices'],
      imagePaths: map['imagePaths'] ?? '', // Default to empty string if null
    );
  }
  Business copyWith({
    int? id,
    String? name,
    String? businessType,
    String? category,
    String? review,
    String? phone,
    String? address,
    String? services,
    String? addedValue,
    String? opinions,
    String? whatsapp,
    String? promotions,
    String? locationLink,
    String? eventDate,
    String? openingHours,
    String? prices,
    String? imagePaths,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      businessType: businessType ?? this.businessType,
      category: category ?? this.category,
      review: review ?? this.review,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      services: services ?? this.services,
      addedValue: addedValue ?? this.addedValue,
      opinions: opinions ?? this.opinions,
      whatsapp: whatsapp ?? this.whatsapp,
      promotions: promotions ?? this.promotions,
      locationLink: locationLink ?? this.locationLink,
      eventDate: eventDate ?? this.eventDate,
      openingHours: openingHours ?? this.openingHours,
      prices: prices ?? this.prices,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }
}
