import 'package:hive/hive.dart';
import '../../domain/entities/subject.dart';
import '../../../../core/constants/hive_constants.dart';

part 'subject_model.g.dart';

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
  final String iconName;

  @HiveField(3)
  @override
  final double progress;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.iconName,
    this.progress = 0.0,
  }) : super(
          id: id,
          name: name,
          iconName: iconName,
          progress: progress,
        );

  factory SubjectModel.fromEntity(Subject subject) {
    return SubjectModel(
      id: subject.id,
      name: subject.name,
      iconName: subject.iconName,
      progress: subject.progress,
    );
  }
}
