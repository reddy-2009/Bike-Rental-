# Test report

Run on 2026-11-14 on Windows with Node.js 22.14.0. Only results actually observed are listed. Nothing in this file is planned or assumed.

## Results

| Check | Status | Evidence |
|---|---|---|
| Backend and frontend type-check | PASS | `npm run typecheck`, both workspaces, no errors |
| Backend build | PASS | `npm test` runs `tsc` before the suites |
| Backend test suite | PASS, 35 of 35 | `npm test`, `node --test test/api.test.mjs test/logic.test.mjs` |
| PDF receipt and invoice | PASS | `api.test.mjs` downloads both documents: `application/pdf`, `%PDF-` header, attachment filename, a single page for a short rental, and a rendered receipt after payment; a receipt before payment is refused with `NO_PAYMENT`; `logic.test.mjs` checks amount-in-words, `Rs` formatting, document numbers, the `fRESCA` header and token signing |
| Document access and share links | PASS | `api.test.mjs`: a rider downloads their own PDF, a stranger gets 403 and no session gets 401; a signed share link opens without a session and a tampered link is refused |
| Document email gate (API only) | PASS | `api.test.mjs`: with no SMTP configured the endpoint answers 503 `EMAIL_NOT_CONFIGURED` instead of failing silently. The interface no longer offers an email action |
| jARVIS assistant | PASS | `api.test.mjs` asks the public chat endpoint and receives a studio answer; `logic.test.mjs` checks deposit, licence, hours, branches, UPI, named-bike rates, price list and the fallback reply without any model key |
| Receipt, invoice and jARVIS in the browser | PASS | Local production build: Home showed the motorcycle hero, a 5-bike fleet count, Daily/Weekly/Monthly cards (₹1,200 / ₹8,400 / ₹36,000), the search form and no console errors; jARVIS opened, answered a pickup question, and is hidden on `/admin`; My bookings and booking details showed Receipt PDF, Invoice PDF and WhatsApp; the admin approvals table showed the same actions; no horizontal overflow |
| Manual UPI flow | PASS | `api.test.mjs`: QR intent and amount are server-generated, a short reference is rejected, a valid 12-digit reference waits for staff, the same reference cannot pay two bookings, riders cannot verify, and staff reject then approve |
| WhatsApp payment link | PASS | `logic.test.mjs`: the studio number is digit-only and the `wa.me` message is URL-encoded and round-trips intact |
| WhatsApp payment confirmation | PASS | `api.test.mjs`: a rider cannot confirm, Not received leaves the booking unpaid and awaiting payment, Received marks it paid and pending approval with method `whatsapp`, and a second confirmation is rejected |
| Service fee setting | PASS | `api.test.mjs`: only an admin can read or change the fee, a new availability quote and booking use the changed amount, a negative fee is rejected, and the suite restores ₹99 afterwards |
| Late payment on an expired hold | PASS | `api.test.mjs`: the hold sweep cancels an unpaid booking, staff record the payment and it returns as paid/pending approval, an admin then confirms it, and a booking the rider cancelled cannot take payment |
| Seed reset | PASS | `npm run seed -w backend -- --force` on a temporary database produced 5 bikes, 3 at Kadapa and 2 at Proddatur, 1 administrator and 0 bookings |
| Fleet migration | PASS | Existing database migrated from 15 numbered copies to 5 models, 3 at Kadapa and 2 at Proddatur, 5 featured, 0 bookings and 1 administrator |
| Fleet API and pricing | PASS | `/api/bikes` returned 5 units, branch filters returned 3 and 2, and the five models quoted their daily, 7-day and 30-day rates before fee and GST |
| Duplicate photo removal | PASS | 15 fleet photos reduced to 5; every bike image and gallery path exists and no unreferenced fleet photo remains |
| Browser fleet smoke test | PASS | `/bikes` rendered 5 cards and the Ducati detail page showed ₹2,000 daily, ₹14,000 weekly and ₹60,000 monthly with no console errors |
| Header cleanup and footer announcement | PASS | Skip link and top announcement bar removed from every page; the announcement now renders above the footer copyright row and the admin field is labelled "Footer announcement" |
| Pickup studio filter | PASS | The "Pickup studio" select in the `/bikes` header filtered to Proddatur and returned exactly the KTM 890 Adventure R and Moto Guzzi V7 Stone, with no console errors and no horizontal overflow |
| Login page image | PASS | A fresh browser context loaded `/login` at desktop and mobile widths with the BMW R 1250 GS Adventure photo visible in the side panel and mobile banner; the image loaded at both sizes with no console errors or horizontal overflow |
| Storefront sign-in gate | PASS | A signed-out visitor was sent from `/` to `/login` and from `/bikes`, the BMW detail page, `/about` and `/contact` to `/login?next=...`; only `/login`, `/register`, `/legal/privacy` and `/legal/terms` opened directly. After signing in, Home, Browse bikes, the BMW detail page, About us and Contact us all loaded with the storefront navigation, no console errors and no horizontal overflow |
| Sign-in page destinations | PASS | A signed-out `/login` listed Home, Browse bikes, About us and Contact us in the header and the phone menu; choosing Contact returned to `/login?next=%2Fcontact`. A customer sign-in from `/login?next=%2Fabout` landed on `/about`, and the header kept the four destinations after sign-in with no console errors and no horizontal overflow |
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
- Manual UPI needs a real `UPI_ID` and a staff member to match each reference with the studio statement. It is reference matching, not an automatic gateway capture.
- Receipt email needs SMTP credentials (`SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`, `SMTP_FROM`). Until then the PDF and WhatsApp share still work.
- The invoice prints a GSTIN line only when `STUDIO_GSTIN` is set. It is currently empty.
- JARVIS answers from a built-in rule engine over the live fleet unless `OPENAI_API_KEY`/`LLM_API_KEY` is configured. The response source is reported as `rules` or `ai`.
- WhatsApp is a chat hand-off only. The link opens the studio chat with the booking details pre-filled; it is not WhatsApp Pay or the WhatsApp Business payment API. An admin or staff member confirms Received or Not received after checking the studio account, and Received records the payment.
- Password recovery is not self-service. A forgotten password must be reset by an operator with database access.
- The Kadapa studio near New Bus Stand and the Proddatur branch at One Town Police Station are set. Phone number, opening hours (9:00 am to 8:00 pm, all seven days) and the refundable ₹2,000 security deposit are stored in `backend/src/lib/business-facts.ts`.

