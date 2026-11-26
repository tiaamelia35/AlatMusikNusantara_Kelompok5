class InstrumentModel {
  final String id;
  final String name;
  final String category; // e.g. IDIOFON (GETAR/GOYANG)
  final String organologyType; // Pukul, Petik, Tiup
  final String province;
  final String description;
  final String imageUrl;
  final String audioUrl;
  final String audioTitle;
  final String audioSubtitle;
  final String duration;
  final int viewCount;
  final bool isPopular;
  bool isFavorite;

  InstrumentModel({
    required this.id,
    required this.name,
    required this.category,
    required this.organologyType,
    required this.province,
    required this.description,
    required this.imageUrl,
    this.audioUrl = '',
    this.audioTitle = '',
    this.audioSubtitle = '',
    this.duration = '0:30',
    this.viewCount = 120,
    this.isPopular = false,
    this.isFavorite = false,
  });
}

class OrganologyCategory {
  final String title;
  final String subtitle;
  final String examples;
  final String iconType;
  final int colorHex;
  final int bgHex;

  const OrganologyCategory({
    required this.title,
    required this.subtitle,
    required this.examples,
    required this.iconType,
    required this.colorHex,
    required this.bgHex,
  });
}
