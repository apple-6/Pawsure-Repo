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

## ⚡ Automated Environment Setup (Recommended)

To ensure consistency across all developer machines and prevent "it works on my machine" errors, we have included automated PowerShell scripts. **Run these every time you pull or merge changes.**

### 1. Backend Setup (`pawsure_backend`)
**Environment:** Command Prompt (CMD) or PowerShell

```powershell
cd pawsure_backend
powershell -ExecutionPolicy Bypass -File setup-backend.ps1
```

**What it does:**
* ✅ **Verifies Node.js Version:** Enforces `v22.21.0` to prevent runtime crashes.
* ✅ **Deep Clean:** Deletes old `dist/` and `node_modules` artifacts.
* ✅ **Clean Install:** Installs fresh dependencies using `npm ci`.

### 2. Mobile App Setup (`pawsure_app`)
**Environment:** Command Prompt (CMD) or PowerShell

```powershell
cd pawsure_app
powershell -ExecutionPolicy Bypass -File setup-flutter.ps1
```

**What it does:**
* ✅ **Flutter Doctor:** Checks for SDK installation issues.
* ✅ **Platform Regeneration:** Rebuilds Windows/Android platform files (Fixes `CMake` errors).
* ✅ **Dependency Sync:** Runs `flutter clean` and `flutter pub get`.

---

## 🎯 Why Run This Every Time?

| If you DON'T run setup scripts ❌ | If you DO run setup scripts ✅ |
| :--- | :--- |
| "Cannot find module" errors | Latest dependencies installed |
| Version conflicts (Node/Flutter) | Clean build files |
| Stale build artifacts | No version conflicts |
| **Wasted time debugging** | **Everything just works** |

---

## 🐛 Troubleshooting Common Issues

If the automated scripts fail, refer to this matrix to resolve common environment issues.

| Problem | Error Message | Solution Steps |
| :--- | :--- | :--- |
| **Node.js Mismatch** | `Node.js version mismatch` | 1. Download **Node v22.21.0** from nodejs.org<br>2. Install & Restart Terminal<br>3. Rerun script. |
| **Missing Module** | `Cannot find module @nestjs/...` | The `dist` folder is stale.<br>**CMD:** `rmdir /s /q dist` then `npm run start:dev` |
| **Windows Build Fail** | `CMake Error: does not contain CMakeLists.txt` | Missing platform files.<br>**CMD:** `cd pawsure_app` then `flutter create --platforms=windows .` |
| **DB Connection** | `Unable to connect (ENETUNREACH)` | You are likely blocked by the ISP (Supabase issue).<br>**Fix:** Turn on **Cloudflare WARP (1.1.1.1)** and restart backend. |
| **Script Blocked** | `...cannot be loaded because running scripts is disabled` | **PowerShell Fix:**<br>`Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |

### 📞 Quick Help Commands
Run these to verify your environment manually:

```bash
node -v          # Must be v22.21.0
npm -v           # Must be >= 10.0.0
flutter --version # Must be 3.x.x
```

---

## Note to Recruiters
This repository represents **Sprint 5** of the PawSure development lifecycle. It focuses on the architectural implementation of core modules (Auth, AI, Chat, Database). While the codebase is functional, certain features are optimized for local development environments.
