enum SplashStatus {
  idle,
  bootstrapping,
  ready,
}

class SplashStateModel {
  const SplashStateModel({this.status = SplashStatus.idle});

  final SplashStatus status;

  SplashStateModel copyWith({SplashStatus? status}) {
    return SplashStateModel(status: status ?? this.status);
  }
}
