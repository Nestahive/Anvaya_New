class ProduceBatch {
  final int? id;
  final String batchId;
  final String title;
  final String category;
  final String quantity;
  final String price;
  final String date;
  final String status;
  final String? condition;
  final double? confidence;
  final List<String> visibleIssues;
  final String? location;
  final String? description;
  final String? type;

  ProduceBatch({
    this.id,
    required this.batchId,
    required this.title,
    required this.category,
    required this.quantity,
    required this.price,
    required this.date,
    required this.status,
    this.condition,
    this.confidence,
    this.visibleIssues = const [],
    this.location,
    this.description,
    this.type,
  });

  bool get isVerified => status.toUpperCase() == 'VERIFIED';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isRejected => status.toUpperCase() == 'REJECTED';

  factory ProduceBatch.fromJson(Map<String, dynamic> json) {
    return ProduceBatch(
      id: json['id'] as int?,
      batchId: json['batch_id'] as String? ?? 'Batch #AG-0000',
      title: json['title'] as String? ?? 'Produce Batch',
      category: json['category'] as String? ?? 'Vegetables',
      quantity: json['quantity'] as String? ?? '100 kg',
      price: json['price'] as String? ?? r'$4.50',
      date: json['date'] as String? ?? '',
      status: json['status'] as String? ?? 'VERIFIED',
      condition: json['condition'] as String?,
      confidence: json['confidence'] != null ? (json['confidence'] as num).toDouble() : null,
      visibleIssues: (json['visible_issues'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      location: json['location'] as String?,
      description: json['description'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'batch_id': batchId,
      'title': title,
      'category': category,
      'quantity': quantity,
      'price': price,
      'date': date,
      'status': status,
      'condition': condition,
      'confidence': confidence,
      'visible_issues': visibleIssues,
      'location': location,
      'description': description,
      'type': type,
    };
  }
}
