import { existsSync } from 'node:fs';
import { resolve } from 'node:path';
import { defineConfig } from 'prisma/config';

// Prisma 7 does not load .env automatically. Reuse the same root .env that the
// API reads so there is only one place to keep database credentials.
const envFile = resolve(process.cwd(), '.env');
if (existsSync(envFile)) process.loadEnvFile(envFile);

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
  },
  datasource: {
    // Prisma CLI commands (migrate, db pull, studio) use the session pooler.
    // The app's Prisma Client uses DATABASE_URL through the pg adapter.
    //
    // `npm run prisma:*` goes through scripts/prisma-cli.mjs, which exports
    // PRISMA_TUNNEL_DIRECT_URL so the CLI talks to a verified local tunnel
    // instead of hitting the Supabase TLS handshake directly. Running the
    // CLI by hand falls back to the plain .env URL.
    url:
      process.env.PRISMA_TUNNEL_DIRECT_URL ??
      process.env.DIRECT_URL ??
      process.env.DATABASE_URL ??
      '',
  },
});
