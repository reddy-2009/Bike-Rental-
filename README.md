# fRESCA Bike Rentals

A motorcycle-rental application for riders, studio staff and the people running the fleet. Customers browse a maintained catalogue, check live availability, reserve with server-calculated pricing and pay at checkout. Staff manage pickups and returns. Administrators approve bookings, handle refunds, manage the fleet and edit the public site.

The repository is an npm-workspace monorepo with a React + TypeScript frontend and an Express + SQLite API. The database seeds itself with the five-motorcycle fleet and one administrator account the first time the server starts.

---

## Highlights

**For riders**

- Search-first catalogue with category, price, location, availability and sort filters
- Motorcycle detail pages with galleries, specifications, live availability and instant quotes
- Date-aware reservations with server-side conflict checks, so the same motorcycle cannot be booked twice
- Mobile number collected at registration and required before booking. There is no self-service password reset
- Sandbox payment flow: paid bookings become `pending_approval`, then an administrator confirms or rejects them
- Rider dashboard, approval/refund timeline, downloadable calendar invites and self-service cancellation with gateway refunds
- Profile details, password changes, communication preferences and saved session

**For staff**

- Daily operations desk: pickups, returns due, overdue motorcycles and live fleet status
- Check motorcycles out and back in, and cancel before pickup with a clear audit trail
- Record cash or card-terminal payments at the counter, which moves the booking to admin approval
- Searchable, filterable booking table with lifecycle-aware actions

**For admins**

- Secure **Admin Access** gate (server-verified password, rate limiting, hashed storage, HTTP-only session)
- Approve or reject paid reservations after an automatic availability re-check; rejections trigger the refund workflow
- Refund queue with retry and confirm controls, provider references and `Refund Failed` visibility
- Revenue by month, booking pipeline, weekly reservations and fleet-health charts
- Top-performing motorcycles, customer counts and utilisation metrics, all computed from live records
- Fleet management with create, edit, maintenance, retire and safe archive of motorcycles with history
- Rider and role management with self-demotion protection
- Coupon management with percent and fixed discounts, usage limits and expiry dates
- **Website customisation panel**: colours, fonts, copy, FAQs, terms, logo and optional images, live draft preview, save/publish and reset

**Platform**

- 18 application routes plus privacy and rental-terms pages, with a designed 404
- Central CSS-variable theme loaded from SQLite at startup, with safe defaults if settings cannot be read
- Accessible forms, inline validation, loading states, toasts and empty states
- Responsive layouts for mobile, tablet and desktop; no horizontal page overflow
- Live booking updates over Server-Sent Events: riders see their booking change, staff and admins see every new and updated booking without refreshing
- The SQLite payment ledger is mirrored into Supabase on every change, so the real payments are visible in Postgres without changing the booking flow
- HTTP-only cookie sessions, scrypt password hashing, Zod request validation and parameterised SQL
- Poppins and Inter from Google Fonts by default, with Lucide icons bundled locally
- Native date pickers, focus states, short hover colour transitions and `prefers-reduced-motion` support
- Neutral grey placeholder with the motorcycle name when a photo is unavailable

---

## Calendar theme

Date fields use a dedicated `.calendar-input` style with `color-scheme: light`, a `#FFFFFF` background, dark text and light-grey borders. The native date-picker popup therefore stays white in both light and dark system themes, including on the home search, the fleet filters and the reservation form. The brand gold accent is used for focus, today and the selected date. Date validation, availability checks, pricing, reservations and admin date controls are unchanged.

## Motorcycle fleet

The fleet has five bikes, one of each model. Three are at the Kadapa studio near New Bus Stand and two are at the Proddatur branch at One Town Police Station.

| Motorcycle                    | Category  | Branch     | Daily   | Weekly (7 days) | Monthly (30 days) |
| ----------------------------- | --------- | ---------- | ------- | --------------- | ----------------- |
| BMW R 1250 GS Adventure       | Adventure | Kadapa     | ₹1,800  | ₹12,600         | ₹54,000           |
| Ducati Panigale V4            | Sport     | Kadapa     | ₹2,000  | ₹14,000         | ₹60,000           |
| KTM 890 Adventure R           | Adventure | Proddatur  | ₹1,800  | ₹12,600         | ₹54,000           |
| Harley-Davidson Sportster S   | Cruiser   | Kadapa     | ₹1,200  | ₹8,400          | ₹36,000           |
| Moto Guzzi V7 Stone           | Cruiser   | Proddatur  | ₹1,200  | ₹8,400          | ₹36,000           |

Every bike is available to book. All rates are in Indian rupees (INR). Weekly and monthly prices are the daily rate multiplied by 7 and 30 days, before the service fee and GST. The checkout quote always recalculates the total on the server.

Category daily rates used when adding a bike in the admin dashboard:

| Category  | Daily rate |
| --------- | ---------- |
| Adventure | ₹1,800     |
| Cruiser   | ₹1,200     |
| Electric  | ₹1,650     |
| Naked     | ₹900       |
| Retro     | ₹1,100     |
| Sport     | ₹2,000     |

---

## Tech stack

| Layer     | Technology                                                                 |
| --------- | -------------------------------------------------------------------------- |
| Frontend  | React 19, TypeScript, Vite 6, React Router 7, Tailwind CSS 4, Lucide React |
| Backend   | Node.js 22, Express 4, Zod, `node:sqlite`                                  |
| Auth      | Signed HS256 JWT in an HTTP-only, SameSite=Lax cookie; scrypt passwords    |
| Styling   | Tailwind v4 + CSS custom properties; Poppins/Inter by default, five selectable Google Fonts |
| Database  | SQLite file created automatically at `backend/data/fresca.db`              |

No native database bindings are required. The API uses Node's built-in SQLite driver.

---

## Project structure

```text
fresca-bike-rentals/
├─ backend/
│  ├─ src/
│  │  ├─ db/            # schema, connection, seed and reset CLI
│  │  ├─ lib/           # pricing, dates, auth, email, payments, refunds, site theme
│  │  ├─ middleware/    # authentication, admin-gate and role guards
│  │  ├─ routes/        # auth, bikes, bookings, payments, staff, admin, site, events
│  │  ├─ app.ts         # Express app, security headers, static SPA serving
│  │  └─ index.ts       # startup, seeding and graceful shutdown
│  ├─ data/             # generated SQLite database (git-ignored)
│  └─ uploads/site/     # uploaded logo and optional images (git-ignored)
├─ frontend/
│  ├─ public/images/    # motorcycle photography
│  └─ src/
│     ├─ components/    # layout, booking, UI primitives
│     ├─ context/       # auth, toasts, live updates, live site theme
│     ├─ hooks/         # data-loading hooks
│     ├─ lib/           # API client, formatting, shared types, default theme
│     ├─ pages/         # every route, incl. admin approvals + customisation
│     └─ styles/        # Tailwind v4 theme and design-system classes
├─ prisma/               # schema, TLS tunnel config, Supabase CA
├─ supabase/             # CLI config and SQL migrations
├─ e2e/                  # Playwright checks
├─ .env.example
└─ package.json          # workspace scripts
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

To serve the built app on the same stable link instead of the Vite dev server:

```bash
npm run build
npm run start:5173
```

`npm run start:5173` serves `frontend/dist` from the Express API on port 5173. Plain `npm start` uses `PORT` from `.env`, which is 4000.

Vite proxies `/api` to the Express server, so cookies work as same-origin during development. The first API start creates and seeds the database automatically.

The API binds to `0.0.0.0` by default so a phone on the same Wi-Fi can reach the app. Set `HOST=127.0.0.1` if you want to restrict it to the laptop only.

### Supabase client

The frontend has a lazily loaded browser Supabase client in `frontend/src/lib/supabase.ts`. The booking, payment, auth and admin flows still use the Express API and SQLite. Supabase Auth is used only for the optional email sign-in code, which is verified by the API before the normal fRESCA session is issued.

```bash
cp frontend/.env.example frontend/.env
```

Set the project URL, **publishable** key and Turnstile site key:

```dotenv
VITE_SUPABASE_URL=https://<project-ref>.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
VITE_SUPABASE_CAPTCHA_SITE_KEY=0x4AAAAAAA...
```

Load the client with `getSupabase()` rather than importing it at the top level:

```ts
import { getSupabase } from './lib/supabase';

const supabase = await getSupabase();
const { data, error } = await supabase.auth.getSession();
```

Email sign-in stays hidden unless all three values are present, because a request without the Turnstile site key is rejected by Supabase while CAPTCHA protection is enabled. It also needs custom SMTP and a Supabase Auth identity for each rider; see `docs/email-templates/`.

Only `VITE_` variables reach the browser. Never put a secret, `service_role` or Turnstile **secret** key in a `VITE_` variable; access is controlled by Row Level Security.

### Supabase on the backend

`@supabase/server` is installed in the backend for routes that need to verify Supabase users or query Supabase directly. Add the project values to the root `.env`:

```dotenv
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
SUPABASE_SECRET_KEY=sb_secret_...
SUPABASE_JWKS_URL=https://<project-ref>.supabase.co/auth/v1/.well-known/jwks.json
SUPABASE_DB_URL=postgresql://postgres:<password>@db.<project-ref>.supabase.co:5432/postgres?sslmode=require
```

`SUPABASE_SECRET_KEY` bypasses Row Level Security. Keep it in the server environment only. If it is missing, `supabaseAdmin()` reports `MISSING_DEFAULT_SECRET_KEY` instead of silently falling back to a weaker key. No current route calls `supabaseAdmin()`, so the key is optional and is removed from `.env` by default. To rotate it, create a new secret key in the Supabase dashboard under Project Settings > API Keys, replace the value, and revoke the old key there. Removing the value locally does not invalidate a leaked key; only revoking it in the dashboard does.

`SUPABASE_DB_URL` is the direct Postgres connection used by `@supabase/server`'s Postgres middleware, which needs `pg` (already installed). Percent-encode special characters in the password before adding it, for example `@` becomes `%40` and `#` becomes `%23`. The direct host `db.<project-ref>.supabase.co` resolves to IPv6 only, so networks without IPv6 should use the Supabase pooler connection string instead (Project Settings > Database > Connection string).

Helpers live in `backend/src/lib/supabase.ts`:

```ts
import { verifySupabaseUser, supabaseForUser, supabaseAdmin } from './lib/supabase';

// Verify Authorization: Bearer <supabase-access-token>
const { data: auth, error } = await verifySupabaseUser(req);
if (error) return res.status(error.status).json({ error: error.message });

// RLS-scoped client for that user
const supabase = supabaseForUser(auth.token);

// Privileged client for server-only work
const admin = supabaseAdmin();
```

These helpers are opt-in. The existing rider, staff and admin sessions continue to use the app's own JWT cookie, so no current route changes behavior.

### Supabase email templates

Five branded emails are ready to paste into the Supabase dashboard in `docs/email-templates/`. Each has an HTML body, a plain-text version, and the folder README lists every subject line, variable, URL setting and SMTP step:

```text
docs/email-templates/confirm-signup.html             # Confirm signup
docs/email-templates/magic-link.html                 # Magic link sign-in
docs/email-templates/verify-code.html               # Verification code (shows .Token)
docs/email-templates/verification-method-added.html  # Security notice
docs/email-templates/verification-method-removed.html # Security notice
```

The confirm-signup template keeps Supabase's `{{ .ConfirmationURL }}` and `{{ .Email }}` variables. Security notices never contain `.ConfirmationURL`, `.Token` or `.TokenHash`; the verification-code email shows `.Token` because that value is the code the rider types. These templates only change the emails Supabase Auth sends. The app's own registration and sign-in use its cookie session, and SMS OTP is no longer part of either flow.

### Prisma

Prisma 7 is installed at the repository root with the `prisma-client` generator. The generated client lives in `backend/src/generated/prisma` (gitignored) and the backend talks to Postgres through `@prisma/adapter-pg` plus `pg`, so the runtime uses the same verified TLS path as the rest of the Node code.

Add both URLs to the root `.env`. `DATABASE_URL` is the transaction pooler used by the app, and `DIRECT_URL` is the session pooler used by CLI commands:

```dotenv
DATABASE_URL="postgresql://postgres.<project-ref>:<password>@aws-0-<region>.pooler.supabase.com:6543/postgres?pgbouncer=true"
DIRECT_URL="postgresql://postgres.<project-ref>:<password>@aws-0-<region>.pooler.supabase.com:5432/postgres"
```

Percent-encode special characters in the password. Use the exact pooler host from Supabase Dashboard > Connect. The direct host `db.<project-ref>.supabase.co` is IPv6 only, so IPv4 networks need the session pooler.

```bash
npm run prisma:validate   # schema syntax
npm run prisma:generate   # regenerate backend/src/generated/prisma
npm run prisma:pull       # introspect existing tables into the schema
npm run prisma:migrate    # create and apply a migration
npm run prisma:studio     # browse the database
npm run prisma:ping       # select 1, to confirm credentials
```

Prisma 7.10 declares Node `^22.18.0 || ^24.11.0 || >=26.0.0`. The commands work on the current Node 22.14 install, but move to a supported release for long-term use.

`npm run prisma:pull` reports `P4001` while the `public` schema has no tables. That was true before the first migration; the schema is now applied and `prisma:pull` introspected all 15 tables into `prisma/schema.prisma`. Run it again after any schema change and then regenerate the client.

Prisma's Rust schema engine cannot complete a TLS handshake with Supabase's shared pooler on some networks, even though Node can with the project's root CA. The `prisma:*` database scripts therefore start a local TLS-terminating tunnel (`scripts/prisma-tunnel.mjs`) and point the CLI at `127.0.0.1`:

```text
Prisma --plaintext--> 127.0.0.1 --> TLS, CA verified --> Supabase pooler
```

Only the loopback hop is plaintext; the network hop is verified against `prisma/supabase-ca.crt`. To run the tunnel by hand, use `npm run prisma:tunnel` and set `DIRECT_URL` to `postgresql://postgres.<project-ref>:<password>@127.0.0.1:6543/postgres?sslmode=disable`. Refresh `prisma/supabase-ca.crt` from Database Settings > SSL Configuration if Supabase rotates the CA.

### Supabase database schema

The hosted Supabase project has the full fRESCA schema applied: 15 tables, 44 indexes, row level security on every table, and zero policies. The tables mirror `backend/src/db/schema.ts` plus the in-place columns from `backend/src/db/index.ts` (`bookings.discount_cents`, `bookings.coupon_code`, `booking_events.actor`, `users.phone_verified`, `users.token_version`). The Express API still runs on SQLite; this schema is the migration target.

- `supabase/migrations/20261104141947_initial_schema.sql` is the initial migration. It is idempotent (`create table if not exists`, `create index if not exists`), so it can be re-run safely.
- Emails and coupon codes are unique case-insensitively through unique indexes on `lower(email)` and `lower(code)`. When the API moves to Postgres, query with `lower(...)` instead of SQLite's `COLLATE NOCASE`.
- Tables are owned by the server-only `prisma` role, which has `BYPASSRLS`. `anon` and `authenticated` have no table privileges and no policies, so the Data API cannot read or write these tables. `postgres` and `service_role` keep DML access for the dashboard and server-side tooling.
- Add explicit policies in a later migration before the SPA reads Supabase directly.

#### Supabase mirror ledger

SQLite remains the source of truth. When `SUPABASE_DB_URL` is present, the API mirrors the five related tables (`users`, `bikes`, `bookings`, `payments`, `refunds`) into Supabase so the real payment ledger is available there.

- `backend/src/lib/supabase-ledger.ts` uses a small `pg` pool and verifies the pooler with the project CA at `prisma/supabase-ca.crt` (override with `SUPABASE_CA_PATH`).
- A full reconcile runs at startup and every 60 seconds. Every booking, payment, refund, user and bike change also queues the affected row immediately.
- Rows are upserted by their local `id` in foreign-key order. Identity sequences are repaired after each batch, so a future Postgres insert cannot collide with a mirrored id.
- The mirror is fail-open and non-blocking. A network error, paused project or rotated password logs at most one warning per minute and retries with backoff. Booking, payment, refund and auth responses are never delayed or failed because of it.
- A row that is missing locally is deleted from the mirror. Deletes that would break a foreign key are skipped and retried on the next reconcile.
- The `users` copy includes `password_hash`, so treat the database URL and the `prisma` role password as production secrets. The table keeps RLS enabled with no policies, and `anon` and `authenticated` have no privileges.
- Set `SUPABASE_LEDGER=0` to turn the mirror off. It never runs in tests, because the test server loads the app without starting the ledger.

Supabase CLI v3 is local by default. To target the hosted project, pass `--remote` and `--yes`:

```powershell
$env:SUPABASE_DB_URL = "postgresql://prisma.<project-ref>:<password>@aws-0-<region>.pooler.supabase.com:5432/postgres"
npx supabase migration new add_feature
npx supabase db push --remote="$env:SUPABASE_DB_URL" --yes
npx supabase migration list --remote="$env:SUPABASE_DB_URL"
```

`supabase db push` records applied versions in `supabase_migrations.schema_migrations`. Creating that schema needs `CREATE` on the database, which the `prisma` role does not have. Run this once in the Supabase SQL editor as the project owner, then push again:

```sql
create schema if not exists supabase_migrations;
grant usage, create on schema supabase_migrations to prisma;
```

If the migration was applied directly before its history row existed, re-running the idempotent file is safe. `npx supabase link --project-ref <ref>` and `npx supabase login` are only needed for dashboard-backed commands; a `--remote` database URL works without them.

### Open it on your phone (same Wi-Fi)

Both devices must be on the same trusted local network. Find the laptop's IPv4 address with `ipconfig` (or `Get-NetIPAddress -AddressFamily IPv4` in PowerShell) and use the port that matches how you started the app:

| Mode | Laptop URL | Phone URL |
| ---- | ---------- | --------- |
| `npm run dev` (Vite + API) | <http://localhost:5173> | `http://<laptop-ip>:5173` |
| `npm run build` then `npm start` (built app) | <http://localhost:4000> | `http://<laptop-ip>:4000` |

For example, on the current machine the addresses are <http://localhost:5173> / <http://localhost:4000> on the laptop and `http://10.220.156.197:5173` / `http://10.220.156.197:4000` from a phone. The IP changes when you switch networks.

If Windows Firewall prompts, allow **Private** or **Public** access for Node.js, since the app is served by `node.exe`. To add the rules explicitly, open PowerShell **as administrator**:

```powershell
netsh advfirewall firewall add rule name="fRESCA 4000" dir=in action=allow protocol=TCP localport=4000
netsh advfirewall firewall add rule name="fRESCA 5173" dir=in action=allow protocol=TCP localport=5173
```

Keep the network trusted: anyone who can reach port 4000 or 5173 can open the public site. Account, staff and admin pages still require sign-in, and the admin dashboard also requires the admin gate.

### If you see `ERR_CONNECTION_REFUSED`

That error means nothing is listening on the URL's port. It is not an authentication failure.

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
| `JWT_SECRET`                | development fallback     | **Required in production**: unique, 32+ characters; also signs payment tokens |
| `ADMIN_ACCESS_PASSWORD`     | `9989`                   | **Required in production**: server-side admin dashboard password, hashed into SQLite on startup |
| `ADMIN_ACCESS_EMAIL`        | owner email              | Admin account used when the access gate signs someone in                |
| `DATABASE_PATH`             | `backend/data/fresca.db` | Override the SQLite file location                                       |
| `SUPABASE_DB_URL`           | none                     | Postgres connection string for the mirror ledger; empty disables it     |
| `SUPABASE_CA_PATH`          | `prisma/supabase-ca.crt` | CA certificate used to verify the Supabase pooler                       |
| `SUPABASE_LEDGER`           | `1` when a DB URL is set | `0` disables the Supabase mirror                                       |
| `SUPABASE_LEDGER_INTERVAL_MS` | `60000`                | Full reconcile interval; values below `15000` are raised to `15000`    |
| `PUBLIC_BASE_URL`           | request host             | Public HTTPS origin used for gateway return/webhook URLs                |
| `PAYMENTS_SIMULATOR`        | on outside production    | `1` shows unconfigured gateway simulators; `0` hides them. Forced off in production |
| `PHONEPE_CLIENT_ID`         | none                     | PhonePe merchant client id (enables live PhonePe)                       |
| `PHONEPE_CLIENT_SECRET`     | none                     | PhonePe merchant client secret                                          |
| `PHONEPE_CLIENT_VERSION`    | `1`                      | PhonePe OAuth client version                                            |
| `PHONEPE_ENV`               | `sandbox`                | `production` switches to the live PhonePe hosts                          |
| `PHONEPE_WEBHOOK_USER`      | none                     | SHA webhook user for `/api/payments/webhook/phonepe`                    |
| `PHONEPE_WEBHOOK_PASSWORD`  | none                     | SHA webhook password for the PhonePe webhook                            |
| `PHONEPE_REFUND_URL`        | PG v2 default            | Optional override for the PhonePe refund endpoint                       |
| `PAYTM_MID`                 | none                     | Paytm merchant id (enables live Paytm)                                  |
| `PAYTM_MERCHANT_KEY`        | none                     | Paytm merchant key used for AES checksums                               |
| `PAYTM_WEBSITE`             | `WEBSTAGING`             | Paytm website code (`DEFAULT` or your live code in production)          |
| `PAYTM_INDUSTRY_TYPE`       | `Retail`                 | Paytm industry type id                                                  |
| `PAYTM_CHANNEL_ID`          | `WEB`                    | Paytm channel id                                                        |
| `PAYTM_ENV`                 | `staging`                | `production` switches to the live Paytm hosts                           |
| `PAYTM_REFUND_URL`          | none                     | Paytm refund endpoint; required for automatic rejection refunds         |

Shell variables take priority over values in the file. The backend looks for `.env` in the current directory first, then the parent directory.

---

## Administrator access

There are no public sample logins. The database creates one administrator row for `ADMIN_ACCESS_EMAIL` at seed time with a random password that is never printed. Administrators use the **Admin access** button on the sign-in page: enter the server-side `ADMIN_ACCESS_PASSWORD` and the API opens `/admin`.

The Admin Access gate is a second factor: any admin route and every `/api/admin/*` request also requires the verified `adminUnlocked` session. Wrong passwords return `Incorrect password. Please try again.` after server-side verification, and five failures per IP in 15 minutes are throttled. **Log out** clears the HTTP-only cookie. Change the gate password with `ADMIN_ACCESS_PASSWORD`; it is stored only as a scrypt hash.

Outside production, the test card checkout accepts any future expiry and CVC with the card **4242 4242 4242 4242**. No real charge is made and no card data is stored; the card form is disabled entirely when `NODE_ENV=production`. PhonePe and Paytm appear in the same checkout: with merchant keys present they open the real gateway; without keys they open the built-in simulator, where you can approve or decline a payment.

---

## Rider requirements

- Riders must be **21 or older** and hold a **full motorcycle licence** valid in the rental state, held for at least one year. Individual machines state their own minimum riding history (one to three years).
- A helmet is mandatory on every ride. A fitted helmet, riding gloves, breakdown cover and a pre-ride safety check are included in every rental.
- Bring your licence and photo ID to pickup; the studio cannot release a motorcycle without them.
- Pillions must be 18 or older and only ride on machines with a pillion seat and footpegs.
- Motorcycles must be returned with the same fuel level; a refuelling charge applies otherwise.

---

## Routes

Public browsing is enabled: anyone can open the home page, fleet, bike details and legal pages. Booking, account, staff and admin routes still require the appropriate sign-in.

| Route                    | Access          | Description                                              |
| ------------------------ | --------------- | -------------------------------------------------------- |
| `/login`                 | Public          | Sign in and admin access                                 |
| `/register`              | Public          | Rider registration                                       |
| `/`                      | Public          | Hero, search, featured motorcycles and FAQ               |
| `/bikes`                 | Public          | Searchable, filterable catalogue                         |
| `/bikes/:slug`           | Public          | Gallery, specs, availability and reservation             |
| `/legal/privacy`         | Public          | Privacy policy                                           |
| `/legal/terms`           | Public          | Rental terms                                             |
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
| `/admin/offers`          | Admin + gate    | Coupon management                                        |
| anything else            | Public          | Designed not-found page                                  |

Role-protected routes redirect unauthenticated visitors to `/login` and send signed-in users to the correct dashboard for their role.

---

## Scripts

Run from the repository root:

| Command                              | What it does                                                            |
| ------------------------------------ | ----------------------------------------------------------------------- |
| `npm run dev`                        | Start API (watch mode) and Vite dev server together                     |
| `npm run build`                      | Type-check and build the backend, then the frontend                     |
| `npm start`                          | Serve the built SPA and API from Express on port 4000                   |
| `npm run typecheck`                  | Type-check both workspaces without emitting files                       |
| `npm test`                           | Build the backend and run the API and logic test suites                 |
| `npm run test:e2e`                   | Run the Playwright end-to-end checks                                    |
| `npm run seed`                       | Seed the fleet and administrator if the database is empty               |
| `npm run seed -w backend -- --force` | Reset and reseed the database (destroys local data)                     |

---

## Booking and pricing rules

- The server is the single source of truth for money. The client may preview a quote, but totals are recalculated from the motorcycle's database rate on every create and pay request.
- Charges are the daily rate multiplied by billable days (minimum one day), plus a **₹99 service fee** and **18% GST**.
- Dates must be valid and in the future (or today), and the return date must be after pickup. Rentals are capped at 60 days.
- A rider must have a saved mobile number before a booking can be created. The number is no longer verified by SMS.
- Overlapping `pending_payment`, `pending_approval`, `confirmed` or `active` reservations are rejected for the same motorcycle.
- **Money and approval are separate state machines.** A booking keeps a `payment_status` (`unpaid`, `pending`, `paid`, `failed`, `refund_pending`, `refund_processing`, `refunded`, `refund_failed`) independent of its booking `status`.
- Booking lifecycle: `pending_payment → pending_approval → confirmed → active → completed`, with `cancelled` and `rejected` as terminal alternatives.
  1. Selecting a motorcycle and dates creates a `pending_payment` / `unpaid` booking. The dates are held for **30 minutes**.
  2. An unpaid hold is released automatically after 30 minutes, or after 24 hours if a gateway attempt is still in flight, so an abandoned checkout cannot block the calendar. The sweep runs on booking and availability reads plus a one-minute server timer.
  3. A successful gateway capture moves it to `pending_approval` / `paid`. It is **not** confirmed yet.
  4. An administrator approves the request. Approval re-checks availability inside a transaction, refuses overlaps, then sets `confirmed` and records the approver and timestamp.
  5. Rejection sets `rejected` and starts the refund workflow. The UI shows `Refund pending`, then `Refund processing`, then `Refunded` only after the gateway confirms the refund.
  6. If the refund cannot be issued, the booking shows `Refund failed` and appears in the admin refund queue.
- Staff can check a confirmed booking out (`active`) and back in (`completed`), and cancel before pickup. Staff cannot approve or reject.
- Customers can cancel `pending_payment`, `pending_approval` or `confirmed` bookings; paid cancellations follow the same refund workflow.
- Invalid transitions return a clear `409` or `400` instead of corrupting state; approvals are timestamped with the administrator's identity.
- Motorcycles with booking history are archived (retired) rather than deleted, preserving receipts and reporting.

---

## Payments (PhonePe, Paytm, sandbox card)

Checkout offers the gateways that are actually configured. The amount is always read from the booking row in SQLite; the browser can never choose what to charge.

| Method                  | How it works                                                                 |
| ----------------------- | ---------------------------------------------------------------------------- |
| Card (development only) | Sandbox authorisation with `4242 4242 4242 4242`; no processor, no card data stored |
| PhonePe                 | PG Standard Checkout v2: OAuth token, create order, hosted page, status API  |
| Paytm                   | Hosted checkout with the official AES-128-CBC + SHA-256 `CHECKSUMHASH`, then status API |

**Modes.** Each gateway reports `live` when its merchant credentials are present, and `simulator` otherwise. The simulator lives at `/pay/simulate` and issues a signed, tamper-proof hand-off token; approving it captures the payment exactly like a real gateway, but no money moves.

- Simulators default to **on outside production** and **off in production**. `PAYMENTS_SIMULATOR=1` can re-enable them in development; in production they stay closed.
- The sandbox card form and the `POST /bookings/:id/pay` route are available only outside production. In production the route returns `403` and the Card tab is hidden, so there is no browser path that marks a booking paid without a real capture.
- With `PAYMENTS_SIMULATOR=0`, gateways without credentials are hidden. A production deployment with no merchant keys therefore offers no online payment instead of a free one.

**Trust model.**

- The payment row is created server-side with the booking total before any redirect. Amounts must be positive integers in paise.
- Merchant order IDs combine a timestamp with 48 random bits, so concurrent checkouts and restarts cannot collide.
- The browser return (`/payments/return/...`) and provider webhooks only *trigger* a check. The provider's signed status API decides `captured`, `pending` or `failed`.
- Paytm callbacks are checksum-verified with the merchant key. Invalid or missing checksums are ignored; the browser return still falls back to the status API instead of trusting the payload.
- PhonePe webhooks can be protected with `PHONEPE_WEBHOOK_USER` and `PHONEPE_WEBHOOK_PASSWORD`; PhonePe sends the hex SHA-256 digest of `username:password` in the `Authorization` header. The readiness check warns when they are absent.
- Capture writes the payment row, moves the booking to `pending_approval` + `paid`, and appends a booking event. It is idempotent, so duplicate webhooks cannot double-capture or double-charge.
- Approval is a **separate, admin-only** action after payment. A successful payment never confirms a booking by itself.
- Refunds are issued through the gateway refund API. PhonePe uses PG v2 `POST /payments/v2/refund` by default, with `PHONEPE_REFUND_URL` available as an override; Paytm needs `PAYTM_REFUND_URL`. A refund only becomes `refunded` when the provider confirms it; until then the booking shows `Refund processing`. Live PhonePe refunds are rechecked at `GET /payments/v2/refund/{merchantRefundId}/status` on later booking or admin reads (throttled) and when a `pg.refund.completed` or `pg.refund.failed` webhook arrives; the status API stays authoritative. If no refund endpoint is configured, the refund is recorded as `refund_failed` and surfaced in the admin queue.

**Ledger mirror.** Every payment and refund row, plus its booking, rider and bike parents, is mirrored into Supabase by `backend/src/lib/supabase-ledger.ts`. SQLite stays authoritative: a Supabase outage never blocks checkout, capture, cancellation or refund. See [Supabase mirror ledger](#supabase-mirror-ledger).

**Going live with real money.**

1. Set `PUBLIC_BASE_URL` to the exact public HTTPS origin, for example `https://fresca.example.com`. Production gateways refuse to start checkout without a reachable HTTPS origin.
2. Add `PHONEPE_CLIENT_ID` and `PHONEPE_CLIENT_SECRET` (plus `PHONEPE_ENV=production`) and/or `PAYTM_MID` and `PAYTM_MERCHANT_KEY` (plus `PAYTM_ENV=production`, your live `PAYTM_WEBSITE`, and a 16-byte merchant key).
3. PhonePe refunds use the PG v2 endpoint by default; set `PHONEPE_REFUND_URL` only if PhonePe gives you a different one. Set `PAYTM_REFUND_URL` for Paytm. Configure `PHONEPE_WEBHOOK_USER` and `PHONEPE_WEBHOOK_PASSWORD` to match the SHA credentials on the PhonePe webhook.
4. Register these URLs in the merchant dashboards:
   - PhonePe webhook: `https://<host>/api/payments/webhook/phonepe`
   - Paytm webhook: `https://<host>/api/payments/webhook/paytm`
   - PhonePe return: `https://<host>/api/payments/return/phonepe`
   - Paytm return: `https://<host>/api/payments/return/paytm`
5. Run in production with `NODE_ENV=production` and leave `PAYMENTS_SIMULATOR` unset or `0`.
6. Check `GET /api/payments/readiness` as staff or admin. It reports configured booleans and operator issues without printing secrets.
7. Run one small live transaction, confirm the booking moves to `pending_approval` with a provider reference, then issue a test refund.

---

## Live booking updates

`GET /api/events` is a Server-Sent Events stream authenticated by the same `fresca_session` cookie as the rest of the API. One connection per signed-in browser feeds the rider dashboard, My bookings, booking details, the staff desk and the admin booking queue.

- Riders receive only events for their own bookings. Staff and admins receive every booking event.
- Events cover booking created, payment captured or recorded, approval, rejection, cancellation, pickup, return, refund processing, refund completed and refund failure.
- Each screen refreshes silently, so tables keep their scroll position and do not flash a loading skeleton. A toast explains the change.
- The acting user is skipped, because their screen already updates from the mutation response.
- The server sends a heartbeat every 25 seconds and tells the browser to reconnect after 4 seconds if the connection drops.
- This is intentionally not Supabase Realtime. The app's JWT cookie is not a Supabase Auth session, and the runtime store is still SQLite, so Postgres triggers and `TO authenticated` Realtime policies would not observe or authorize these writes.

---

## API overview

All responses are JSON under `/api`. Authentication uses the `fresca_session` HTTP-only cookie.

| Area     | Endpoints                                                                                     |
| -------- | --------------------------------------------------------------------------------------------- |
| Auth     | `GET /auth/me`, `POST /auth/register`, `POST /auth/login`, `POST /auth/logout`, `POST /auth/admin-access`, `POST /auth/admin-lock`, `PATCH /auth/profile`, `POST /auth/password`, `PATCH /auth/preferences` |
| Bikes    | `GET /bikes`, `GET /bikes/filters`, `GET /bikes/:idOrSlug`, `GET /bikes/:idOrSlug/availability` |
| Bookings | `POST /bookings`, `GET /bookings`, `GET /bookings/:id`, `POST /bookings/:id/cancel`, `PATCH /bookings/:id/status` (staff), `POST /bookings/:id/record-payment` (staff) |
| Events   | `GET /events` (Server-Sent Events, signed-in users only)                                       |
| Payments | `GET /payments/methods`, `GET /payments/readiness` (staff), `POST /payments/bookings/:id/checkout`, `GET /payments/simulator/:token`, `POST /payments/simulator/:token/complete`, `GET /payments/return/phonepe`, `POST /payments/return/paytm`, `POST /payments/webhook/phonepe`, `POST /payments/webhook/paytm` |
| Staff    | `GET /staff/overview`, `GET /staff/stats`                                                    |
| Admin    | `GET /admin/overview`, `GET /admin/stats`, `GET /admin/users`, `PATCH /admin/users/:id/role`, `GET /admin/bikes`, `POST /admin/bikes`, `PATCH /admin/bikes/:id`, `DELETE /admin/bikes/:id`, `GET /admin/bookings`, `GET /admin/bookings/:id`, `POST /admin/bookings/:id/approve`, `POST /admin/bookings/:id/reject`, `GET /admin/refunds`, `POST /admin/refunds/:id/retry`, `POST /admin/refunds/:id/confirm`, `GET /admin/offers`, `POST /admin/offers`, `PATCH /admin/offers/:id`, `DELETE /admin/offers/:id` |
| Site     | Public `GET /site`; admin `GET /admin/site`, `PUT /admin/site/draft`, `POST /admin/site/publish`, `POST /admin/site/reset`, `POST /admin/site/upload` |

Errors use `{ "error": "message", "details": ... }` with appropriate `4xx` or `5xx` status codes. Invalid input is validated with Zod on the server and mirrored by inline client-side validation.

---

## Website customisation

Signed-in administrators reach the panel at **`/admin/customization`** (or via the Admin Dashboard). It is a six-tab editor:

1. **Colours**: primary, secondary, background, header/nav, footer, buttons and hover, text, headings, cards, borders and shadows, links, form fields and admin-dashboard colours. Every field has a colour picker and a HEX input.
2. **Fonts**: heading, body, navigation and button fonts (Poppins, Inter, Roboto, Montserrat, Open Sans), plus base size, heading scale, weight and line height.
3. **Website text**: site name, tagline, homepage eyebrow/heading/description, About, contact details, navigation labels, button text, bike headings, booking instructions, footer, FAQs, terms and the customer announcement. Each field has its own reset; required fields cannot be saved empty.
4. **Images & logo**: upload a logo, plus optional homepage background and About images (PNG/JPEG/WebP, max 2 MB, magic-byte checked). Both photo slots are empty by default; the site renders a plain background until an administrator uploads real studio or fleet photography. Each card shows "No image set" when empty and can be reset.
5. **Preview**: device-local live preview of the draft, including a mobile/desktop frame, before anything is published.
6. **Save & publish**: **Save changes** stores a draft (not live), **Cancel changes** discards unsaved edits, **Publish to live site** asks for confirmation and applies the draft site-wide. **Restore default design** resets colours, fonts, text and images.

All settings live in SQLite as versioned JSON. The public endpoint serves only the **published** configuration; the admin API serves the draft plus publication history. Saving, publishing and resetting require an unlocked admin session (`requireAdmin`), and every publish records the administrator's name and timestamp. The storefront applies the published values as CSS custom properties at runtime and loads the selected Google Fonts, so no source edits are needed. If settings cannot be loaded, the backend and frontend both fall back to a mirrored default theme. Editable content is length-limited and plain text, so no HTML or JavaScript is executed.

Business facts that must not be guessed live in `backend/src/lib/business-facts.ts`. The Kadapa studio near New Bus Stand and the Proddatur branch at One Town Police Station are set. The phone number, opening hours and security deposit remain `TODO` until the owner confirms them, and `TODO` values are hidden from customers.

---

## Production build

```bash
npm run build
NODE_ENV=production \
  JWT_SECRET="<32+ character random value>" \
  ADMIN_ACCESS_PASSWORD="<strong unique password>" \
  npm start
```

On Windows PowerShell:

```powershell
$env:NODE_ENV = "production"
$env:JWT_SECRET = "<32+ character random value>"
$env:ADMIN_ACCESS_PASSWORD = "<strong unique password>"
npm start
```

Production refuses to start if `JWT_SECRET` is missing, shorter than 32 characters, or still the development fallback, or if `ADMIN_ACCESS_PASSWORD` is missing or still `9989`.

The Express server serves `frontend/dist` with immutable caching for hashed assets, no-cache for HTML, and SPA fallback for client routes. API responses are always `Cache-Control: no-store`.

Before deploying:

1. Set a unique `JWT_SECRET` of at least 32 characters. Production will not start without it.
2. Set a unique `ADMIN_ACCESS_PASSWORD` (never the development default `9989`) and point `ADMIN_ACCESS_EMAIL` at the administrator account.
3. Terminate TLS in front of the app so secure cookies are delivered over HTTPS.
4. Persist the SQLite file (`DATABASE_PATH`) on durable storage, since it holds users, bookings, payments, refunds and the published website theme. Back it up.
5. Configure PhonePe and/or Paytm merchant keys plus refund endpoints (see [Payments](#payments-card-phonepe-paytm)) and set `PUBLIC_BASE_URL`.
6. There is no self-service password recovery. A forgotten password must be reset by an operator with database access, so keep `ADMIN_ACCESS_EMAIL` on a mailbox the owner controls and store passwords in a password manager.
7. Uploaded site images are written to `backend/uploads/site/`; put that directory on durable storage too.
8. Replace the `TODO` values in `backend/src/lib/business-facts.ts` with the confirmed address, phone number, opening hours and deposit amount.

### Where to host it

The app needs a persistent disk, a long-running process (Server-Sent Events at `/api/events` and the booking-hold timer) and stable HTTPS. Serverless platforms without those cannot run it, including Vercel, whose build also fails with `Could not load schema from '.../prisma/schema.prisma'` when the uploaded tree omits the `prisma/` folder.

Ready-made deployment files live in the repository root:

- `Dockerfile` and `.dockerignore` for any container host
- `railway.json` and `.railwayignore` for the live Railway service
- `render.yaml` for a Render blueprint with a `/data` disk
- `docker-compose.yml` for a VPS with a named volume

The app is currently deployed at <https://fresca-bike-rentals-production.up.railway.app>.
Step-by-step instructions, environment values and data migration are in [docs/deployment.md](docs/deployment.md).

---

## Resetting seed data

Stop the server, then run:

```bash
npm run seed -w backend -- --force
```

This recreates the schema and restores the five-motorcycle fleet plus the administrator row. Deleting `backend/data/fresca.db` and restarting also produces a fresh seed. Both also clear published website customisation (back to the default theme).

---

## Notes and limitations

- Card payments are a deliberate sandbox and are disabled entirely when `NODE_ENV=production`: details are validated in the browser, never stored, and no card processor is called. PhonePe and Paytm use the real gateway only when merchant credentials are configured; until then their simulator stands in, and only outside production.
- Refunds call the gateway refund API and only become `refunded` on provider confirmation. PhonePe uses its PG v2 refund endpoint by default (`PHONEPE_REFUND_URL` is an optional override); without a Paytm refund URL they are recorded as `refund_failed` and surfaced in the admin queue.
- Real gateway capture and refund calls were implemented against the published PhonePe PG Checkout v2 and Paytm hosted-checkout contracts, but cannot be executed end to end without live merchant credentials.
- SMS OTP is no longer used anywhere. Registration collects a mobile number without a verification code, and the booking gate only requires a saved number. Password recovery is not offered in the app; a forgotten password must be reset by an operator with database access.
- Website text is plain text and length-limited; there is intentionally no HTML or JavaScript editing.
- Motorcycle photography is bundled locally for reliable offline rendering. If a bike photo is missing or fails to load, the UI shows a neutral grey panel with the motorcycle name.
- The API is intentionally dependency-light; there is no ORM, external auth provider or general background job runner. Simulator refunds and live PhonePe refund status checks advance on the next booking or admin read, and a one-minute timer releases unpaid booking holds.
- This project is a working application, not a substitute for a PCI-compliant payment stack in production.

---

## Photo credits

Fleet photography was supplied by the site operator for use on this site. Source and licence details for the five supplied files are held by the operator. No image is used to imply an endorsement by the manufacturer or photographer.

---

© 2026 fRESCA Bike Rentals.
