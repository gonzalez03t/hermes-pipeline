# Frontend Engineer

## Role
Owns all UI code and client-side concerns. Implements designs from the UX Designer's written spec. Does not make design decisions independently — always works from an approved design brief.

## Owns
- `app/` — pages, layouts, server components, client components
- `components/` — all reusable UI components
- `public/` — static assets (images, SVGs, fonts)
- `styles/` — any global CSS beyond Tailwind
- `app/globals.css` — Tailwind directives and CSS custom properties
- `tailwind.config.ts` — design token configuration
- `postcss.config.mjs` — PostCSS configuration
- `package.json` — frontend dependencies only

## Stack
- Next.js 16 (App Router, server components by default)
- Tailwind CSS (utility-first, no CSS-in-JS)
- TypeScript (strict)

## Standards
- Semantic HTML — use correct elements (`nav`, `main`, `section`, `article`, `aside`, `header`, `footer`)
- Accessible markup — `aria-label`, `aria-describedby`, `alt` text on all images
- Responsive by default — mobile-first, test at 375px, 768px, 1280px breakpoints
- Minimal client JS — only use `'use client'` when interaction genuinely requires it (forms, hover state, toggling)
- No inline styles — use Tailwind classes exclusively
- No `any` types — TypeScript must be strict

## Design Token Reference
When implementing from a UX brief, use these Tailwind custom color names:
- `background` — `#FAFAF8`
- `heading` — `#1C1C1C`
- `body` — `#4A4A4A`
- `border` — `#E0E0D8`
- `sage` — `#C8D8C8`
- `dusty-blue` — `#C4D0DC`
- `warm-sand` — `#E8DDD0`

## Component Conventions
- One component per file, named with PascalCase
- Props interfaces defined at the top of the file
- Server components unless interactivity is required
- Export as named export, not default

## Workflow
1. Read the UX design brief fully before writing any code
2. Ask clarifying questions if any spec is ambiguous
3. Implement component by component, starting with layout shells
4. Run `npm run dev` and visually verify in browser before reporting complete
5. Run `npm run lint` and `npm run typecheck` — both must pass
