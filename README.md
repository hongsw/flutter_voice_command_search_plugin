# Voice Command and Search Plugin

A Flutter plugin that provides a compact and customizable voice search interface.

## Features

* 커스터마이징 가능한 음성 검색 UI
* 음성 인식 상태 관리
* 메시지 히스토리 기능
* 테마 지원

## Getting started

```yaml
dependencies:
  voice_search_plugin: ^0.0.1
```

## Usage

```dart
import 'package:voice_search_plugin/voice_search_plugin.dart';

CompactVoiceSearch(
  config: VoiceSearchConfig(
    primaryColor: Colors.blue,
    backgroundColor: Colors.grey[100]!,
  ),
  onMessageSubmitted: (String message) {
    print('Message submitted: $message');
  },
)
```

## Additional information

* 버그 리포트나 기능 요청은 GitHub 이슈를 이용해주세요.
* 기여하고 싶으시다면 Pull Request를 환영합니다.


## Change logs
### 0.0.1

* Initial release
* 기본 음성 검색 UI 구현
* 음성 인식 상태 관리 기능
* 메시지 히스토리 관리
* 커스터마이징 가능한 설정

