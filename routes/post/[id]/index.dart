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
    case HttpMethod.delete:
      return _delete(context, id);
    case HttpMethod.post:
    case HttpMethod.put:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

//Create Post

FutureOr<Response> _get(RequestContext context, String id) async {
  final postRepository = context.read<PostRepository>();

  final userId = context.read<UserId>().userId;
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
    logger.d('$uuid: Read post, userId: $userId, postId:$id');
    final post = await postRepository.readPost(
      postId: postId,
      reqUserId: userId,
    );

    if (post == null) {
      logger.d('$uuid: Post not found, userId: $userId, postId:$id');
      return TextlyResponse.error(
        statusCode: 500,
        errorCode: 0,
        uuid: uuid,
        message: 'postId:$id',
        error: 'Post not found',
      );
    }
    logger.d('$uuid: Successfully readed post, userId: $userId, postId:$id');
    return TextlyResponse.success(
      uuid: uuid,
      message: 'Post has been readed successfully, userId: $userId, postId:$id',
      data: {
        'post': post.toJson(),
      },
    );
  } catch (e) {
    logger
        .e('$uuid: Error reading post, userId: $userId, postId:$id, error: $e');
    return TextlyResponse.error(
      statusCode: 500,
      errorCode: 0,
      uuid: uuid,
      message: 'postId:$id',
      error: '$e',
    );
  }
}

/// Delete Post
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
    logger.d('$uuid: Deleting post, userId: $userId, postId: $postId');
    await postRepository.deletePost(userId: userId, postId: postId);
    logger.d('$uuid: Successfully deleted post, userId: $userId');
    return TextlyResponse.success(
      uuid: uuid,
      message: 'Post has been deleted successfully',
      data: userId,
    );
  } catch (e) {
    logger.e('$uuid: Error deleted post, userId: $userId, error: $e');
    return TextlyResponse.error(
      statusCode: 500,
      errorCode: 0,
      uuid: uuid,
      message: '',
      error: '$e',
    );
  }
}
