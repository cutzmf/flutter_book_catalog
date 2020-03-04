import 'package:meta/meta.dart';

class Book {
  final int id;
  final String title;
  final String author;
  final String shortDescription;
  final int price;
  final String imageUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Book &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          author == other.author &&
          shortDescription == other.shortDescription &&
          price == other.price &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      author.hashCode ^
      shortDescription.hashCode ^
      price.hashCode ^
      imageUrl.hashCode;

  const Book({
    @required this.id,
    @required this.title,
    @required this.author,
    @required this.shortDescription,
    @required this.price,
    @required this.imageUrl,
  });
}
