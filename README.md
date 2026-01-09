I apologize for the formatting breaks. It happens because the code blocks inside the README conflict with the chat's formatting.

Here is the **entire file** wrapped in a safe block. You can copy everything inside this box directly into your `README.md`.

```markdown
# PawSure: The Integrated Pet Care Ecosystem 🐾

> **A cross-platform Superapp bridging the gap between Pet Owners and Caretakers through secure marketplace dynamics, AI-driven health monitoring, and real-time community engagement.**

![Flutter](https://img.shields.io/badge/Flutter-3.19-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![NestJS](https://img.shields.io/badge/NestJS-10.0-E0234E?style=for-the-badge&logo=nestjs&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![TypeORM](https://img.shields.io/badge/TypeORM-Active_Record-orange?style=for-the-badge)

## 📖 Project Overview
PawSure is an ambitious engineering capstone project designed to solve the fragmentation in the pet care industry. Unlike single-purpose apps, PawSure is architected as a **Superapp Ecosystem** that unifies three critical domains:

1.  **Service Marketplace:** A secure, dual-role booking system for Sitters and Owners.
2.  **Health Intelligence:** AI-powered diagnostics and comprehensive medical logging.
3.  **Community Social Graph:** Real-time social interaction and event coordination.

---

## 🏗️ System Architecture

This project utilizes a **Monorepo** structure to ensure type safety and unified development standards across the stack.

### 📱 Frontend: Mobile Superapp (`/pawsure_app`)
- **Framework:** Flutter (Dart)
- **State Management:** **GetX** (Reactive State Manager) for high-performance UI rebuilds.
- **UX Strategy:** Implemented **Optimistic UI** updates for zero-latency user feedback during network requests.
- **Real-Time:** Integrated `socket_io_client` for bi-directional chat latency < 100ms.

### ⚙️ Backend: API Gateway (`/pawsure_backend`)
- **Framework:** NestJS (TypeScript)
- **Architecture:** Modular architecture with **Dependency Injection** and **DTO Validation**.
- **Security:** Custom **JWT Strategy** with "Gatekeeper" Guards implementing strict **Role-Based Access Control (RBAC)**.
- **AI Integration:** Hosted custom **ONNX Model** (`best.onnx`) for local inference of pet waste analysis.
- **Database:** PostgreSQL managed via **TypeORM**, featuring a fully normalized (3NF) schema with Cascade constraints.

---

## 🚀 Key Technical Features (Sprint 5)

### 1. Dual-Role Authentication & RBAC
PawSure implements a complex authorization flow allowing users to exist as both "Owners" and "Sitters" within the same ecosystem without relogging.
- **Technical Detail:** The `JwtStrategy` intercepts requests, decodes the Bearer token, and validates the user's `RoleID` against the specific endpoint's `@Roles()` decorator.

### 2. The "Gatekeeper" Security Module
We moved beyond basic authentication by implementing a custom Guard that acts as a firewall for API routes.

```typescript
// Example: RBAC Guard Logic
@Injectable()
export class RolesGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>(ROLES_KEY, ...);
    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.some((role) => user.roles?.includes(role));
  }
}
```

### 3. AI-Powered Health Scanning
- **Module:** `AiModule`
- **Logic:** Users capture images of pet waste; the backend processes the image against a pre-trained ONNX model to detect potential digestive issues, logging the result directly to the `HealthRecord` entity.

### 4. Real-Time Geospatial Tracking
- **Module:** `ActivityLogModule`
- **Logic:** Integrated GPS stream handling to visualize pet walking routes in real-time, storing coordinate arrays for historical route playback and sitter accountability.

---

## 📂 Repository Structure

```bash
pawsure-repo/
├── pawsure_app/          # Flutter Mobile Client
│   ├── lib/controllers/  # GetX Controllers (Business Logic)
│   ├── lib/services/     # API & Socket Services
│   └── lib/widgets/      # Reusable UI Components
├── pawsure_backend/      # NestJS Server
│   ├── src/auth/         # JWT Strategies & Guards
│   ├── src/ai/           # ONNX Model & Inference Logic
│   ├── src/chat/         # WebSocket Gateway
│   └── src/database/     # TypeORM Entities & Migrations
└── README.md             # You are here
```

---

## 🛠️ Getting Started

### Prerequisites
* Node.js (v18+)
* Flutter SDK (v3.19+)
* PostgreSQL (v16)
* Docker (Optional for DB)

### Installation

1. **Clone the Monorepo:**
   ```bash
   git clone [https://github.com/your-username/pawsure-repo.git](https://github.com/your-username/pawsure-repo.git)
   ```

2. **Backend Setup:**
   ```bash
   cd pawsure_backend
   npm install
   # Configure .env file with DB credentials
   npm run start:dev
   ```

3. **Frontend Setup:**
   ```bash
   cd pawsure_app
   flutter pub get
   flutter run
   ```

---

## Note to Recruiters
This repository represents **Sprint 5** of the PawSure development lifecycle. It focuses on the architectural implementation of core modules (Auth, AI, Chat, Database). While the codebase is functional, certain features are optimized for local development environments.

```
