class Case {
  String? name;
  String? description;
  String? status;
  String? patientId;
  String? createdBy;
  int createdDt;
  int id;

  Case(this.name, this.description, this.status, this.patientId, this.createdBy,
      this.createdDt, this.id);

  Case.fromJson(dynamic data)
      : this(
          data["name"],
          data["description"],
          data["status"],
          data["patient_id"],
          data["created_by"],
          data["created_dt"],
          data["id"],
        );
}
