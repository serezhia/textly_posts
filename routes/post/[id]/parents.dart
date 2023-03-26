import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:logger/logger.dart';
import 'package:textly_core/textly_core.dart';
import 'package:textly_posts/models/textly_response.dart';
import 'package:textly_posts/models/user_id_model.dart';

FutureOr<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context, id);
    case HttpMethod.post:
    case HttpMethod.put:
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

FutureOr<Response> _get(RequestContext context, String id) async {
  final params = context.request.uri.queryParameters;

  final limit = int.tryParse(params['limit'] ?? '');

  final postRepository = context.read<PostRepository>();

  final userId = context.read<UserId>().userId;
  final postId = int.tryParse(id);
  final uuid = context.read<String>();
  final logger = context.read<Logger>();

  if (limit == null) {
    return TextlyResponse.needMoreData(
      uuid: uuid,
      type: TypeNeedData.param,
      nameData: 'limit',
    );
  }

  if (postId == null) {
    return TextlyResponse.needMoreData(
      uuid: uuid,
      type: TypeNeedData.param,
      nameData: '[id]',
    );
  }

  try {
    logger.d('$uuid: Read post parents, userId: $userId, postId: $postId');
    final chunk = await postRepository.getPostParents(
      reqUserId: userId,
      postId: postId,
      limit: limit,
    );
    logger.d('$uuid: Readed post parents, userId: $userId, postId: $postId');
    return TextlyResponse.success(
      uuid: uuid,
      message: 'Success read post parents',
      data: chunk.toJson(),
    );
  } catch (e) {
    logger
        .e('$uuid: Error read post parents, userId: $userId, postId: $postId');
    return TextlyResponse.error(
      uuid: uuid,
      statusCode: 500,
      message: 'Error read post parents',
      error: '$e',
      errorCode: 0,
    );
  }
}
