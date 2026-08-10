// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_order_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VoiceOrderController)
final voiceOrderControllerProvider = VoiceOrderControllerProvider._();

final class VoiceOrderControllerProvider
    extends $NotifierProvider<VoiceOrderController, VoiceOrderState> {
  VoiceOrderControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'voiceOrderControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$voiceOrderControllerHash();

  @$internal
  @override
  VoiceOrderController create() => VoiceOrderController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoiceOrderState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoiceOrderState>(value),
    );
  }
}

String _$voiceOrderControllerHash() =>
    r'ff3b54f5a3ba122f5cae095027e82981bec1d622';

abstract class _$VoiceOrderController extends $Notifier<VoiceOrderState> {
  VoiceOrderState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VoiceOrderState, VoiceOrderState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<VoiceOrderState, VoiceOrderState>,
        VoiceOrderState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
