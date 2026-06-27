// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_users_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authUsers)
final authUsersProvider = AuthUsersFamily._();

final class AuthUsersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>
        >
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  AuthUsersProvider._({
    required AuthUsersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'authUsersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$authUsersHash();

  @override
  String toString() {
    return r'authUsersProvider'
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
    return authUsers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AuthUsersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$authUsersHash() => r'8e3b1d203b6c0a7bcb0abcb823632deb4c20c966';

final class AuthUsersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<dynamic>>, String> {
  AuthUsersFamily._()
    : super(
        retry: null,
        name: r'authUsersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AuthUsersProvider call(String projectRef) =>
      AuthUsersProvider._(argument: projectRef, from: this);

  @override
  String toString() => r'authUsersProvider';
}
