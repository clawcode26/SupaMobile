// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storageBuckets)
final storageBucketsProvider = StorageBucketsFamily._();

final class StorageBucketsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>
        >
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  StorageBucketsProvider._({
    required StorageBucketsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'storageBucketsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$storageBucketsHash();

  @override
  String toString() {
    return r'storageBucketsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<dynamic>> create(Ref ref) {
    final argument = this.argument as String;
    return storageBuckets(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StorageBucketsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$storageBucketsHash() => r'768307f5bbec5e215af2afe00db2894818b15980';

final class StorageBucketsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<dynamic>>, String> {
  StorageBucketsFamily._()
    : super(
        retry: null,
        name: r'storageBucketsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StorageBucketsProvider call(String projectRef) =>
      StorageBucketsProvider._(argument: projectRef, from: this);

  @override
  String toString() => r'storageBucketsProvider';
}

@ProviderFor(storageObjects)
final storageObjectsProvider = StorageObjectsFamily._();

final class StorageObjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>
        >
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  StorageObjectsProvider._({
    required StorageObjectsFamily super.from,
    required ({String projectRef, String bucketId, String path}) super.argument,
  }) : super(
         retry: null,
         name: r'storageObjectsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$storageObjectsHash();

  @override
  String toString() {
    return r'storageObjectsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<dynamic>> create(Ref ref) {
    final argument =
        this.argument as ({String projectRef, String bucketId, String path});
    return storageObjects(
      ref,
      projectRef: argument.projectRef,
      bucketId: argument.bucketId,
      path: argument.path,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StorageObjectsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$storageObjectsHash() => r'fde1df0b0cae3551a50470e5bd4f7375163a7f80';

final class StorageObjectsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<dynamic>>,
          ({String projectRef, String bucketId, String path})
        > {
  StorageObjectsFamily._()
    : super(
        retry: null,
        name: r'storageObjectsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StorageObjectsProvider call({
    required String projectRef,
    required String bucketId,
    String path = '',
  }) => StorageObjectsProvider._(
    argument: (projectRef: projectRef, bucketId: bucketId, path: path),
    from: this,
  );

  @override
  String toString() => r'storageObjectsProvider';
}
