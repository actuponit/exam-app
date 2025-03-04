import 'package:hive/hive.dart';
import '../../domain/entities/subject.dart';
import '../../../../core/constants/hive_constants.dart';

@HiveType(typeId: HiveTypeIds.subject)
class SubjectModel extends Subject {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String name;

  @HiveField(2)
  @override
  final String iconPath;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.iconPath,
  }) : super(
          id: id,
          name: name,
          iconPath: iconPath,
        );

  factory SubjectModel.fromEntity(Subject subject) {
    return SubjectModel(
      id: subject.id,
      name: subject.name,
      iconPath: subject.iconPath,
    );
  }
} 