// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stt_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SpeechController)
final speechControllerProvider = SpeechControllerProvider._();

final class SpeechControllerProvider
    extends $NotifierProvider<SpeechController, SpeechState> {
  SpeechControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'speechControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$speechControllerHash();

  @$internal
  @override
  SpeechController create() => SpeechController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpeechState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpeechState>(value),
    );
  }
}

String _$speechControllerHash() => r'4453e57a6a636df29bd7345bb8997d35b5285ebe';

abstract class _$SpeechController extends $Notifier<SpeechState> {
  SpeechState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SpeechState, SpeechState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SpeechState, SpeechState>, SpeechState, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
