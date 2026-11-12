# syntax=docker/dockerfile:1

# fRESCA Bike Rentals is one long-lived Node process, not a serverless app:
#
#   * the SQLite file and the uploaded images live on disk and change at runtime
#   * /api/events is a Server-Sent Events stream that must stay open
#   * a 60 second timer releases expired booking holds
#
# That is why Vercel (and any other platform without a persistent disk and a
# always-running process) cannot host it. See docs/deployment.md.

# ---------------------------------------------------------------------------
# Build stage
# ---------------------------------------------------------------------------
FROM node:22-bookworm-slim AS build

WORKDIR /app

# Playwright browsers are only needed for local end-to-end tests.
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
ENV npm_config_cache=/tmp/npm-cache

# Prisma's postinstall runs before the rest of the source is copied, so the
# schema, its config file and the postinstall guard have to be present first.
COPY package.json package-lock.json prisma7.config.ts ./
COPY prisma ./prisma
COPY scripts ./scripts
COPY backend/package.json ./backend/
COPY frontend/package.json ./frontend/
RUN npm ci

COPY backend ./backend
COPY frontend ./frontend

# Public Supabase Auth keys. Baking these in is safe because the publishable
# key is meant for browsers; the secret key is never used in the frontend.
# Railway exposes service variables to matching build arguments. When they are
# absent the SPA simply hides email sign-in instead of failing to boot.
ARG VITE_SUPABASE_URL
ARG VITE_SUPABASE_PUBLISHABLE_KEY
ARG VITE_SUPABASE_CAPTCHA_SITE_KEY
ENV VITE_SUPABASE_URL=$VITE_SUPABASE_URL \
    VITE_SUPABASE_PUBLISHABLE_KEY=$VITE_SUPABASE_PUBLISHABLE_KEY \
    VITE_SUPABASE_CAPTCHA_SITE_KEY=$VITE_SUPABASE_CAPTCHA_SITE_KEY

# Generates Prisma Client, compiles the API and builds the SPA.
RUN npm run build

# ---------------------------------------------------------------------------
# Runtime stage
# ---------------------------------------------------------------------------
FROM node:22-bookworm-slim AS runtime

WORKDIR /app

ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=8080 \
    DATABASE_PATH=/data/fresca.db \
    UPLOAD_DIR=/data/uploads

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/prisma ./prisma
COPY --from=build /app/backend/package.json ./backend/package.json
COPY --from=build /app/backend/dist ./backend/dist
COPY --from=build /app/frontend/dist ./frontend/dist

# Mount a persistent volume at /data so bookings, payments and uploads survive
# a redeploy. Without the volume every restart starts from an empty database.
RUN mkdir -p /data/uploads

# The API resolves ../frontend/dist from its working directory.
WORKDIR /app/backend

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=25s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||8080)+'/api/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

CMD ["node", "--disable-warning=ExperimentalWarning", "dist/index.js"]
