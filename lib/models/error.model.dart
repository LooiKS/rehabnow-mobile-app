class FormError {
  String message;
  String code;

  FormError(this.message, this.code);

  FormError.fromJson(dynamic error) : this(error["message"], error["code"]);
}
