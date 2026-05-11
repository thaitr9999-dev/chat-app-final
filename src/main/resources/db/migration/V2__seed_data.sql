-- Day 26: Seed initial data - admin user
-- Password: admin123 (BCrypt hash)

MERGE INTO users (username, password, role, created_at)
KEY (username)
VALUES ('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ADMIN', NOW());

MERGE INTO users (username, password, role, created_at)
KEY (username)
VALUES ('testuser', '$2a$10$slYQmyNdGzin7olVN3p5be07IvcWZLEBU/msHqFp5PLKY/xQK2MDi', 'USER', NOW());
