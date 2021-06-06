import 'package:rehabnow_app/models/predicted_recovery.model.dart';
import 'package:rehabnow_app/models/target.model.dart';

class Part {
  String? description;
  String? name;
  int? recoveryDt;
  String? status;
  int? createdDt;
  String? createdBy;
  int? caseId;
  int? id;
  List<Target> targets;
  List<PredictedRecovery?> predictedRecoveries;

  Part(
    this.description,
    this.name,
    this.recoveryDt,
    this.status,
    this.createdDt,
    this.createdBy,
    this.caseId,
    this.id,
    this.targets,
    this.predictedRecoveries,
  );

  Part.fromJson(dynamic data)
      : this(
          data["description"],
          data["name"],
          data["recovery_dt"],
          data["status"],
          data["created_dt"],
          data["created_by"],
          data["case_id"],
          data["id"],
          (data["targets"] as List)
              .map((target) => Target.fromJson(target))
              .toList(),
          (data["predicted_recoveries"] as List)
              .map((predictedRecovery) =>
                  PredictedRecovery.fromJson(predictedRecovery))
              .toList(),
        );
}
