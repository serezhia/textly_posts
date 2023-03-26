import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:logger/logger.dart';
import 'package:textly_core/textly_core.dart';
import 'package:textly_posts/models/textly_response.dart';
import 'package:textly_posts/models/user_id_model.dart';

FutureOr<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.post:
      return await _post(context);
    case HttpMethod.put:
      return await _put(context);
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.get:
    case HttpMethod.options:
    case HttpMethod.patch:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

//Create Post

FutureOr<Response> _post(RequestContext context) async {
  final postRepository = context.read<PostRepository>();
  final body = jsonDecode(await context.request.body()) as Map<String, Object?>;
  final userId = context.read<UserId>().userId ?? -1;
  final content = body['body'] as String?;
  final parentPostId = body['parent_post_id'] as int?;

  final uuid = context.read<String>();
  final logger = context.read<Logger>();

  if (content == null) {
    return TextlyResponse.needMoreData(
      uuid: uuid,
      type: TypeNeedData.body,
      nameData: 'body',
    );
  }

  if (content.length > 30) {
    return TextlyResponse.error(
      uuid: uuid,
      errorCode: 0,
      message: 'Incorrect body',
      description: '''body must have a length less than or equal to 255''',
      error: 'Incorrect body',
      statusCode: 400,
    );
  }

  try {
    logger.d('$uuid: Creating post, userId: $userId');
    final post = await postRepository.createPost(
      post: Post(
        userId: userId,
        body: content,
        parentPostId: parentPostId,
        createdAt: DateTime.now(),
        likes: 0,
        comments: 0,
        views: 0,
        isDelete: false,
        isEdit: false,
        isLiked: false,
      ),
    );
    logger.d('$uuid: Successfully created post, userId: $userId');
    return TextlyResponse.success(
      uuid: uuid,
      message: 'Post has been created successfully, userId: $userId',
      data: {
        'post': post.toJson(),
      },
    );
  }
  // on PostgreSQLException catch (e) {
  //   logger.e('$uuid: Error creating post, userId: $userId, error: $e');
  //   if (e.code == '23505' && e.constraintName == 'profiles_pkey') {
  //     return TextlyResponse.error(
  //       statusCode: 500,
  //       errorCode: 23505,
  //       uuid: uuid,
  //       message: 'This user already has a profile',
  //       error: '$e',
  //     );
  //   }

  //   return TextlyResponse.error(
  //     statusCode: 500,
  //     errorCode: 23000,
  //     uuid: uuid,
  //     message: 'PostgreSQLException',
  //     error: '$e',
  //   );
  // }
  catch (e) {
    logger.e('$uuid: Error creating post, userId: $userId, error: $e');
    return TextlyResponse.error(
      statusCode: 500,
      errorCode: 0,
      uuid: uuid,
      message: '',
      error: '$e',
    );
  }
}

// /// Delete Post
// FutureOr<Response> _delete(RequestContext context) async {
//   final postRepository = context.read<PostRepository>();
//   final body = jsonDecode(await context.request.body()) as Map<String, Object?>;
//   final userId = context.read<UserId>().userId ?? -1;
//   final content = body['body'] as String?;
//   final parentPostId = body['parent_post_id'] as int?;

//   final uuid = context.read<String>();
//   final logger = context.read<Logger>();

//   try {
//     logger.d('$uuid: Deleting account, userId: $userId');
//     await postRepository.deletePost(userId: userId, postId: postId);
//     logger.d('$uuid: Successfully deleted profile, userId: $userId');
//     return TextlyResponse.success(
//       uuid: uuid,
//       message: 'Profile has been deleted successfully',
//       data: userId,
//     );
//   } on PostgreSQLException catch (e) {
//     logger.e('$uuid: Error deleted profile, userId: $userId, error: $e');
//     return TextlyResponse.error(
//       statusCode: 500,
//       errorCode: 23000,
//       uuid: uuid,
//       message: 'PostgreSQLException',
//       error: '$e',
//     );
//   } catch (e) {
//     logger.e('$uuid: Error deleted profile, userId: $userId, error: $e');
//     return TextlyResponse.error(
//       statusCode: 500,
//       errorCode: 0,
//       uuid: uuid,
//       message: '',
//       error: '$e',
//     );
//   }
// }

/// Update Profile
FutureOr<Response> _put(RequestContext context) async {
  final postRepository = context.read<PostRepository>();
  final body = jsonDecode(await context.request.body()) as Map<String, Object?>;
  final userId = context.read<UserId>().userId ?? -1;
  final content = body['body'] as String?;
  final postId = body['post_id'] as int?;

  final uuid = context.read<String>();
  final logger = context.read<Logger>();

  if (content == null) {
    return TextlyResponse.needMoreData(
      uuid: uuid,
      type: TypeNeedData.body,
      nameData: 'body',
    );
  }
  if (postId == null) {
    return TextlyResponse.needMoreData(
      uuid: uuid,
      type: TypeNeedData.body,
      nameData: 'post_id',
    );
  }

  if (content.length > 30) {
    return TextlyResponse.error(
      uuid: uuid,
      errorCode: 0,
      message: 'Incorrect body',
      description: '''body must have a length less than or equal to 255''',
      error: 'Incorrect body',
      statusCode: 400,
    );
  }

  try {
    logger.d('$uuid: Updating post, userId: $userId');
    final post = await postRepository.updatePost(
      post: Post(
        postId: postId,
        userId: userId,
        body: content,
        isEdit: true,
      ),
    );
    logger.d('$uuid: Successfully updated post, userId: $userId');
    return TextlyResponse.success(
      uuid: uuid,
      message: 'Post has been updated successfully, userId: $userId',
      data: {
        'post': post.toJson(),
      },
    );
  } catch (e) {
    logger.e('$uuid: Error updating post, userId: $userId, error: $e');
    return TextlyResponse.error(
      statusCode: 500,
      errorCode: 0,
      uuid: uuid,
      message: '',
      error: '$e',
    );
  }
}
