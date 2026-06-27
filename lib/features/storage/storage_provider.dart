import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/project_api.dart';
import '../../core/providers/core_providers.dart';

part 'storage_provider.g.dart';

@riverpod
Future<List<dynamic>> storageBuckets(Ref ref, String projectRef) async {
  final serviceKey = await ref.watch(serviceRoleKeyProvider(projectRef).future);
  if (serviceKey == null) throw Exception('Service role key not found');

  final api = ProjectApi(projectRef: projectRef, serviceRoleKey: serviceKey);
  return api.getStorageBuckets();
}

@riverpod
Future<List<dynamic>> storageObjects(
  Ref ref, {
  required String projectRef,
  required String bucketId,
  String path = '',
}) async {
  final serviceKey = await ref.watch(serviceRoleKeyProvider(projectRef).future);
  if (serviceKey == null) throw Exception('Service role key not found');

  final api = ProjectApi(projectRef: projectRef, serviceRoleKey: serviceKey);
  return api.getStorageObjects(bucketId, path: path);
}

