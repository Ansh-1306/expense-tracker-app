class Account {
  final int? id;
  final String userId;
  final String name;
  final double balance;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final bool isSynced;

  Account({
    this.id,
    required this.userId,
    required this.name,
    this.balance = 0.0,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    this.isSynced = false,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()),
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      isDeleted: json['is_deleted'] == true || json['is_deleted'] == 1,
      isSynced: json['is_synced'] == true || json['is_synced'] == 1,
    );
  }

  Map<String, dynamic> toJson({bool forInsert = false}) {
    final map = <String, dynamic>{
      'user_id': userId,
      'name': name,
      'balance': balance,
      'is_deleted': isDeleted,
      'is_synced': isSynced,
    };

    if (!forInsert && id != null) {
      map['id'] = id;
    }

    return map;
  }

  Account copyWith({
    int? id,
    String? userId,
    String? name,
    double? balance,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSynced,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
