abstract class UseCase<Result, Params> {
  const UseCase();

  Future<Result> call(Params params);
}

class NoParams {
  const NoParams();
}
