// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:dotenv/dotenv.dart';

final env = DotEnv(includePlatformEnvironment: true)..load(['../.env']);

const String nameService = 'POSTS';

String secretKey() {
  if (env['SECRET_KEY'] == null) {
    return Platform.environment['SECRET_KEY'] ?? 'secret';
  } else {
    return env['SECRET_KEY']!;
  }
}

int servicePort() {
  if (env['${nameService}_PORT'] == null) {
    return int.parse(
      Platform.environment['${nameService}_PORT'] ?? '2004',
    );
  } else {
    return int.parse(env['${nameService}_PORT']!);
  }
}

String serviceHost() {
  if (env['${nameService}_HOST'] == null) {
    return Platform.environment['${nameService}_HOST'] ?? '0.0.0.0';
  } else {
    return env['${nameService}_HOST']!;
  }
}

int dbPort() {
  if (env['${nameService}_DATABASE_PORT'] == null) {
    return int.parse(
      Platform.environment['${nameService}_DATABASE_PORT'] ?? '2044',
    );
  } else {
    return int.parse(env['${nameService}_DATABASE_PORT']!);
  }
}

String dbHost() {
  if (env['${nameService}_DATABASE_HOST'] == null) {
    return Platform.environment['${nameService}_DATABASE_HOST'] ?? '0.0.0.0';
  } else {
    return env['${nameService}_DATABASE_HOST']!;
  }
}

String dbName() {
  if (env['${nameService}_DATABASE_NAME'] == null) {
    return Platform.environment['${nameService}_DATABASE_NAME'] ??
        'textly_posts';
  } else {
    return env['${nameService}_DATABASE_NAME']!;
  }
}

String dbUsername() {
  if (env['${nameService}_DATABASE_USERNAME'] == null) {
    return Platform.environment['${nameService}_DATABASE_USERNAME'] ?? 'admin';
  } else {
    return env['${nameService}_DATABASE_USERNAME']!;
  }
}

String dbPassword() {
  if (env['${nameService}_DATABASE_PASSWORD'] == null) {
    return Platform.environment['${nameService}_DATABASE_PASSWORD'] ?? 'pass';
  } else {
    return env['${nameService}_DATABASE_PASSWORD']!;
  }
}
