# 💬 Real-Time Chat Application

![CI/CD](https://github.com/thaitr9999-dev/java-chat-app/actions/workflows/ci-cd.yml/badge.svg)
![Java](https://img.shields.io/badge/Java-17-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5-green)
![License](https://img.shields.io/badge/license-MIT-blue)

Production-ready real-time chat built with Spring Boot, WebSocket/STOMP, and JWT — designed with a security-first mindset across every layer.

**Live Demo:** [https://chat-app-final-5i37.onrender.com](https://chat-app-final-5i37.onrender.com)

---

## Features

- Real-time group and private 1-to-1 messaging via WebSocket/STOMP
- JWT authentication on every REST request and WebSocket handshake
- File upload with multi-layer validation (MIME + extension + UUID sanitization)
- Brute-force protection — 5 failed attempts triggers a 15-minute block (HTTP 429)
- Audit logging — every login and file upload recorded with username, IP, timestamp
- Role-based access control (`USER` / `ADMIN`), message read status, online user tracking

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Java 17, Spring Boot 3.5 |
| Real-time | WebSocket, STOMP, SockJS |
| Security | Spring Security, JWT (jjwt 0.12.3), BCrypt |
| Database | H2 (dev) / PostgreSQL 15 (prod), Flyway, Spring Data JPA |
| Rate limiting | Bucket4j |
| Containerization | Docker, Docker Compose |
| CI/CD | GitHub Actions → Render |
| Frontend | HTML/CSS/JS, Bootstrap 5, StompJS 7 |

---

## Architecture

```
Browser
  ├── HTTP (REST)  ──► JwtFilter ──► Controllers ──► Services ──► PostgreSQL
  └── WebSocket    ──► JwtHandshakeInterceptor (HTTP layer reject)
        └── STOMP  ──► JwtChannelInterceptor (sets Principal)
                   ──► ChatController
                         ├── /app/chat.sendMessage  → /topic/public
                         ├── /app/chat.addUser      → /topic/public + /topic/online-users
                         └── /app/private           → /user/{recipient}/queue/private
```

**Key design decisions:**

- **JWT vs Session:** Stateless tokens allow horizontal scaling with no shared session store. Sender identity is always derived from the token server-side, never from client payload.
- **Dual WebSocket auth:** `JwtHandshakeInterceptor` rejects unauthenticated connections at the HTTP upgrade layer; `JwtChannelInterceptor` sets the STOMP `Principal` so `@MessageMapping` methods get verified identity.
- **ConcurrentHashMap keyed by sessionId** for online tracking — correctly handles multiple tabs per user.
- **H2 → PostgreSQL** via Flyway migrations with `ddl-auto=validate` in production, preventing schema drift.
- **Chat history loaded via REST**, not WebSocket broadcast, to avoid replaying messages to new joiners.

---

## Security

| Attack | Defense | Tested |
|---|---|---|
| JWT tampering / wrong secret | HMAC-SHA256 verification — `isValid()` returns false | ✅ |
| Brute-force login | Bucket4j token bucket per `username:ip`, 5 attempts → 15-min block | ✅ |
| XSS via chat message | Server-side HTML escaping before broadcast | ✅ |
| Path traversal filename | UUID rename — original filename discarded entirely | ✅ |
| MIME spoofing on upload | Content-type + extension double validation | ✅ |
| WebSocket without token | Rejected at HTTP handshake before STOMP layer | ✅ |
| Unauthorized admin access | `@PreAuthorize("hasRole('ADMIN')")` → HTTP 403 | ✅ |
| Stack trace disclosure | `@RestControllerAdvice` returns structured error JSON only | ✅ |

Additional hardening: HSTS, `X-Content-Type-Options`, explicit CORS origin allowlist (no wildcard `*`).

---

## Testing

```bash
./mvnw test
```

- **Unit tests** (Mockito, no Spring context): `JwtUtil`, `AuthController`, `MessageService`
- **Integration tests** (`@SpringBootTest` + H2): `WebSocketIntegrationTest` — connect with valid token, broadcast, multi-client message exchange
- `ReflectionTestUtils` injects `@Value` fields without a full application context

---

## Quick Start

```bash
# Option 1 — H2 in-memory (no setup)
git clone https://github.com/thaitr9999-dev/java-chat-app.git
cd java-chat-app
./mvnw spring-boot:run

# Option 2 — Docker Compose with PostgreSQL
docker-compose up --build
```

App available at `http://localhost:8080`.

**Required environment variables for production:**

| Variable | Description |
|---|---|
| `JWT_SECRET` | Min 32-char signing secret |
| `SPRING_DATASOURCE_URL` | PostgreSQL JDBC URL |
| `SPRING_DATASOURCE_USERNAME` / `_PASSWORD` | DB credentials |
| `SPRING_PROFILES_ACTIVE` | Set to `prod` |

---

## Roadmap

- [ ] String search with Boyer-Moore / Rabin-Karp
- [ ] Docker multi-stage build optimization
- [ ] Swagger / OpenAPI documentation

---

## Author

**Kim Truong** — Backend Developer  
GitHub: [@thaitr9999-dev](https://github.com/thaitr9999-dev)
