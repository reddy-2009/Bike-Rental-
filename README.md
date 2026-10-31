# fRESCA Bike Rentals

**Your Ride. Your Freedom.**

A complete motorcycle-rental platform for riders, studio staff and the people running the fleet. Browse a maintained catalogue of sport, naked, adventure, cruiser, retro and electric motorcycles, check live availability, reserve with server-calculated pricing, pay at checkout, then manage pickups, returns, revenue and roles from purpose-built dashboards.

Built as an npm-workspace monorepo with a React + TypeScript frontend and an Express + SQLite API. The database seeds itself with a realistic demo fleet of 12 motorcycles, riders and bookings the first time the server starts.

---

## Highlights

**For riders**

- Search-first catalogue of motorcycles with category, price, location, availability and sort filters
- Motorcycle detail pages with galleries, engine and chassis specifications, live availability and instant quotes
- Date-aware reservations with server-side conflict checks — no double bookings
- Mobile OTP verification at registration, a verified-phone requirement before booking, and OTP password recovery
- Sandbox payment flow: paid bookings become `pending_approval`, then an administrator confirms or rejects them
- Rider dashboard, approval/refund timeline, downloadable calendar invites and self-service cancellation with gateway refunds
- Profile details, verified mobile badge, password changes, communication preferences and saved session

**For staff**

- Daily operational desk: pickups, returns due, overdue motorcycles and live fleet status
- Check motorcycles out and back in and cancel before pickup with a clear audit trail
- Record cash or card-terminal payments at the counter, which moves the booking to admin approval
- Searchable, filterable booking table with lifecycle-aware actions

**For admins**

- Secure **Admin Access** gate (server-verified password, rate limiting, hashed storage, HTTP-only session)
- Approve or reject paid reservations after an automatic availability re-check; rejections trigger the gateway refund workflow
- Refund queue with retry/confirm controls, provider references and `Refund Failed — Admin Action Required` visibility
- Revenue by month, booking pipeline, weekly reservations and fleet-health charts
- Top-performing motorcycles, customer counts and utilisation metrics — all computed from live records
- Fleet management with create, edit, maintenance, retire and safe archive of motorcycles with history
- Rider and role management with self-demotion protection
- **Website customisation panel**: colours, fonts, copy, FAQs, terms, logo/images, live draft preview, save/publish and reset

**Platform**

- 17 application routes plus privacy and rental-terms pages, with a designed 404
- Central CSS-variable theme loaded from SQLite at startup; safe defaults if settings cannot be read
- Accessible forms, inline validation, loading states, toasts and empty states
- Responsive layouts for mobile, tablet and desktop; no horizontal page overflow
- HTTP-only cookie sessions, scrypt password hashing, Zod request validation and parameterised SQL
- Poppins and Inter from Google Fonts by default, with Lucide icons bundled locally
- Cinematic pull-cord lamp entrance on the authenticated home page, with skip/replay, optional sound and reduced-motion support

---

## The cinematic entrance

The first time a signed-in visitor opens the home page, the homepage is hidden behind a dark room with a hanging brass lamp and pull cord.

- **Pull the cord** by dragging it down with a mouse or finger, or focus the handle and press **Enter** / **Space**. A small movement springs back without switching the lamp on; a deliberate downward pull crosses the activation threshold.
- The first pull clicks the switch, lights the bulb and releases a short golden burst with a controlled set of floating particles.
- A second deliberate pull within about **1.65 seconds** adds an enhanced glow and a larger particle burst. Waiting longer simply continues to the reveal, so a double activation cannot happen by accident.
- After activation the real homepage fades in as a **3–5 second staggered sequence** — hero, navigation, headline, imagery, search, featured motorcycles, reviews, FAQ and footer. No placeholder page is used.
- **Skip animation** is always visible. **Escape** also skips. The cord handle receives focus when the entrance opens and Tab stays inside the entrance controls.
- **Replay experience** is available in the footer after entering. It replays the entrance without a page refresh, and booking data, the session and unpublished form state are untouched.
- Completion is remembered in `localStorage` under `fresca.entrance.seen.v1`, so returning visitors go straight to the homepage. The sound preference uses `fresca.entrance.sound.v1`. Neither key contains personal or sensitive data.
- Sound is synthesised with the Web Audio API (no audio files) and never plays before a user gesture. **Sound on/off** is persisted locally.
- `prefers-reduced-motion: reduce` removes the particles and long transitions while keeping the lamp controllable.
- The entrance is a presentation-only portal that mounts **inside the authenticated home route**. It cannot bypass the members-only gate or change any booking rule, and it unmounts after the reveal.

## Calendar theme

Date fields use a dedicated `.calendar-input` style with `color-scheme: light`, a `#FFFFFF` background, dark text and light-grey borders. The native date-picker popup therefore stays white in both light and dark system themes, including on the home search, the fleet filters and the reservation form. The brand gold accent is used for focus, today and the selected date. Date validation, availability checks, pricing, reservations and admin date controls are unchanged.

## The demo fleet

| Motorcycle                     | Category  | Daily rate | Studio           |
| ------------------------------ | --------- | ---------- | ---------------- |
| Ducati Panigale V4            | Sport     | ₹15,900    | fRESCA Downtown  |
| Triumph Street Triple RS      | Naked     | ₹10,900    | fRESCA Riverside |
| BMW R 1250 GS Adventure       | Adventure | ₹12,500    | fRESCA Downtown  |
| Royal Enfield Interceptor 650 | Retro     | ₹3,900     | fRESCA Uptown    |
| Harley-Davidson Sportster S   | Cruiser   | ₹11,500    | fRESCA Riverside |
| Yamaha Ténéré 700             | Adventure | ₹8,900     | fRESCA Riverside |
| Honda CB650R                  | Naked     | ₹6,900     | fRESCA Downtown  |
| Kawasaki Ninja 650            | Sport     | ₹6,500     | fRESCA Uptown    |
| Moto Guzzi V7 Stone           | Cruiser   | ₹7,900     | fRESCA Uptown    |
| KTM 890 Adventure R           | Adventure | ₹9,900     | fRESCA Riverside |
| Zero SR/F                     | Electric  | ₹9,500     | fRESCA Downtown  |
| Triumph Bonneville T120       | Retro     | ₹8,500     | fRESCA Uptown    |

The KTM 890 Adventure R seeds in `maintenance` to demonstrate the unavailable state. Every other machine is bookable. All rates are in Indian rupees (INR) per day.

---

## Tech stack

| Layer     | Technology                                                                 |
| --------- | -------------------------------------------------------------------------- |
| Frontend  | React 19, TypeScript, Vite 6, React Router 7, Tailwind CSS 4, Lucide React |
| Backend   | Node.js 22, Express 4, Zod, `node:sqlite`                                  |
| Auth      | Signed HS256 JWT in an HTTP-only, SameSite=Lax cookie; scrypt passwords    |
| Styling   | Tailwind v4 + CSS custom properties; Poppins/Inter by default, five selectable Google Fonts |
| Database  | SQLite file created automatically at `backend/data/fresca.db`              |

No native database bindings are required — the API uses Node's built-in SQLite driver.

---

## Project structure

```text
fresca-bike-rentals/
├─ backend/
│  ├─ src/
│  │  ├─ db/            # schema, connection, demo seed and reset CLI
│  │  ├─ lib/           # pricing, dates, auth, OTP, payments, refunds, site theme
│  │  ├─ middleware/    # authentication, admin-gate and role guards
│  │  ├─ routes/        # auth, bikes, bookings, payments, staff, admin, site
│  │  ├─ app.ts         # Express app, security headers, static SPA serving
│  │  └─ index.ts       # startup, seeding and graceful shutdown
│  ├─ data/             # generated SQLite database (git-ignored)
│  └─ uploads/site/     # uploaded logo / background / About images (git-ignored)
├─ frontend/
│  ├─ public/images/    # demo motorcycle photography
│  └─ src/
│     ├─ components/    # layout, booking, UI primitives
│     ├─ context/       # auth, toasts, live site theme
│     ├─ hooks/         # data-loading hooks
│     ├─ lib/           # API client, formatting, shared types, default theme
│     ├─ pages/         # every route, incl. admin approvals + customisation
│     └─ styles/        # Tailwind v4 theme and design-system classes
├─ .env.example
└─ package.json         # workspace scripts
```

---

## Getting started

### Prerequisites

- **Node.js 22.5 or newer** (required for the built-in `node:sqlite` module)
- npm 10 or newer

```bash
node --version
npm --version
```

### Install and run

```bash
npm install
npm run dev
```

- Web app: <http://localhost:5173>
- API: <http://localhost:4000>
- Health check: <http://localhost:4000/api/health>

Vite proxies `/api` to the Express server, so cookies work as same-origin during development. The first API start creates and seeds the database automatically.

The API binds to `0.0.0.0` by default so a phone on the same Wi-Fi can reach the app. Set `HOST=127.0.0.1` if you want to restrict it to the laptop only.

### Open it on your phone (same Wi-Fi)

Both devices must be on the same trusted local network. Find the laptop's IPv4 address with `ipconfig` (or `Get-NetIPAddress -AddressFamily IPv4` in PowerShell) and use the port that matches how you started the app:

| Mode | Laptop URL | Phone URL |
| ---- | ---------- | --------- |
| `npm run dev` (Vite + API) | <http://localhost:5173> | `http://<laptop-ip>:5173` |
| `npm run build` then `npm start` (built app) | <http://localhost:4000> | `http://<laptop-ip>:4000` |

For example, on the current machine the addresses are <http://localhost:5173> / <http://localhost:4000> on the laptop and `http://10.220.156.197:5173` / `http://10.220.156.197:4000` from a phone. The IP changes when you switch networks.

If Windows Firewall prompts, allow **Private** or **Public** access for Node.js — the app is served by `node.exe`. To add the rules explicitly, open PowerShell **as administrator**:

```powershell
netsh advfirewall firewall add rule name="fRESCA 4000" dir=in action=allow protocol=TCP localport=4000
netsh advfirewall firewall add rule name="fRESCA 5173" dir=in action=allow protocol=TCP localport=5173
```

Keep the network trusted: anyone who can reach port 4000/5173 can open the sign-in screen. Authentication, the members-only gate and the admin gate still apply to every protected page and API.

### If you see `ERR_CONNECTION_REFUSED`

That error means nothing is listening on the URL's port — it is not an authentication failure.

1. Start the correct process from the repository root: `npm run dev` for development (Vite 5173 + API 4000), or `npm run build` followed by `npm start` for the built app (everything on 4000).
2. Check the port and bind address: `Get-NetTCPConnection -LocalPort 4000 -State Listen` and `Get-NetTCPConnection -LocalPort 5173 -State Listen`.
3. Use the URL that matches the mode. In development open <http://localhost:5173>, not 4000; only the built app serves the SPA on 4000.
4. If the API exits on startup, read its terminal output. A missing database is created automatically; a malformed `.env` or a port already in use is reported there.

### Environment variables

The app runs with sensible local defaults and needs no `.env` to start. To customise it, copy `.env.example` to `.env` in the repository root (or `backend/.env`):

```bash
cp .env.example .env
```

| Variable                    | Default                  | Purpose                                                                 |
| --------------------------- | ------------------------ | ----------------------------------------------------------------------- |
| `PORT`                      | `4000`                   | API port                                                                |
| `HOST`                      | `0.0.0.0`                | Bind address. `0.0.0.0` allows phones on the local network; `127.0.0.1` restricts to this laptop |
| `NODE_ENV`                  | `development`            | `production` enables secure cookies and quieter errors                  |
| `JWT_SECRET`                | development fallback     | **Set a long random value in production** (also signs payment tokens)   |
| `ADMIN_ACCESS_PASSWORD`     | `9989`                   | Server-side admin dashboard password; hashed into SQLite on startup     |
| `ADMIN_ACCESS_EMAIL`        | owner email              | Admin account used when the access gate signs someone in                |
| `OTP_DEV_MODE`              | `1` outside production   | Return the sandbox OTP in API responses when no SMS provider is set     |
| `SMS_PROVIDER`              | –                        | `2factor`, `msg91` or `twilio`; required for real OTP delivery          |
| `SMS_API_KEY`               | –                        | API key for 2factor or MSG91                                            |
| `SMS_SENDER_ID`             | `FRESCA`                 | Sender ID / DLT header for Indian SMS providers                         |
| `SMS_TEMPLATE_ID`           | –                        | Provider template id where required                                     |
| `TWILIO_ACCOUNT_SID`        | –                        | Twilio account SID (alternative SMS provider)                           |
| `TWILIO_AUTH_TOKEN`         | –                        | Twilio auth token                                                       |
| `TWILIO_FROM`               | –                        | Twilio sender number                                                    |
| `DATABASE_PATH`             | `backend/data/fresca.db` | Override the SQLite file location                                       |
| `PUBLIC_BASE_URL`           | request host             | Public HTTPS origin used for gateway return/webhook URLs                |
| `PAYMENTS_SIMULATOR`        | `1`                      | `0` hides gateways that have no merchant keys configured                |
| `PHONEPE_CLIENT_ID`         | –                        | PhonePe merchant client id (enables live PhonePe)                       |
| `PHONEPE_CLIENT_SECRET`     | –                        | PhonePe merchant client secret                                          |
| `PHONEPE_CLIENT_VERSION`    | `1`                      | PhonePe OAuth client version                                            |
| `PHONEPE_ENV`               | `sandbox`                | `production` switches to the live PhonePe hosts                          |
| `PHONEPE_WEBHOOK_USER`      | –                        | Optional basic-auth user for `/api/payments/webhook/phonepe`            |
| `PHONEPE_WEBHOOK_PASSWORD`  | –                        | Optional basic-auth password for the PhonePe webhook                    |
| `PHONEPE_REFUND_URL`        | –                        | PhonePe refund endpoint; required for automatic rejection refunds       |
| `PAYTM_MID`                 | –                        | Paytm merchant id (enables live Paytm)                                  |
| `PAYTM_MERCHANT_KEY`        | –                        | Paytm merchant key used for AES checksums                               |
| `PAYTM_WEBSITE`             | `WEBSTAGING`             | Paytm website code (`DEFAULT`/your live code in production)             |
| `PAYTM_INDUSTRY_TYPE`       | `Retail`                 | Paytm industry type id                                                  |
| `PAYTM_CHANNEL_ID`          | `WEB`                    | Paytm channel id                                                        |
| `PAYTM_ENV`                 | `staging`                | `production` switches to the live Paytm hosts                           |
| `PAYTM_REFUND_URL`          | –                        | Paytm refund endpoint; required for automatic rejection refunds         |

Shell variables take priority over values in the file. The backend looks for `.env` in the current directory first, then the parent directory.

---

## Demo accounts

Seeded accounts are listed on the sign-in screen and filled in with one click. The sign-in page also has a dedicated **Admin access** button: enter the initial admin password **9989** and the server signs you into the administrator account and opens `/admin`. Change it with `ADMIN_ACCESS_PASSWORD`; the password is stored only as a scrypt hash.

| Role     | Email                                | Password       |
| -------- | ------------------------------------ | -------------- |
| Rider    | `rider@fresca.com`                   | `Rider@123`    |
| Staff    | `staff@fresca.com`                   | `Staff@123`    |
| Admin    | `navaneethreddychagari1005@gmail.com`| `Navaneeth@123`|
| Admin    | `admin@fresca.com`                   | `Admin@123`    |

The Admin Access gate is a second factor: any admin route and every `/api/admin/*` request also requires the elevated `adminUnlocked` session. Wrong passwords return `Incorrect password. Please try again.` after server-side verification, and five failures per IP in 15 minutes are throttled. **Log out** clears the HTTP-only cookie.

The demo card checkout accepts any future expiry and CVC with the test card **4242 4242 4242 4242**. No real charge is made and no card data is stored. PhonePe and Paytm appear in the same checkout: with merchant keys present they open the real gateway; without keys they open the built-in simulator, where you can approve or decline a payment.

---

## Rider requirements

- Riders must be **21 or older** and hold a **full motorcycle licence** valid in the rental state, held for at least one year. Individual machines state their own minimum experience (one to three years).
- A helmet is mandatory on every ride. A fitted helmet, riding gloves, breakdown cover and a pre-ride safety check are included in every rental.
- Bring your licence and photo ID to pickup — the studio cannot release a motorcycle without them.
- Pillions must be 18 or older and only ride on machines with a pillion seat and footpegs.
- Motorcycles must be returned with the same fuel level; a refuelling charge applies otherwise.

---

## Routes

The whole site is members-only: a signed-out visitor cannot open the home page, fleet or legal pages. Every route except sign-in and registration redirects to `/login?next=...`, and the original destination is restored after signing in or creating an account.

| Route                    | Access          | Description                                              |
| ------------------------ | --------------- | -------------------------------------------------------- |
| `/login`                 | Signed out      | Sign in, demo-account shortcuts and one-click admin access |
| `/register`              | Signed out      | Rider registration                                       |
| `/`                      | Account         | Hero, search, featured motorcycles, reviews and FAQ      |
| `/bikes`                 | Account         | Searchable, filterable catalogue                         |
| `/bikes/:slug`           | Account         | Gallery, specs, availability and reservation             |
| `/legal/privacy`         | Account         | Privacy policy                                           |
| `/legal/terms`           | Account         | Rental terms                                             |
| `/account`               | Rider           | Rider dashboard                                          |
| `/account/bookings`      | Rider           | Upcoming, pending, completed and cancelled rides         |
| `/account/bookings/:id`  | Rider           | Receipt, timeline, payment, cancellation, ICS            |
| `/account/profile`       | Authenticated   | Details, password and preferences                        |
| `/pay/simulate`          | Rider           | Built-in PhonePe/Paytm simulator used until merchant keys exist |
| `/staff`                 | Staff / admin   | Operations desk and booking management                   |
| `/admin`                 | Admin + gate    | Revenue, pipeline and fleet analytics                    |
| `/admin/bikes`           | Admin + gate    | Fleet CRUD, maintenance and retirement                   |
| `/admin/bookings`        | Admin + gate    | Approvals, confirmed/rejected bookings and refund queue  |
| `/admin/customization`   | Admin + gate    | Colours, fonts, website text, images, preview and publish|
| anything else            | Account         | Designed not-found page                                  |

Role-protected routes redirect unauthenticated visitors to `/login` and send signed-in users to the correct dashboard for their role. The lamp entrance only mounts on `/` after authentication, so it can never reveal a protected page to a signed-out visitor.

---

## Scripts

Run from the repository root:

| Command                              | What it does                                                            |
| ------------------------------------ | ----------------------------------------------------------------------- |
| `npm run dev`                        | Start API (watch mode) and Vite dev server together                     |
| `npm run build`                      | Type-check and build the backend, then the frontend                     |
| `npm start`                          | Serve the built SPA and API from Express on port 4000                   |
| `npm run typecheck`                  | Type-check both workspaces without emitting files                       |
| `npm run seed`                       | Seed demo data if the database is empty                                 |
| `npm run seed -w backend -- --force` | Reset and reseed the demo database (destroys local data)                |

---

## Booking and pricing rules

- The server is the single source of truth for money. The client may preview a quote, but totals are recalculated from the motorcycle's database rate on every create/pay request.
- Charges are the daily rate × billable days (minimum one day), plus a **₹99 service fee** and **18% GST**.
- Dates must be valid, in the future (or today), and the return date must be after pickup. Rentals are capped at 60 days.
- A rider must have a **verified mobile number** before a booking can be created.
- Overlapping `pending_payment`, `pending_approval`, `confirmed` or `active` reservations are rejected for the same motorcycle.
- **Money and approval are separate state machines.** A booking keeps a `payment_status` (`unpaid`, `pending`, `paid`, `failed`, `refund_pending`, `refund_processing`, `refunded`, `refund_failed`) independent of its booking `status`.
- Booking lifecycle: `pending_payment → pending_approval → confirmed → active → completed`, with `cancelled` and `rejected` as terminal alternatives.
  1. Selecting a motorcycle and dates creates a `pending_payment` / `unpaid` booking.
  2. A successful gateway capture moves it to `pending_approval` / `paid` — it is **not** confirmed yet.
  3. An administrator approves the request. Approval re-checks availability inside a transaction, refuses overlaps, then sets `confirmed` and records the approver and timestamp.
  4. Rejection sets `rejected` and starts the refund workflow. The UI shows `Rejected — Refund Pending`, then `Refund Processing`, then `Refunded` only after the gateway confirms the refund.
  5. If the refund cannot be issued, the booking shows `Refund Failed — Admin Action Required` and appears in the admin refund queue.
- Staff can check a confirmed booking out (`active`) and back in (`completed`), and cancel before pickup. Staff cannot approve or reject.
- Customers can cancel `pending_payment`, `pending_approval` or `confirmed` bookings; paid cancellations follow the same refund workflow.
- Invalid transitions return a clear `409`/`400` instead of corrupting state; approvals are timestamped with the administrator's identity.
- Motorcycles with booking history are archived (retired) rather than deleted, preserving receipts and reporting.

---

## Payments (Card, PhonePe, Paytm)

Checkout offers three methods. The amount is always read from the booking row in SQLite; the browser can never choose what to charge.

| Method   | How it works                                                                 |
| -------- | ---------------------------------------------------------------------------- |
| Card     | Sandbox authorisation with `4242 4242 4242 4242`; no processor, no card data stored |
| PhonePe  | PG Standard Checkout v2: OAuth token → create order → hosted page → status API |
| Paytm    | Hosted checkout with AES-128-CBC + SHA-256 `CHECKSUMHASH` → status API      |

**Modes.** Each gateway reports `live` when its merchant credentials are present, and `simulator` otherwise. The simulator lives at `/pay/simulate` and issues a signed, tamper-proof hand-off token; approving it captures the payment exactly like a real gateway, but no money moves. Set `PAYMENTS_SIMULATOR=0` to hide unconfigured gateways entirely.

**Trust model.**

- The payment row is created server-side with the booking total before any redirect.
- The browser return (`/payments/return/...`) and provider webhooks only *trigger* a check. The provider's signed status API decides `captured` / `pending` / `failed`.
- Paytm callbacks are checksum-verified, but an unverified payload still falls back to the status API instead of being trusted.
- Capture writes the payment row, moves the booking to `pending_approval` + `paid`, and appends a booking event. It is idempotent, so duplicate webhooks cannot double-capture or double-charge.
- Approval is a **separate, admin-only** action after payment — a successful payment never confirms a booking by itself.
- Refunds are issued through the gateway refund API (`PHONEPE_REFUND_URL` / `PAYTM_REFUND_URL`). A refund only becomes `refunded` when the provider confirms it; until then the booking shows `Refund Processing`. If no refund endpoint is configured, the refund is recorded as `refund_failed` and surfaced as `Refund Failed — Admin Action Required`.

**Going live with real money.**

1. Add `PHONEPE_CLIENT_ID`/`PHONEPE_CLIENT_SECRET` (plus `PHONEPE_ENV=production`) and/or `PAYTM_MID`/`PAYTM_MERCHANT_KEY` (plus `PAYTM_ENV=production`, live `PAYTM_WEBSITE`).
2. Add the refund endpoint from the merchant dashboard (`PHONEPE_REFUND_URL` / `PAYTM_REFUND_URL`) so rejections and paid cancellations can be refunded automatically.
3. Set `PUBLIC_BASE_URL` to a public HTTPS origin — the gateway must be able to reach the return/webhook URLs built from it.
4. Register `https://<host>/api/payments/webhook/phonepe` and `https://<host>/api/payments/webhook/paytm` in the merchant dashboards.
5. Secure-cookie sessions require HTTPS in production, so terminate TLS in front of Express.

---

## API overview

All responses are JSON under `/api`. Authentication uses the `fresca_session` HTTP-only cookie.

| Area     | Endpoints                                                                                     |
| -------- | --------------------------------------------------------------------------------------------- |
| Auth     | `GET /auth/me`, `POST /auth/register`, `POST /auth/login`, `POST /auth/logout`, `POST /auth/admin-access`, `POST /auth/admin-lock`, `PATCH /auth/profile`, `POST /auth/password`, `PATCH /auth/preferences` |
| OTP      | `POST /auth/otp/request`, `POST /auth/otp/login/request`, `POST /auth/otp/login/verify`, `POST /auth/phone/request`, `POST /auth/phone/verify`, `POST /auth/password/forgot/request`, `POST /auth/password/forgot/verify` |
| Bikes    | `GET /bikes`, `GET /bikes/filters`, `GET /bikes/:idOrSlug`, `GET /bikes/:idOrSlug/availability` |
| Bookings | `POST /bookings`, `GET /bookings`, `GET /bookings/:id`, `POST /bookings/:id/cancel`, `PATCH /bookings/:id/status` (staff), `POST /bookings/:id/record-payment` (staff) |
| Payments | `GET /payments/methods`, `POST /payments/bookings/:id/checkout`, `GET /payments/simulator/:token`, `POST /payments/simulator/:token/complete`, `GET /payments/return/phonepe`, `POST /payments/return/paytm`, `POST /payments/webhook/phonepe`, `POST /payments/webhook/paytm` |
| Staff    | `GET /staff/overview`, `GET /staff/stats`                                                    |
| Admin    | `GET /admin/overview`, `GET /admin/stats`, `GET /admin/users`, `PATCH /admin/users/:id/role`, `GET /admin/bikes`, `POST /admin/bikes`, `PATCH /admin/bikes/:id`, `DELETE /admin/bikes/:id`, `GET /admin/bookings`, `GET /admin/bookings/:id`, `POST /admin/bookings/:id/approve`, `POST /admin/bookings/:id/reject`, `GET /admin/refunds`, `POST /admin/refunds/:id/retry`, `POST /admin/refunds/:id/confirm` |
| Site     | Public `GET /site`; admin `GET /admin/site`, `PUT /admin/site/draft`, `POST /admin/site/publish`, `POST /admin/site/reset`, `POST /admin/site/upload` |

Errors use `{ "error": "message", "details": ... }` with appropriate `4xx`/`5xx` status codes. Invalid input is validated with Zod on the server and mirrored by inline client-side validation.

---

## Website customisation

Signed-in administrators reach the panel at **`/admin/customization`** (or via the Admin Dashboard). It is a six-tab editor:

1. **Colours** — primary, secondary, background, header/nav, footer, buttons + hover, text, headings, cards, borders/shadows, links, form fields/input borders and admin-dashboard colours. Every field has a colour picker and a HEX input.
2. **Fonts** — heading, body, navigation and button fonts (Poppins, Inter, Roboto, Montserrat, Open Sans), plus base size, heading scale, weight and line height.
3. **Website text** — site name, tagline, homepage eyebrow/heading/description, About, contact details, navigation labels, button text, bike headings, booking instructions, footer, FAQs, terms and the customer announcement. Each field has its own reset; required fields cannot be saved empty.
4. **Images & logo** — upload a logo, homepage background and About image (PNG/JPEG/WebP, max 2 MB, magic-byte checked), preview, or restore the original.
5. **Preview** — device-local live preview of the draft, including a mobile/desktop frame, before anything is published.
6. **Save & publish** — **Save changes** stores a draft (not live), **Cancel changes** discards unsaved edits, **Publish to live site** asks for confirmation and applies the draft site-wide. **Restore default design** resets colours, fonts, text and images.

All settings live in SQLite as versioned JSON. The public endpoint serves only the **published** configuration; the admin API serves the draft plus publication history. Saving, publishing and resetting require an elevated admin session (`requireAdmin`), and every publish records the administrator's name and timestamp. The storefront applies the published values as CSS custom properties at runtime and loads the selected Google Fonts, so no source edits are needed. If settings cannot be loaded, the backend and frontend both fall back to a mirrored default theme. Editable content is length-limited and plain text — no HTML or JavaScript is executed.

---

## Production build

```bash
npm run build
NODE_ENV=production JWT_SECRET="replace-with-a-long-random-secret" npm start
```

On Windows PowerShell:

```powershell
$env:NODE_ENV = "production"
$env:JWT_SECRET = "replace-with-a-long-random-secret"
npm start
```

The Express server serves `frontend/dist` with immutable caching for hashed assets, no-cache for HTML, and SPA fallback for client routes. API responses are always `Cache-Control: no-store`.

Before deploying:

1. Set a strong `JWT_SECRET`.
2. Change `ADMIN_ACCESS_PASSWORD` from the default `9989` and set `ADMIN_ACCESS_EMAIL` to the administrator account.
3. Terminate TLS in front of the app so secure cookies are delivered over HTTPS.
4. Persist the SQLite file (`DATABASE_PATH`) on durable storage — it holds users, bookings, payments, refunds **and** the published website theme — and back it up.
5. Configure PhonePe and/or Paytm merchant keys plus refund endpoints (see [Payments](#payments-card-phonepe-paytm)) and set `PUBLIC_BASE_URL`.
6. Configure an SMS provider (`SMS_PROVIDER` + key, or Twilio) and set `OTP_DEV_MODE=0`. Without SMS, registration, phone verification and password recovery cannot deliver codes in production.
7. Uploaded site images are written to `backend/uploads/site/`; put that directory on durable storage too.

---

## Resetting demo data

Stop the server, then run:

```bash
npm run seed -w backend -- --force
```

This recreates the schema and restores the 12-motorcycle fleet, demo riders and booking history. Deleting `backend/data/fresca.db` and restarting also produces a fresh seed. Both also clear published website customisation (back to the default theme).

---

## Notes and limitations

- Card payments are a deliberate sandbox: details are validated in the browser, never stored, and no card processor is called. PhonePe and Paytm use the real gateway only when merchant credentials are configured; until then their simulator stands in.
- Refunds call the gateway refund API and only become `refunded` on provider confirmation. Without `PHONEPE_REFUND_URL` / `PAYTM_REFUND_URL` they are recorded as `Refund Failed — Admin Action Required`.
- Real gateway capture and refund calls were implemented against the published PhonePe PG Checkout v2 and Paytm hosted-checkout contracts, but cannot be executed end to end without live merchant credentials.
- Mobile OTP codes are only returned in API responses when `OTP_DEV_MODE=1` (the default outside production). With no SMS provider and dev mode off, OTP endpoints return a clear `503`. In dev mode, password recovery returns a `devCode` only for existing accounts — a development-only convenience that should never be enabled publicly.
- Website text is plain text and length-limited; there is intentionally no HTML/JavaScript editing.
- Demo motorcycle photography is bundled locally for reliable offline rendering.
- The API is intentionally dependency-light; there is no ORM, external auth provider or background job runner. Simulator refunds advance on the next booking/admin read rather than via a scheduler.
- This project is a complete demonstration application, not a substitute for a PCI-compliant payment stack in production.

---

## Photo credits

Demo motorcycle photography is sourced from [Wikimedia Commons](https://commons.wikimedia.org/) and resized/cropped to 1400 × 933 for this demo. Images remain under their original licences; the photographer and licence are listed below. No image is used to imply an endorsement by the manufacturer or photographer.

| File                              | Source (Wikimedia Commons)                                                        | Photographer        | Licence       |
| --------------------------------- | --------------------------------------------------------------------------------- | ------------------- | ------------- |
| `ducati-panigale-v4-1.jpg`        | Ducati Panigale V4 - Tuning World Bodensee 2018, Friedrichshafen (OW1A0484).jpg   | Matti Blume         | CC BY-SA 4.0  |
| `ducati-panigale-v4-2.jpg`        | 2020 Ducati Panigale V4 Superleggera.jpg                                          | Ducati              | CC0           |
| `ducati-panigale-v4-3.jpg`        | Ducati Panigale V4 Las Vegas.jpg                                                  | TaurusEmerald       | CC BY-SA 4.0  |
| `triumph-street-triple-rs-1.jpg`  | Triumph Street Triple 675 front left threequarter.jpg                             | lmnop88a            | CC BY 2.0     |
| `triumph-street-triple-rs-2.jpg`  | Triumph Street Triple R 675.jpg                                                   | TheMalsa            | CC BY-SA 3.0  |
| `triumph-street-triple-rs-3.jpg`  | Triumph Street Triple 675, blue.jpg                                               | Cjp24               | CC BY-SA 4.0  |
| `bmw-r-1250-gs-adventure-1.jpg`   | BMW R 1250 GS (1).jpg                                                             | Cjp24               | CC BY-SA 4.0  |
| `bmw-r-1250-gs-adventure-2.jpg`   | BMW R 1250 GS and helmet.jpg                                                      | Cjp24               | CC BY-SA 4.0  |
| `bmw-r-1250-gs-adventure-3.jpg`   | BMW R 1250 GS HP (1).jpg                                                          | Cjp24               | CC BY-SA 4.0  |
| `royal-enfield-interceptor-650-1.jpg` | Royal Enfield 650 Interceptor A-Seite noBG.jpg                                | Auge=mit            | CC BY-SA 4.0  |
| `royal-enfield-interceptor-650-2.jpg` | Royal Enfield 650 Interceptor B-Seite noBG.jpg                                | Auge=mit            | CC BY-SA 4.0  |
| `royal-enfield-interceptor-650-3.jpg` | Royal Enfield INT 650 motorcycle.jpg                                          | Hu Nhu              | CC BY-SA 4.0  |
| `harley-davidson-sportster-s-1.jpg` | Würgauer Bergrennen Harley-Davidson Sportster-20220911-RM-111422.jpg            | Ermell              | CC BY-SA 4.0  |
| `harley-davidson-sportster-s-2.jpg` | Würgauer Bergrennen Harley-Davidson Sportster-20220911-RM-111440.jpg            | Ermell              | CC BY-SA 4.0  |
| `harley-davidson-sportster-s-3.jpg` | Harley-Davidson in The 43rd Bangkok International Motor Show by TrisT 34.jpg     | Tris T7             | CC BY-SA 4.0  |
| `yamaha-tenere-700-1.jpg`         | Yamaha Tenere 700.jpg                                                             | Roland Niedermeier  | CC BY-SA 4.0  |
| `yamaha-tenere-700-2.jpg`         | 06-2024 Yamaha Rally Tenere 700.jpg                                               | Wikisympathisant    | CC BY-SA 4.0  |
| `yamaha-tenere-700-3.jpg`         | 06-2024 Yamaha Rally Tenere 700 side.jpg                                          | Wikisympathisant    | CC BY-SA 4.0  |
| `honda-cb650r-1.jpg`              | 2019 Honda CB650R (20190428).jpg                                                  | オーバードライブ83    | CC BY-SA 4.0  |
| `honda-cb650r-2.jpg`              | Honda CB650R at Sydney Harbor Bridge.jpg                                          | Salesberg           | CC BY-SA 4.0  |
| `honda-cb650r-3.jpg`              | 2023 Honda CB650R Standard.jpg                                                    | Chanokchon          | CC BY-SA 4.0  |
| `kawasaki-ninja-650-1.jpg`        | Kawasaki Ninja 650 2017.jpg                                                       | Sebastian6186       | CC BY-SA 3.0  |
| `kawasaki-ninja-650-2.jpg`        | Kawasaki Ninja 650 SlantView.jpg                                                  | サフィル             | CC BY-SA 4.0  |
| `kawasaki-ninja-650-3.jpg`        | Kawasaki Ninja 650 2020.jpg                                                       | A7N8X               | CC BY-SA 4.0  |
| `moto-guzzi-v7-stone-1.jpg`       | Moto Guzzi V7 Stone in Avellino.jpg                                               | Corvettec6r         | CC BY 4.0     |
| `moto-guzzi-v7-stone-2.jpg`       | Moto Guzzi V7 Stone Corsa.jpg                                                     | AVMOTO              | CC BY-SA 4.0  |
| `moto-guzzi-v7-stone-3.jpg`       | Moto Guzzi V7 Stone 105th Anniversary.jpg                                         | Guzzista76          | CC BY-SA 4.0  |
| `ktm-890-adventure-r-1.jpg`       | KTM 890 Adventure.jpg                                                             | Siechfred           | CC0           |
| `zero-srf-1.jpg`                  | Zero, BAS 24, Brussels (P1170327-RR).jpg                                          | Matti Blume         | CC BY-SA 4.0  |
| `triumph-bonneville-t120-1.jpg`   | Triumph Bonneville IMG 2728.jpg                                                   | Rama                | CC BY-SA 2.0 fr |
| `triumph-bonneville-t120-2.jpg`   | 2017 Bonneville T120 CSNDCC1.jpg                                                  | AmenMoto            | CC BY-SA 4.0  |
| `triumph-bonneville-t120-3.jpg`   | Triumph Bonneville T120 - 7742388010.jpg                                          | SG2012              | CC BY 2.0     |

Licence texts: [CC BY 2.0](https://creativecommons.org/licenses/by/2.0/), [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/), [CC BY-SA 2.0 fr](https://creativecommons.org/licenses/by-sa/2.0/fr/), [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/), [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/), [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

---

© 2026 fRESCA Bike Rentals. **Your Ride. Your Freedom.**
