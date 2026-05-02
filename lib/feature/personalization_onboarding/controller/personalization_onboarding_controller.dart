import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/interest_model.dart';
import '../service/personalization_onboarding_service.dart';

class PersonalizationOnboardingController extends ChangeNotifier {
  PersonalizationOnboardingController({
    PersonalizationOnboardingService? service,
  }) : _service = service ?? PersonalizationOnboardingService() {
    unawaited(load());
  }

  final PersonalizationOnboardingService _service;

  List<InterestModel> interests = const <InterestModel>[];
  bool isLoading = true;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .getEndpoint('personalization_onboarding');
      if (!response.isSuccess || response.data['success'] == false) {
        throw Exception(
          response.message ?? 'Unable to load personalization onboarding.',
        );
      }
      final Map<String, dynamic> payload =
          ApiPayloadReader.readMap(response.data['data']) ?? response.data;
      interests =
          ApiPayloadReader.readMapList(
                payload,
                preferredKeys: const <String>['interests', 'items'],
              )
              .map((item) {
                return InterestModel(
                  name: ApiPayloadReader.readString(item['name']),
                  selected:
                      ApiPayloadReader.readBool(item['selected']) ?? false,
                );
              })
              .where((item) => item.name.isNotEmpty)
              .toList(growable: false);
    } catch (error) {
      errorMessage = error.toString();
      interests = const <InterestModel>[];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggle(String name) async {
    final List<InterestModel> previous = interests;
    interests = interests
        .map(
          (item) => item.name == name
              ? InterestModel(name: item.name, selected: !item.selected)
              : item,
        )
        .toList(growable: false);
    errorMessage = null;
    notifyListeners();
    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .patchEndpoint('interests', payload: <String, dynamic>{'name': name});
      if (!response.isSuccess || response.data['success'] == false) {
        throw Exception(
          response.message ?? 'Unable to update personalization interest.',
        );
      }
      final Map<String, dynamic> payload =
          ApiPayloadReader.readMap(response.data['data']) ?? response.data;
      interests =
          ApiPayloadReader.readMapList(
                payload,
                preferredKeys: const <String>['interests', 'items'],
              )
              .map((item) {
                return InterestModel(
                  name: ApiPayloadReader.readString(item['name']),
                  selected:
                      ApiPayloadReader.readBool(item['selected']) ?? false,
                );
              })
              .where((item) => item.name.isNotEmpty)
              .toList(growable: false);
    } catch (error) {
      interests = previous;
      errorMessage = error.toString();
    } finally {
      notifyListeners();
    }
  }

  int get selectedCount => interests.where((item) => item.selected).length;

  bool get canContinue => selectedCount > 0;
}
