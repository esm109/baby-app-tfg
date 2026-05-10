import 'stage.dart';
import 'baby_development.dart';
import 'mother_change.dart';
import 'recommendation.dart';

class StageDetails {
  final Stage stage;
  final List<BabyDevelopment> babyDevelopment;
  final List<MotherChange> motherChanges;
  final List<Recommendation> recommendations;

  StageDetails({
    required this.stage,
    required this.babyDevelopment,
    required this.motherChanges,
    required this.recommendations,
  });

  factory StageDetails.fromJson(Map<String, dynamic> json) {
    return StageDetails(
      stage: Stage.fromJson(json['stage']),
      babyDevelopment: ((json['babyDevelopment'] ?? json['baby_development']) as List)
          .map((item) => BabyDevelopment.fromJson(item))
          .toList(),
      motherChanges: ((json['motherChanges'] ?? json['mother_changes']) as List)
          .map((item) => MotherChange.fromJson(item))
          .toList(),
      recommendations: ((json['recommendations'] ?? []) as List)
          .map((item) => Recommendation.fromJson(item))
          .toList(),
    );
  }
}