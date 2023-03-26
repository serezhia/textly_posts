CREATE TABLE
    "likes" (
        "user_id" int8 NOT NULL,
        "post_id" int8 NOT NULL
    );

CREATE TABLE
    "posts" (
        "post_id" bigserial,
        "user_id" int8 NOT NULL,
        "parent_post_id" int8,
        "created_at" timestamp NOT NULL,
        "likes" int8 NOT NULL,
        "comments" int8 NOT NULL,
        "views" int8 NOT NULL,
        "is_edit" bool NOT NULL,
        "is_delete" bool NOT NULL,
        "body" varchar(256) NOT NULL,
        PRIMARY KEY ("post_id")
    );

ALTER TABLE "likes"
ADD
    CONSTRAINT "post_id_likes_fk" FOREIGN KEY ("post_id") REFERENCES "posts" ("post_id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "posts"
ADD
    CONSTRAINT "parent_post_id_fk" FOREIGN KEY ("parent_post_id") REFERENCES "posts" ON DELETE CASCADE ON UPDATE CASCADE;