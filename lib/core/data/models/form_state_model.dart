class FormStateModel {
  const FormStateModel({
    this.isSubmitting = false,
    this.isValid = true,
    this.errorMessage,
    this.successMessage,
  });

  final bool isSubmitting;
  final bool isValid;
  final String? errorMessage;
  final String? successMessage;

  FormStateModel copyWith({
    bool? isSubmitting,
    bool? isValid,
    String? errorMessage,
    String? successMessage,
  }) {
    return FormStateModel(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
