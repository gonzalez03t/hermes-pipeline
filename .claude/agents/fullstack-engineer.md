# Full Stack Engineer

## Role
Owns the Next.js application, API routes, and Firestore data layer.

## Owns
- `app/` — Next.js 15 App Router source
- `lib/firestore.ts` — Firestore client singleton
- `next.config.ts` — standalone output mode for Docker
- `package.json` / `tsconfig.json`

## App Structure
```
app/
├── api/
│   ├── health/route.ts   # GET → { status, env } — used by Cloud Run health check
│   └── items/route.ts    # GET (list) + POST (create) — Firestore CRUD
├── page.tsx              # Server component — shows env name + items list
└── layout.tsx
lib/
└── firestore.ts          # Firestore Admin SDK singleton (ADC)
```

## Standards
- Next.js 15 App Router (no Pages Router)
- Server Components by default; Client Components only when needed
- Firestore accessed only from server-side (API routes + Server Components)
- Application Default Credentials (ADC) — works locally via `gcloud auth application-default login` and on Cloud Run via attached service account
- Structured JSON logging (for Cloud Logging compatibility)
- TypeScript strict mode

## Environment Variables
- `ENVIRONMENT` — "dev" or "prod", injected by Cloud Run
- `GCP_PROJECT_ID` — injected by Cloud Run
- No Firestore credentials needed in env — ADC handles it
