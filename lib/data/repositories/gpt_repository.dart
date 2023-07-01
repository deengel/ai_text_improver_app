import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:chat_gpt_sdk/src/model/edits/enum/edit_model.dart';
import 'package:rxdart/rxdart.dart';

class GPTRepository {
  final _gptController = ReplaySubject<String>();
  late OpenAI openAI;

  Stream<String> get gptResponseStream => _gptController.asBroadcastStream();
  void addToStream(String text) => _gptController.add(text);

  Future<void> sendRequest({
    required String apiKey,
    required String inputText,
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

    final instruction = 'Paraphrase with ${tones.join(", ")}';

    final request = EditRequest(
      model: CodeEditModel(),
      input: inputText,
      instruction: instruction,
    );

    final response = await openAI.editor.prompt(request);
    addToStream(response.choices.last.text);
  }
}
