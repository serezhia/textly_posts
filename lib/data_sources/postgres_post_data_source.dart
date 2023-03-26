// ignore_for_file: public_member_api_docs

import 'package:postgres/postgres.dart';
import 'package:textly_core/textly_core.dart';

class PostgresPostDataSource implements PostRepository {
  PostgresPostDataSource({required this.connection});

  PostgreSQLConnection connection;

  @override
  Future<Post> addLikeToPost({
    required int postId,
    required int userId,
  }) async {
    await connection.transaction((tranc) async {
      await tranc.mappedResultsQuery(
        '''
        INSERT INTO likes (post_id, user_id)
        VALUES (@post_id, @user_id)
      ''',
        substitutionValues: {
          'post_id': postId,
          'user_id': userId,
        },
      );

      await tranc.mappedResultsQuery(
        '''
        UPDATE posts
        SET likes = likes + 1
        WHERE post_id = @post_id
        ''',
        substitutionValues: {
          'post_id': postId,
        },
      );
    });

    return await readPost(postId: postId) ??
        Post(body: 'error , addLikeToPost');
  }

  @override
  Future<Post> createPost({required Post post}) async {
    final response = await connection.mappedResultsQuery(
      '''
        INSERT INTO posts (user_id, body, parent_post_id, created_at, likes, comments, views, is_edit, is_delete)
        VALUES (@user_id, @body, @parent_post_id, @created_at, 0, 0, 0, false, false)
        RETURNING *
        ''',
      substitutionValues: post.toJson(),
    );
    return Post.fromPostgres(
      response.first['posts'] ??
          Post(
            postId: -1,
            userId: -1,
            body: 'Error create post',
            isDelete: false,
          ).toJson(),
    );
  }

  @override
  Future<Post> deleteLikeFromPost({
    required int postId,
    required int userId,
  }) async {
    await connection.transaction((tranc) async {
      final result = await tranc.mappedResultsQuery(
        '''
        DELETE
        FROM likes 
        WHERE post_id = @post_id AND user_id = @user_id
        RETURNING *
      ''',
        substitutionValues: {
          'post_id': postId,
          'user_id': userId,
        },
      );
      if (result.isEmpty) {
        throw Exception('Like not found');
      }

      await tranc.mappedResultsQuery(
        '''
        UPDATE posts
        SET likes = likes - 1
        WHERE post_id = @post_id
        ''',
        substitutionValues: {
          'post_id': postId,
        },
      );
    });

    return await readPost(postId: postId) ??
        Post(body: 'error , deleteLikeFromPost');
  }

  @override
  Future<void> deletePost({
    required int postId,
    required int userId,
  }) async {
    await connection.mappedResultsQuery(
      '''
        UPDATE posts
        SET  is_delete = true, body = ''
        WHERE post_id = @post_id AND user_id = @user_id
        ''',
      substitutionValues: {
        'post_id': postId,
        'user_id': userId,
      },
    );
  }

  @override
  Future<PostsChunk> getPostComments({
    required int postId,
    required int offset,
    required int limit,
    int? reqUserId,
  }) async {
    final response = await connection.mappedResultsQuery(
      '''
      SELECT post_id
      FROM posts
			WHERE (is_delete is NULL OR is_delete = false) AND parent_post_id = @post_id 
      ORDER BY post_id ASC
      OFFSET @offset
      LIMIT @limit
      ''',
      substitutionValues: {
        'post_id': postId,
        'offset': offset,
        'limit': limit,
      },
    );
    final posts = <Post>[];
    for (final post in response) {
      final postFromDb = await readPost(
        postId: post['posts']?['post_id'] as int? ?? -1,
        reqUserId: reqUserId,
      );

      posts.add(
        postFromDb ??
            Post(
              postId: -1,
              userId: -1,
              body: 'Error create post',
              isDelete: false,
            ),
      );
    }
    return PostsChunk(posts: posts, endOfList: posts.length < limit);
  }

  @override
  Future<PostsChunk> getPostParents({
    required int postId,
    required int limit,
    int? reqUserId,
  }) async {
    final mainPost = await readPost(postId: postId) ??
        Post(
          postId: -1,
          userId: -1,
          body: 'Error create post',
          isDelete: false,
        );

    final parents = <Post>[];
    print(mainPost);
    if (mainPost.parentPostId == null) {
      return const PostsChunk(posts: [], endOfList: true);
    }
    var currentPostId = mainPost.parentPostId;
    for (var i = 0; i < limit; i++) {
      if (currentPostId == null) {
        break;
      }

      final post =
          await readPost(postId: currentPostId, reqUserId: reqUserId) ??
              Post(
                postId: -1,
                userId: -1,
                body: 'Error create post',
                isDelete: false,
              );
      parents.add(post);
      currentPostId = post.parentPostId;
    }
    return PostsChunk(
      posts: parents.reversed.toList(),
      endOfList: parents.last.parentPostId == null,
    );
  }

  @override
  Future<Post?> readPost({required int postId, int? reqUserId}) async {
    final response = await connection.mappedResultsQuery(
      '''
          SELECT *
          ${reqUserId == null ? " " : ",(SELECT EXISTS (SELECT * FROM likes WHERE likes.user_id = @req_user_id AND likes.post_id= @post_id )) as  is_liked"}
          FROM posts ${reqUserId == null ? "" : ",likes"}
          WHERE posts.post_id = @post_id
          ''',
      substitutionValues: {
        'post_id': postId,
        'req_user_id': reqUserId,
      },
    );

    final isLiked = response.first['']?['is_liked'] as bool?;

    if (response.first['posts']?.isEmpty ?? false) {
      return null;
    }

    return Post.fromPostgres(response.first['posts'] ?? {}).copyWith(
      isLiked: isLiked,
    );
  }

  @override
  Future<Post> updatePost({required Post post}) async {
    await connection.mappedResultsQuery(
      '''
        UPDATE posts
        SET  is_edit = true, body = @body
        WHERE post_id = @post_id AND user_id = @user_id
        ''',
      substitutionValues: post.toJson(),
    );

    return (await readPost(postId: post.postId ?? -1) ??
            Post(body: 'error , updatePost'))
        .copyWith(isEdit: true);
  }
}
