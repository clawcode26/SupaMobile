import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scaffold_key_provider.g.dart';

@riverpod
GlobalKey<ScaffoldState> rootScaffoldKey(Ref ref) {
  return GlobalKey<ScaffoldState>();
}

