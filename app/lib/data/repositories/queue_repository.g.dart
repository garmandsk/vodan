// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(queueRepository)
final queueRepositoryProvider = QueueRepositoryProvider._();

final class QueueRepositoryProvider extends $FunctionalProvider<QueueRepository,
    QueueRepository, QueueRepository> with $Provider<QueueRepository> {
  QueueRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'queueRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$queueRepositoryHash();

  @$internal
  @override
  $ProviderElement<QueueRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  QueueRepository create(Ref ref) {
    return queueRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QueueRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QueueRepository>(value),
    );
  }
}

String _$queueRepositoryHash() => r'c99565152c54c6971c2c857b25bff475952dfca4';
