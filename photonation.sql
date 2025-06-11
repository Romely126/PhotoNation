USE photonation;

-- 사용자 정보 테이블
CREATE TABLE IF NOT EXISTS user_info (
    orderNum INT AUTO_INCREMENT PRIMARY KEY,
    id VARCHAR(50) NOT NULL UNIQUE,              -- 로그인 ID
    password VARCHAR(100) NOT NULL,              -- 암호화된 비밀번호
    name VARCHAR(50) NOT NULL,                   -- 이름
    nickname VARCHAR(50) NOT NULL UNIQUE,        -- 닉네임
    sex ENUM('남성', '여성') NOT NULL,           -- 성별
    birthday DATE NOT NULL,                      -- 생일
    phoneNum VARCHAR(15) NOT NULL,               -- 전화번호
    email VARCHAR(100),                          -- 이메일
    postNum VARCHAR(10) NOT NULL,                -- 우편번호
    address VARCHAR(100) NOT NULL,               -- 기본주소
    detailAddress VARCHAR(100) NOT NULL,         -- 상세주소
    profileImg LONGBLOB,                         -- 프로필 이미지
    profileImgType VARCHAR(50),                  -- 프로필 이미지 타입
    joinDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 가입일, 기본값 현재 시간
    actived TINYINT(1) NOT NULL DEFAULT 1        -- actived 컬럼, 기본값 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 이메일 인증 정보를 저장하는 테이블
CREATE TABLE email_verification (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  verification_code VARCHAR(6) NOT NULL,
  is_verified TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expired_at TIMESTAMP
);

-- 탈퇴한 사용자들의 데이터 적재
CREATE TABLE lost_user (
    id VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    nickname VARCHAR(100) NOT NULL,
    sex VARCHAR(10) NOT NULL,
    birthday DATE NOT NULL,
    phoneNum VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL,
    postNum VARCHAR(10),
    address VARCHAR(500),
    joinDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    withdrawDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id, withdrawDate),
    INDEX idx_withdraw_date (withdrawDate),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='탈퇴한 사용자 정보 보관 테이블';

-- 탈퇴 회원의 프로필 이미지 백업 테이블
CREATE TABLE lost_user_profiles (
    id VARCHAR(50) NOT NULL,
    withdrawDate TIMESTAMP NOT NULL,
    profileImage LONGBLOB,
    uploadDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id, withdrawDate),
    FOREIGN KEY (id, withdrawDate) REFERENCES lost_user(id, withdrawDate) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='탈퇴한 사용자 프로필 이미지 보관 테이블';

-- 게시글 테이블
CREATE TABLE posts (
    postId INT AUTO_INCREMENT PRIMARY KEY,
    userId VARCHAR(50) NOT NULL,                     -- 작성자 ID (user_info의 id 참조)
    nickname VARCHAR(50) NOT NULL,                   -- 작성 시점의 닉네임
    boardType ENUM('free', 'photo', 'qna', 'market') NOT NULL,  -- 게시판 종류
    title VARCHAR(200) NOT NULL,                     -- 제목
    content TEXT NOT NULL,                           -- 내용
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,   -- 작성일
    updatedAt TIMESTAMP NULL,                       -- 수정일
    viewCount INT DEFAULT 0,                         -- 조회수
    likeCount INT DEFAULT 0,                         -- 추천수
    dislikeCount INT DEFAULT 0,                      -- 비추천수
    FOREIGN KEY (userId) REFERENCES user_info(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 게시글 이미지 테이블
CREATE TABLE post_images (
    imageId INT AUTO_INCREMENT PRIMARY KEY,
    postId INT NOT NULL,
    fileName VARCHAR(255) NOT NULL,                  -- 저장된 파일명
    originalName VARCHAR(255) NOT NULL,              -- 원본 파일명
    fileSize BIGINT NOT NULL,                       -- 파일 크기
    filePath VARCHAR(255) NOT NULL,                  -- 저장 경로
    fileType VARCHAR(50) NOT NULL,                   -- 파일 MIME 타입
    uploadedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- 업로드 시간
    FOREIGN KEY (postId) REFERENCES posts(postId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 추천/비추천 기록 테이블
CREATE TABLE post_reactions (
    reactionId INT AUTO_INCREMENT PRIMARY KEY,
    postId INT NOT NULL,
    userId VARCHAR(50) NOT NULL,
    reactionType ENUM('like', 'dislike') NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (postId) REFERENCES posts(postId),
    FOREIGN KEY (userId) REFERENCES user_info(id),
    UNIQUE KEY unique_reaction (postId, userId)      -- 한 게시글에 한 사용자당 하나의 반응만
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 댓글 테이블
CREATE TABLE comments (
    commentId INT AUTO_INCREMENT PRIMARY KEY,
    postId INT NOT NULL,
    userId VARCHAR(50) NOT NULL,
    nickname VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modifiedAt TIMESTAMP NULL,
    FOREIGN KEY (postId) REFERENCES posts(postId) ON DELETE CASCADE,
    FOREIGN KEY (userId) REFERENCES user_info(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 포토 스팟 테이블
CREATE TABLE photo_spots (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL,
    photo_name VARCHAR(255),
    photo_data LONGBLOB,
    user_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    like_count INT DEFAULT 0
);

-- 포토 스팟 좋아요(추천) 테이블
CREATE TABLE photo_spot_likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    spot_id INT NOT NULL,
    user_id VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (spot_id) REFERENCES photo_spots(id) ON DELETE CASCADE,
    UNIQUE KEY unique_like (spot_id, user_id)  -- 한 유저당 한 출사지에 하나의 좋아요만 가능
);