-- 샘플 사용자 추가 (비밀번호: 1234)
INSERT INTO user_info (id, password, name, nickname, sex, birthday, phoneNum, email, postNum, address, detailAddress)
VALUES ('test1', 'e4c5f30e6ad54c1cf89a95a6e4cdb870', '홍길동', '길동이', '남성', '1990-01-01', '010-1234-5678', 'test1@example.com', '12345', '서울시 강남구', '테스트 아파트 101호');

-- 샘플 게시글 추가 (각 게시판 유형별 게시글)
INSERT INTO posts (userId, nickname, boardType, title, content, createdAt)
VALUES ('test1', '길동이', 'free', '자유게시판 테스트 게시글입니다', '자유게시판에 작성된 테스트 내용입니다.', NOW());

INSERT INTO posts (userId, nickname, boardType, title, content, createdAt)
VALUES ('test1', '길동이', 'photo', '포토게시판 테스트 게시글입니다', '포토게시판에 작성된 테스트 내용입니다. 사진이 첨부되어 있습니다.', NOW());

INSERT INTO posts (userId, nickname, boardType, title, content, createdAt)
VALUES ('test1', '길동이', 'qna', '질문게시판 테스트 게시글입니다', '질문게시판에 작성된 테스트 내용입니다. 질문이 있습니다.', NOW());

INSERT INTO posts (userId, nickname, boardType, title, content, createdAt)
VALUES ('test1', '길동이', 'market', '장터게시판 테스트 게시글입니다', '장터게시판에 작성된 테스트 내용입니다. 물건을 팝니다.', NOW());

-- 게시글 이미지 경로 추가 (실제 파일이 해당 경로에 존재해야 합니다)
INSERT INTO post_images (postId, fileName, originalName, fileSize, filePath, fileType)
VALUES (1, 'sample1.jpg', 'sample1.jpg', 1024, 'img/default_thumbnail.jpg', 'image/jpeg');

INSERT INTO post_images (postId, fileName, originalName, fileSize, filePath, fileType)
VALUES (2, 'sample2.jpg', 'sample2.jpg', 1024, 'img/default_thumbnail.jpg', 'image/jpeg');

INSERT INTO post_images (postId, fileName, originalName, fileSize, filePath, fileType)
VALUES (3, 'sample3.jpg', 'sample3.jpg', 1024, 'img/default_thumbnail.jpg', 'image/jpeg');

INSERT INTO post_images (postId, fileName, originalName, fileSize, filePath, fileType)
VALUES (4, 'sample4.jpg', 'sample4.jpg', 1024, 'img/default_thumbnail.jpg', 'image/jpeg');

-- 게시글 반응 추가 (예: 추천)
INSERT INTO post_reactions (postId, userId, reactionType)
VALUES (1, 'test1', 'like');

INSERT INTO post_reactions (postId, userId, reactionType)
VALUES (2, 'test1', 'like'); 