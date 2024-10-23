// voice_search_plugin/lib/voice_search_plugin.dart
import 'package:flutter/material.dart';

// 플러그인의 메인 클래스
class VoiceSearchPlugin {
  static const MethodChannel _channel = MethodChannel('voice_search_plugin');

  static Future<String?> getPlatformVersion() async {
    final version = await _channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

// 음성 인식 상태를 관리하는 프로바이더
class VoiceSearchProvider extends ChangeNotifier {
  bool _isListening = false;
  String _userMessage = '';
  final List<String> _messageHistory = [];

  bool get isListening => _isListening;
  String get userMessage => _userMessage;
  List<String> get messageHistory => _messageHistory;

  void startListening() {
    _isListening = true;
    _userMessage = '음성을 인식하고 있습니다...';
    notifyListeners();
  }

  void stopListening() {
    _isListening = false;
    if (_userMessage.contains('음성을 인식')) {
      _userMessage = '';
    }
    notifyListeners();
  }

  void setMessage(String message) {
    _userMessage = message;
    notifyListeners();
  }

  void addToHistory() {
    if (_userMessage.isNotEmpty && !_userMessage.contains('음성을 인식')) {
      _messageHistory.insert(0, _userMessage);
      _userMessage = '';
      notifyListeners();
    }
  }
}

// 위젯 설정을 위한 설정 클래스
class VoiceSearchConfig {
  final Color primaryColor;
  final Color backgroundColor;
  final double borderRadius;
  final TextStyle? messageStyle;
  final TextStyle? placeholderStyle;

  const VoiceSearchConfig({
    this.primaryColor = Colors.blue,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.borderRadius = 24.0,
    this.messageStyle,
    this.placeholderStyle,
  });
}

// 메인 위젯
class CompactVoiceSearch extends StatelessWidget {
  final VoiceSearchConfig? config;
  final Function(String)? onMessageSubmitted;
  final Function(bool)? onListeningStateChanged;

  const CompactVoiceSearch({
    Key? key,
    this.config,
    this.onMessageSubmitted,
    this.onListeningStateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cfg = config ?? const VoiceSearchConfig();
    return ChangeNotifierProvider(
      create: (_) => VoiceSearchProvider(),
      child: _VoiceSearchWidget(
        config: cfg,
        onMessageSubmitted: onMessageSubmitted,
        onListeningStateChanged: onListeningStateChanged,
      ),
    );
  }
}

// 내부 구현 위젯
class _VoiceSearchWidget extends StatelessWidget {
  final VoiceSearchConfig config;
  final Function(String)? onMessageSubmitted;
  final Function(bool)? onListeningStateChanged;

  const _VoiceSearchWidget({
    Key? key,
    required this.config,
    this.onMessageSubmitted,
    this.onListeningStateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceSearchProvider>(
      builder: (context, provider, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: config.backgroundColor,
                borderRadius: BorderRadius.circular(config.borderRadius),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      provider.isListening ? Icons.mic : Icons.mic_none,
                      color: provider.isListening ? Colors.red : config.primaryColor,
                    ),
                    onPressed: () {
                      if (provider.isListening) {
                        provider.stopListening();
                      } else {
                        provider.startListening();
                      }
                      onListeningStateChanged?.call(provider.isListening);
                    },
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        if (provider.isListening)
                          Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(right: 8),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                config.primaryColor,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            provider.userMessage.isEmpty
                                ? '음성 명령을 입력하세요'
                                : provider.userMessage,
                            style: provider.userMessage.isEmpty
                                ? config.placeholderStyle
                                : config.messageStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: config.primaryColor),
                    onPressed: provider.userMessage.isEmpty
                        ? null
                        : () {
                            onMessageSubmitted?.call(provider.userMessage);
                            provider.addToHistory();
                          },
                  ),
                ],
              ),
            ),
            if (provider.messageHistory.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  reverse: true,
                  itemCount: provider.messageHistory.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.history, size: 18),
                      title: Text(
                        provider.messageHistory[index],
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.refresh, size: 18),
                        onPressed: () {
                          provider.setMessage(provider.messageHistory[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}