class Target {
  int? id;
  int? createdDt;
  String? createdBy;
  int? frequency;
  int? oscillationNum;
  double? timeTaken;
  int? partId;

  Target(this.id, this.createdDt, this.createdBy, this.frequency,
      this.oscillationNum, this.timeTaken, this.partId);

  Target.fromJson(dynamic data)
      : this(
          data["id"],
          data["created_dt"],
          data["created_by"],
          data["frequency"],
          data["oscillation_num"],
          data["time_taken"],
          data["part_id"],
        );
}
