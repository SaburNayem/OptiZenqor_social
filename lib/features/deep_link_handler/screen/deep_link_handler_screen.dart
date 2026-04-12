import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controller/deep_link_handler_controller.dart';

class DeepLinkHandlerScreen extends StatelessWidget {
  const DeepLinkHandlerScreen({super.key});
  static const String _initialLink = 'https://optizenqor.app/post/p1';

  @override
  Widget build(BuildContext context) {
    final controller = DeepLinkHandlerController();
    return BlocProvider<_DeepLinkHandlerCubit>(
      create: (_) => _DeepLinkHandlerCubit(),
      child: BlocBuilder<_DeepLinkHandlerCubit, _DeepLinkHandlerState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Deep Link Handler')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(controller.explain('/post/p1')),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: state.link,
                  onChanged: context.read<_DeepLinkHandlerCubit>().updateLink,
                  decoration: const InputDecoration(
                    labelText: 'Deep link URL',
                    hintText: 'https://optizenqor.app/profile/u1',
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () async {
                    final resolved = await controller.resolve(state.link);
                    if (!context.mounted) return;
                    context.read<_DeepLinkHandlerCubit>().updateResolved(
                      resolved ?? 'Unable to resolve route',
                    );
                  },
                  child: const Text('Resolve link'),
                ),
                const SizedBox(height: 8),
                Text('Resolved route: ${state.resolved}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DeepLinkHandlerState {
  const _DeepLinkHandlerState({
    this.link = DeepLinkHandlerScreen._initialLink,
    this.resolved = 'No route resolved yet',
  });

  final String link;
  final String resolved;

  _DeepLinkHandlerState copyWith({String? link, String? resolved}) {
    return _DeepLinkHandlerState(
      link: link ?? this.link,
      resolved: resolved ?? this.resolved,
    );
  }
}

class _DeepLinkHandlerCubit extends Cubit<_DeepLinkHandlerState> {
  _DeepLinkHandlerCubit() : super(const _DeepLinkHandlerState());

  void updateLink(String value) => emit(state.copyWith(link: value));

  void updateResolved(String value) => emit(state.copyWith(resolved: value));
}
