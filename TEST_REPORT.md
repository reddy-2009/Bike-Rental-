# Test report — logout revocation, coupons, WhatsApp, asset failure

Generated 2026-10-31 in an offline sandbox (no `npm install`, no browser). Status is stated honestly.

| Item | Status | Evidence |
|---|---|---|
| Logout revokes the token server-side (deny-list, SHA-256 of token, kept until natural expiry) | PASS (logic) | `backend/test/logic.test.mjs` — revoked token refused, other sessions unaffected |
| Password reset / logout-all invalidate old tokens (`token_version`) | PASS (logic) | same file |
| Admin-lock no longer leaves a replayable admin token | IMPLEMENTED, not run over HTTP | `routes/auth.ts` |
| Replay old cookie against real endpoints after logout → 401 | NOT RUN | `backend/test/api.test.mjs` (skips until `npm install`) |
| Coupons: percent, fixed, expired, inactive, over-limit, below minimum, invalid | PASS (logic) | `logic.test.mjs` |
| Discount can never make total negative (clamped to subtotal; total ≥ service fee) | PASS (logic) | `logic.test.mjs` |
| Coupon on live quote + booking creation, admin CRUD auth | NOT RUN | `api.test.mjs` |
| WhatsApp `wa.me` URL builder (digits only, encoded text) | PASS (logic) | `logic.test.mjs` |
| Admin UI for coupons/WhatsApp, coupon field on bike page, WhatsApp button, "sign out everywhere" | WRITTEN, not compiled or viewed | no frontend deps offline |
| Images / .glb / audio blocked, Slow 3G | NOT RUN | `e2e/asset-failure.spec.ts` |

## Also fixed
- `GET /bikes/:id/availability` checked the status `'pending'`, which no longer exists, so held bikes looked available. It now checks `pending_payment` and `pending_approval`.

## Run everything
```
npm install
npm test                       # backend build + node:test (logic + HTTP)
npx playwright install chromium
npm run dev                    # in another terminal
npm run test:e2e
```

## Known limits
- Session cookie still lasts 7 days (`COOKIE_MAX_AGE`); revocation makes that safe, but a 15-minute access token + refresh token was not built.
- Coupon usage counts non-cancelled/rejected bookings; there is no per-user limit.
- Payments/SMS were not re-tested; this project uses PhonePe/Paytm and a simulator, not Stripe/Twilio.
