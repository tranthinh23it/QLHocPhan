class GiangVien {
  final String? idgv;
  final String fullname;
  final String? image;
  final int sumClass;

  GiangVien({
    this.idgv,
    required this.fullname,
    this.image,
    this.sumClass = 0,
  });

  // Convert GiangVien to JSON
  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'image': image ?? '',
      'sumClass': sumClass,
    };
  }

  // Create GiangVien from JSON
  factory GiangVien.fromJson(Map<String, dynamic> json) {
    return GiangVien(
      idgv: json['idgv'] ?? '',
      fullname: json['fullname'] ?? '',
      image: json['image'] ?? '',
      sumClass: json['sumClass'] ?? 0,
    );
  }

  // Copy with method
  GiangVien copyWith({
    String? idgv,
    String? fullname,
    String? image,
    int? sumClass,
  }) {
    return GiangVien(
      idgv: idgv ?? this.idgv,
      fullname: fullname ?? this.fullname,
      image: image ?? this.image,
      sumClass: sumClass ?? this.sumClass,
    );
  }
}
