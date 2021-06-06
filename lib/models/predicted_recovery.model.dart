class PredictedRecovery {
  int id;
  int createdDt;
  String createdBy;
  int recoveryDt;
  int partId;
  PredictedRecovery(
      this.createdBy, this.createdDt, this.id, this.partId, this.recoveryDt);

  PredictedRecovery.fromJson(dynamic data)
      : this(
          data["created_by"],
          data["created_dt"],
          data["id"],
          data["part_id"],
          data["recovery_dt"],
        );
}
