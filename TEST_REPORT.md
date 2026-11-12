# Test report

Run on 2026-11-02 on Windows with Node.js 22.14.0. Only results actually observed are listed. Nothing in this file is planned or assumed.

## Results

| Check | Status | Evidence |
|---|---|---|
| Backend and frontend type-check | PASS | `npm run typecheck`, both workspaces, no errors |
| Backend build | PASS | `npm test` runs `tsc` before the suites |
| Backend test suite | PASS, 12 of 12 | `npm test`, `node --test test/api.test.mjs test/logic.test.mjs` |
| Seed reset | PASS | `npm run seed -w backend -- --force` on a temporary database produced 5 bikes, 3 at Kadapa and 2 at Proddatur, 1 administrator and 0 bookings |
| Fleet migration | PASS | Existing database migrated from 15 numbered copies to 5 models, 3 at Kadapa and 2 at Proddatur, 5 featured, 0 bookings and 1 administrator |
| Fleet API and pricing | PASS | `/api/bikes` returned 5 units, branch filters returned 3 and 2, and the five models quoted their daily, 7-day and 30-day rates before fee and GST |
| Duplicate photo removal | PASS | 15 fleet photos reduced to 5; every bike image and gallery path exists and no unreferenced fleet photo remains |
| Browser fleet smoke test | PASS | `/bikes` rendered 5 cards and the Ducati detail page showed ₹2,000 daily, ₹14,000 weekly and ₹60,000 monthly with no console errors |
| Header cleanup and footer announcement | PASS | Skip link and top announcement bar removed from every page; the announcement now renders above the footer copyright row and the admin field is labelled "Footer announcement" |
| Pickup studio filter | PASS | The "Pickup studio" select in the `/bikes` header filtered to Proddatur and returned exactly the KTM 890 Adventure R and Moto Guzzi V7 Stone, with no console errors and no horizontal overflow |
| Login page image | PASS | A fresh browser context loaded `/login` at desktop and mobile widths with the BMW R 1250 GS Adventure photo visible in the side panel and mobile banner; the image loaded at both sizes with no console errors or horizontal overflow |
| Public browsing | PASS | A signed-out browser opened `/`, `/bikes`, the BMW detail page, `/legal/privacy` and `/legal/terms` directly; `/account`, `/staff` and `/admin` still redirected to `/login?next=...` |
| Stable single-server link | PASS | One Express process serves the built app and API on `0.0.0.0:5173`; `http://localhost:5173` and `http://10.220.156.197:5173` both returned 200, and all public links returned 200 with no console errors |
| Production frontend build | PASS | `npm run build`, Vite produced `dist/index.html`, one CSS bundle and one JS bundle |
| Logout revokes the token server-side | PASS | `logic.test.mjs`: revoked token refused, other sessions unaffected |
| Old cookie replay after logout returns 401 | PASS | `api.test.mjs` |
| Logout-all and password reset invalidate old tokens | PASS | `logic.test.mjs` and `api.test.mjs` (`token_version` bump) |
| Admin coupon API requires an admin session | PASS | `api.test.mjs` |
| Availability quote applies a coupon and rejects bad codes | PASS | `api.test.mjs` |
| Discount reduces subtotal and GST, never below zero | PASS | `logic.test.mjs` |
| Percent and fixed coupons | PASS | `logic.test.mjs` |
| Fixed coupon capped at the subtotal | PASS | `logic.test.mjs` |
| Invalid, expired, inactive, below-minimum and over-limit codes rejected | PASS | `logic.test.mjs` |

## Not run

- Playwright end-to-end checks (`e2e/asset-failure.spec.ts`). They need a running dev server and an installed Chromium build.
- Real SMS delivery and SMS-based password recovery were not tested before SMS OTP was removed from the product.
- Live PhonePe or Paytm capture and refunds. No merchant credentials were supplied, and no real money may be moved in this environment.
- A live PostgreSQL or Supabase deployment. The application uses the local SQLite data layer.
- Visual confirmation that each supplied photo matches the motorcycle it is assigned to. The five files were kept from the operator's supplied set and mapped in the order given, but the image pixels were not machine-verified.

## Known limits

- The session cookie lasts 7 days (`COOKIE_MAX_AGE`). Revocation makes that safe, but a short access token plus refresh token was not built.
- Coupon usage counts non-cancelled and non-rejected bookings; there is no per-user usage limit.
- The payment simulator stands in for PhonePe and Paytm until merchant keys are configured.
- Password recovery is not self-service. A forgotten password must be reset by an operator with database access.
- The Kadapa studio near New Bus Stand and the Proddatur branch at One Town Police Station are set. Phone number, opening hours and security deposit are marked `TODO` in `backend/src/lib/business-facts.ts` until the owner supplies them.

## Run everything

```bash
npm install
npm run typecheck
npm test
npm run build
npx playwright install chromium
npm run dev
npm run test:e2e
```
