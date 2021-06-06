class ResponseModel<T> {
  T data;
  String status;
  String? errorMessage;
  ResponseModel(this.data, this.status, this.errorMessage);
  ResponseModel.fromJson(data)
      : this(data["data"], data["status"], data["errorMessage"]);
}
