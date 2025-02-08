class Business {
  final String id;
  final String name;
  final String businessType;
  final String category;
  final String review;
  final String phone;
  final String address;
  final String municipal;
  final String services;
  final String addedValue;
  final String opinions;
  final String whatsapp;
  final String promotions;
   String locationLink;
  final String facebookPage;
  final String website;
  final String eventDate;
  final String openingHours;
  final String closingHours;
  final String prices;
  final List<dynamic> imagePaths;

  Business({
    required this.id,
    required this.name,
    required this.municipal,
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
    required this.facebookPage,
    required this.website,
    required this.eventDate,
    required this.openingHours,
    required this.closingHours,
    required this.prices,
    required this.imagePaths,
  });

  /// Converts the `Business` object to a `Map` representation.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'businessType': businessType,
      'municipal':municipal,
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
      'facebookPage': facebookPage,
      'website': website,
      'eventDate': eventDate,
      'openingHours': openingHours,
      'closingHours':closingHours,
      'prices': prices,
      'imagePaths': imagePaths,
    };
  }

  /// Creates a `Business` object from a `Map`.
  factory Business.fromMap(Map<String, dynamic> map) {
    return Business(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      municipal:map['municipal'],
      businessType: map['businessType'] ?? '',
      category: map['category'] ?? '',
      review: map['review'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      services: map['services'] ?? '',
      addedValue: map['addedValue'] ?? '',
      opinions: map['opinions'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      promotions: map['promotions'] ?? '',
      locationLink: map['locationLink'] ?? '',
      facebookPage: map['facebookPage'] ?? '',
      website: map['website'] ?? '',
      eventDate: map['eventDate'] ?? '',
      openingHours: map['openingHours'] ?? '',
      closingHours: map['closingHours']??'',
      prices: map['prices'] ?? '',
      imagePaths: map['imagePaths'] ?? '',
    );
  }

  /// Creates a copy of the `Business` object with optional modifications.
  Business copyWith({
    String? id,
    String? name,
    String? businessType,
    String? category,
    String? review,
    String? phone,
    String? address,
    String? services,
    String? addedValue,
    String? municipal,
    String? opinions,
    String? whatsapp,
    String? promotions,
    String? locationLink,
    String? facebookPage,
    String? website,
    String? eventDate,
    String? openingHours,
    String? closingHours,
    String? prices,
    List<dynamic>? imagePaths,
  }) {
    return Business(
      id: id ?? this.id,
      municipal:municipal??this.municipal,
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
      facebookPage: facebookPage ?? this.facebookPage,
      website: website ?? this.website,
      eventDate: eventDate ?? this.eventDate,
      openingHours: openingHours ?? this.openingHours,
      closingHours: closingHours ?? this.closingHours,
      prices: prices ?? this.prices,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }
  // Convert a Business object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'businessType': businessType,
      'category': category,
      'review': review,
      'phone': phone,
      'address': address,
      'services': services,
      'addedValue': addedValue,
      'municipal': municipal,
      'opinions': opinions,
      'whatsapp': whatsapp,
      'promotions': promotions,
      'locationLink': locationLink,
      'facebookPage': facebookPage,
      'website': website,
      'eventDate': eventDate,
      'openingHours': openingHours,
      'closingHours': closingHours,
      'prices': prices,
      'imagePaths': imagePaths,
    };
  }

  // Create a Business object from a JSON map
  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String,
      name: json['name'] as String,
      businessType: json['businessType'] as String,
      category: json['category'] as String,
      review: json['review'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      services: json['services'] as String,
      addedValue: json['addedValue'] as String,
      municipal: json['municipal'] as String,
      opinions: json['opinions'] as String,
      whatsapp: json['whatsapp'] as String,
      promotions: json['promotions'] as String,
      locationLink: json['locationLink'] as String,
      facebookPage: json['facebookPage'] as String,
      website: json['website'] as String,
      eventDate: json['eventDate'] as String,
      openingHours: json['openingHours'] as String,
      closingHours: json['closingHours'] as String,
      prices: json['prices'] as String,
      imagePaths: json['imagePaths'] as List<dynamic>,
    );
  }  
   /// Serialize to query parameters
  
  /// Deserialize from query parameters
  factory Business.fromQueryParameters(Map<String, String> params) {
    return Business(
      id: params['id'] ?? '',
      name: params['name'] ?? '',
      municipal: params['municipal'] ?? '',
      businessType: params['businessType'] ?? '',
      category: params['category'] ?? '',
      review: params['review']??'',
      phone: params['phone'] ?? '',
      address: params['address'] ?? '',
      services: params['services'] ?? '',
      addedValue: params['addedValue'] ?? '',
      opinions: params['opinion']??'',
      whatsapp: params['whatsapp'] ?? '',
      promotions: params['promotions'] ?? '',
      locationLink: params['locationLink'] ?? '',
      facebookPage: params['facebookPage'] ?? '',
      website: params['website'] ?? '',
      eventDate: params['eventDate'] ?? '',
      openingHours: params['openingHours'] ?? '',
      closingHours: params['closingHours'] ?? '',
      prices: params['prices'] ?? '',
      imagePaths: (params['imagePaths'] ?? '').split(','),
    );
  }
}

extension BusinessToQueryParameters on Business {
  String toQueryParameters() {
    return Uri(
      queryParameters: {
        'id': id,
        'name': name,
        'municipal': municipal,
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
        'facebookPage': facebookPage,
        'website': website,
        'eventDate': eventDate,
        'openingHours': openingHours,
        'closingHours': closingHours,
        'prices': prices,
        'imagePaths': imagePaths.join(','),
      },
    ).query; // returns the query string
  }
}
