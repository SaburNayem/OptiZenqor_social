import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    if (kDebugMode) {
      debugPrint(
        '[BlocCreate] ${bloc.runtimeType} state=${_describeValue(bloc.state)}',
      );
    }
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    if (kDebugMode) {
      debugPrint(
        '[BlocClose] ${bloc.runtimeType} state=${_describeValue(bloc.state)}',
      );
    }
    super.onClose(bloc);
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) {
      debugPrint(
        '[BlocEvent] ${bloc.runtimeType} event=${_describeValue(event)}',
      );
    }
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      debugPrint(
        '[BlocChange] ${bloc.runtimeType} '
        'current=${_describeValue(change.currentState)} '
        'next=${_describeValue(change.nextState)}',
      );
    }
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      debugPrint(
        '[BlocTransition] ${bloc.runtimeType} '
        'event=${_describeValue(transition.event)} '
        'current=${_describeValue(transition.currentState)} '
        'next=${_describeValue(transition.nextState)}',
      );
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[BlocError] ${bloc.runtimeType} $error');
      debugPrint('$stackTrace');
    }
    super.onError(bloc, error, stackTrace);
  }

  String _describeValue(Object? value) {
    if (value == null) {
      return 'null';
    }

    final String text = value.toString();
    if (text.startsWith('Instance of ')) {
      return value.runtimeType.toString();
    }
    return text;
  }
}
