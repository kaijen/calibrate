import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_key_service.dart';
import '../../../core/services/openrouter_service.dart';
import '../../../core/services/prompt_template_service.dart';
import '../../../core/utils/import_parser.dart';

enum AiGeneratorPhase { form, loading, preview, imported }

class AiGeneratorState {
  final AiGeneratorPhase phase;
  final PromptTemplate? selectedTemplate;
  final int count;
  final ImportFile? result;
  final String? errorMessage;

  const AiGeneratorState({
    this.phase = AiGeneratorPhase.form,
    this.selectedTemplate,
    this.count = 10,
    this.result,
    this.errorMessage,
  });

  AiGeneratorState copyWith({
    AiGeneratorPhase? phase,
    PromptTemplate? selectedTemplate,
    int? count,
    ImportFile? result,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return AiGeneratorState(
      phase: phase ?? this.phase,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      count: count ?? this.count,
      result: clearResult ? null : (result ?? this.result),
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AiGeneratorNotifier extends StateNotifier<AiGeneratorState> {
  AiGeneratorNotifier() : super(const AiGeneratorState());

  void selectTemplate(PromptTemplate template) {
    state = state.copyWith(selectedTemplate: template, clearError: true);
  }

  void setCount(int count) {
    state = state.copyWith(count: count);
  }

  void reset() {
    state = AiGeneratorState(
      selectedTemplate: state.selectedTemplate,
      count: state.count,
    );
  }

  Future<void> generate(String topic) async {
    if (state.selectedTemplate == null) return;
    if (topic.trim().isEmpty) return;

    state = state.copyWith(
      phase: AiGeneratorPhase.loading,
      clearError: true,
      clearResult: true,
    );

    try {
      final apiKey = await ApiKeyService.getKey();
      if (apiKey == null || apiKey.isEmpty) {
        state = state.copyWith(
          phase: AiGeneratorPhase.form,
          errorMessage: 'Kein API-Key gesetzt. Bitte in Einstellungen hinterlegen.',
        );
        return;
      }

      final model = await ApiKeyService.getModel() ??
          'google/gemma-3-12b-it:free';

      final prompt = state.selectedTemplate!.body
          .replaceAll('{topic}', topic.trim())
          .replaceAll('{count}', '${state.count}');

      final responseText = await OpenRouterService.generate(
        apiKey: apiKey,
        model: model,
        prompt: prompt,
      );

      final importFile = ImportParser.parseAutoDetect(responseText);

      state = state.copyWith(
        phase: AiGeneratorPhase.preview,
        result: importFile,
      );
    } on OpenRouterException catch (e) {
      String message;
      if (e.statusCode == 401) {
        message = 'API-Key ungültig – Einstellungen prüfen.';
      } else if (e.statusCode == 402) {
        message = 'OpenRouter-Guthaben aufgebraucht.';
      } else {
        message = 'API-Fehler: ${e.message}';
      }
      state = state.copyWith(
        phase: AiGeneratorPhase.form,
        errorMessage: message,
      );
    } on ImportParseException catch (_) {
      state = state.copyWith(
        phase: AiGeneratorPhase.form,
        errorMessage:
            'Antwort kein gültiges Kailibrate-JSON – '
            'anderes Modell oder Template versuchen.',
      );
    } catch (e) {
      state = state.copyWith(
        phase: AiGeneratorPhase.form,
        errorMessage: 'Unbekannter Fehler: $e',
      );
    }
  }

  void setImported() {
    state = state.copyWith(phase: AiGeneratorPhase.imported);
  }
}

final aiGeneratorProvider = StateNotifierProvider.autoDispose<
    AiGeneratorNotifier, AiGeneratorState>(
  (_) => AiGeneratorNotifier(),
);

final templatesProvider =
    FutureProvider.autoDispose<List<PromptTemplate>>((ref) {
  return PromptTemplateService.loadAll();
});
