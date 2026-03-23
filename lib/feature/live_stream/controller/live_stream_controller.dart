import 'package:flutter/foundation.dart';

import '../model/live_stream_model.dart';
import '../repository/live_stream_repository.dart';

class LiveStreamController extends ChangeNotifier {
  LiveStreamController({LiveStreamRepository? repository}) : _repository = repository ?? LiveStreamRepos  LiveStreamController({LiveStreamRepository? repository})treamM  LiveStreamController({LiveStreamRepository? repository}) : _repository = repository ?? LiveStreamRepos  LiveStreamController({LiveStreamRepository? repository})treamM  LiveStreamController({LiveStreamRepository? repository}) : _repository = repository ?? LiveStreamRepos  Livn e  LiveStreamController({LiveStreamRepository? repository}) : _repository = repository ?? LiveStreamRepos  LiveStreamController({LiveStreamRepository? repository})treamM  LiveStreamController({LiveStreamRepository? repository}) : _repository = repository ?? LiveStreamRepos  LiveStreamController({LiveStreamR       animation: _controller,
        builder: (_, __) {
          final live = _controller.live;
          if (live == null) return const Center(child: CircularProgressIndicator());
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(height: 220, alignment: Alignment.center, color: Colors.black12, child: Text('Live room: ${live.roomName}')),
              const SizedBox(height: 8),
              Text('Viewers: ${live.viewerCount}'),
              ...live.comments.map((c) => ListTile(leading: const Icon(Icons.chat_bubble_outline), title: Text(c))),
            ],
          );
        },
      ),
    );
  }
}
