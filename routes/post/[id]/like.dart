import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:logger/logger.dart';
import 'package:textly_core/textly_core.dart';
import 'package:textly_posts/models/textly_response.dart';
import 'package:textly_posts/models/user_id_model.dart';

FutureOr<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.post:
      return _post(context, id);
    case HttpMethod.delete:
      return _delete(context, id);
    case HttpMethod.put:
    case HttpMethod.head:
    case HttpMethod.get:
    case HttpMethod.options:
    case HttpMethod.patch:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

FutureOr<Response> _post(RequestContext context, String id) async {
  final postRepository = context.read<PostRepository>();

  final userId = context.read<UserId>().userId ?? -1;
  final postId = int.tryParse(id);

  final uuid = context.read<String>();
  final logger = context.read<Logger>();
  if (postId == null) {
    return TextlyResponse.needMoreData(
      uuid: uuid,
      type: TypeNeedData.param,
      nameData: '[id]',
    );
  }

  try {
    logger.d('$uuid: Add like to post, userId: $userId, postId:$id');
    final post =
        await postRepository.addLikeToPost(postId: postId, userId: userId);
    logger.d('$uuid: Success add like to post, userId: $userId, postId:$id');
    return TextlyResponse.success(
      uuid: uuid,
      message: 'Post has been liked successfully, userId: $userId',
      data: {
        'post': post.toJson(),
      },
    );
  } catch (e) {
    logger.d(
      '$uuid: Error add like to post, userId: $userId, postId:$id, error: $e',
    );
    return TextlyResponse.error(
      uuid: uuid,
      statusCode: 500,
      message: 'Error add like to post ',
      error: '$e',
      errorCode: 0,
    );
  }
}

FutureOr<Response> _delete(RequestContext context, String id) async {
  final postRepository = context.read<PostRepository>();

  final userId = context.read<UserId>().userId ?? -1;
  final postId = int.tryParse(id);
  final uuid = context.read<String>();
  final logger = context.read<Logger>();
  if (postId == null) {
    return TextlyResponse.needMoreData(
      uuid: uuid,
      type: TypeNeedData.param,
      nameData: '[id]',
    );
  }

  try {
    logger.d('$uuid: Delete like to post, userId: $userId, postId:$id');
    final post =
        await postRepository.deleteLikeFromPost(postId: postId, userId: userId);
    logger
        .d('$uuid: Success delete like from post, userId: $userId, postId:$id');
    return TextlyResponse.success(
      uuid: uuid,
      message: 'Post has been unLiked successfully, userId: $userId',
      data: {
        'post': post.toJson(),
      },
    );
  } catch (e) {
    logger.d(
      '''$uuid: Error delete like from post, userId: $userId, postId:$id, error: $e''',
    );
    return TextlyResponse.error(
      uuid: uuid,
      statusCode: 500,
      message: 'Error delete like to post ',
      error: '$e',
      errorCode: 0,
    );
  }
}
