import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:rxdart/rxdart.dart';

enum AnswerLength { same, shorten, expand }

class GPTRepository {
  final _gptController = ReplaySubject<String>();
  late OpenAI openAI;

  Stream<String> get gptResponseStream => _gptController.asBroadcastStream();
  void addToStream(String text) => _gptController.add(text);

  Future<void> sendRequest({
    required String apiKey,
    required String inputText,
    required AnswerLength answerLength,
    required List<String> tones,
  }) async {
    openAI = OpenAI.instance.build(
      token: apiKey,
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 10),
        connectTimeout: const Duration(seconds: 10),
      ),
      enableLog: true,
    );

    const instruction1 =
        'Please ignore all previous instructions. You are an expert copywriter who creates content briefs. Please write only in the English language.';
    final instruction2 = _handleTones(tones);
    final instruction3 = _handleLength(answerLength);

    final instruction = '$instruction1\n\n$instruction2\n\n$instruction3';

    final request = CompleteText(
      prompt: '$instruction\n\n$inputText',
      model: TextDavinci3Model(),
    );
    final response = await openAI.onCompletion(request: request);

    String text = response!.choices.last.text;
    // remove leading new line chars
    while (text.startsWith('\n')) {
      text = text.substring(1);
    }

    addToStream(text);
  }

  String _handleLength(AnswerLength answerLength) {
    switch (answerLength) {
      case AnswerLength.shorten:
        return 'The rephrased message should be shorter than the original.';
      case AnswerLength.expand:
        return 'The rephrased message should be a little longer than the original.';
      case AnswerLength.same:
        return 'The rephrased message should have the same length as the original.';
    }
  }

  String _handleTones(List<String> tones) {
    if (tones.isNotEmpty) {
      return 'Rephrase the paragraph below in a more ${tones.join(' and more ')} tone, without changing the core message.';
    }
    return 'Rephrase the paragraph below, without changing the core message.';
  }
}
