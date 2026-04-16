# Molly Infrastructure — Deployment Runbook

> **Last updated:** 2026-04-17
> **Project:** molly-infra
> **Services covered:** molly-api, molly-astro, molly-ios, molly-android

---

## Table of Contents

1. [Service Overview](#service-overview)
2. [How to Deploy Each Service](#how-to-deploy-each-service)
3. [How to Roll Back](#how-to-roll-back)
4. [How to Check Logs](#how-to-check-logs)
5. [How to Restart Services](#how-to-restart-services)
6. [Common Troubleshooting Scenarios](#common-troubleshooting-scenarios)
7. [Emergency Contacts and Escalation](#emergency-contacts-and-escalation)

---

## Service Overview

| Service | Stack | Hosting | Deploy Trigger | Health Check |
|---------|-------|---------|---------------|--------------|
| molly-api | Node.js 22 / TypeScript / Hono | Railway | Push to `main` → CI → Deploy workflow | `GET /health` |
| molly-astro | Python 3.11 / FastAPI (astrology engine) | Railway | Push to `main` → CI → Deploy workflow | `GET /health` |
| molly-ios | Swift / Xcode | App Store (manual) | Manual Xcode Archive + TestFlight | n/a |
| molly-android | Kotlin / Gradle | Play Store (manual) | Manual `./gradlew bundleRelease` | n/a |

**GitHub repos:**
- `RyanMacMillanSoftware/molly-api`
- `RyanMacMillanSoftware/molly-astro`
- `RyanMacMillanSoftware/molly-ios`
- `RyanMacMillanSoftware/molly-android`

**Railway projects:** Both molly-api and molly-astro deploy to Railway. Check the Railway dashboard for service URLs and environment details.

---

## How to Deploy Each Service

### molly-api

Deployment is fully automated. Merging to `main` triggers the pipeline:

1. **CI workflow** runs on push to `main` — lint, typecheck, tests with Postgres.
2. On CI success, the **Deploy workflow** triggers automatically (`workflow_run`).
3. Deploy workflow:
   - Builds Docker image from `Dockerfile`
   - Pushes to GHCR: `ghcr.io/ryanmacmillansoftware/molly-api:latest` and `:<commit-sha>`
   - Runs `railway up --detach` to deploy the new image on Railway

**To deploy: push or merge a PR to `main`.** No manual steps required once `RAILWAY_TOKEN` is configured in GitHub Secrets.

**Required secret:** `RAILWAY_TOKEN` in `RyanMacMillanSoftware/molly-api` → Settings → Secrets and variables → Actions.

**Verify deployment:**
1. Go to GitHub Actions → Deploy workflow → confirm it succeeded
2. Visit the Railway dashboard → molly-api service → check the new deployment is active
3. Hit the health endpoint: `curl https://<molly-api-url>/health` — expect `200 OK`

### molly-astro

Same automated pipeline as molly-api:

1. **CI workflow** runs on push to `main` — ruff lint, pytest.
2. On CI success, **Deploy workflow** triggers.
3. Deploy workflow runs `railway up --detach` to deploy on Railway.

**Required secret:** `RAILWAY_TOKEN` in `RyanMacMillanSoftware/molly-astro` → Settings → Secrets and variables → Actions.

**Verify deployment:**
1. GitHub Actions → Deploy workflow → confirm success
2. Railway dashboard → molly-astro service → new deployment active
3. `curl https://<molly-astro-url>/health` — expect `200 OK`

### molly-ios

iOS deployments are manual (no automated pipeline for App Store/TestFlight):

1. Open `Molly.xcodeproj` in Xcode on a Mac with the Apple Developer certificate.
2. Select the target scheme `Molly` and set destination to `Any iOS Device`.
3. **Product → Archive** to create an `.xcarchive`.
4. In the Organizer, click **Distribute App** → App Store Connect.
5. Submit for TestFlight review or direct release.

**CI only validates** on PR/push — it does not release to the App Store.

### molly-android

Android deployments are manual:

1. Run `./gradlew bundleRelease` to produce a signed AAB in `app/build/outputs/bundle/release/`.
2. Upload the AAB to the Google Play Console → select the target track (Internal, Alpha, Beta, Production).
3. Submit for review or rollout.

**CI only validates debug builds** — it does not release to the Play Store.

---

## How to Roll Back

### molly-api and molly-astro (automated rollback via git)

**Option A — Revert the bad commit (recommended, keeps history clean):**

```bash
git clone https://github.com/RyanMacMillanSoftware/molly-api  # or molly-astro
cd molly-api
git log --oneline -10          # Find the bad commit SHA
git revert <bad-commit-sha>    # Creates a new revert commit
git push origin main           # Triggers CI → Deploy automatically
```

The revert commit pushes to `main`, CI runs, and on success the Deploy workflow redeploys the previous code.

**Option B — Railway instant rollback (fastest, no git needed):**

1. Railway dashboard → select the service (molly-api or molly-astro)
2. Click **Deployments** tab
3. Find the last good deployment
4. Click **Redeploy** on that deployment

This redeploys the previously built image without waiting for CI. Use this for immediate incidents.

**Option C — Docker image rollback (for molly-api):**

The GHCR registry stores images tagged by commit SHA. To redeploy a specific image:

```bash
railway up --image ghcr.io/ryanmacmillansoftware/molly-api:<previous-commit-sha> --detach
```

Requires Railway CLI and `RAILWAY_TOKEN` set locally.

### molly-ios rollback

Submit a previous build from App Store Connect → TestFlight. For App Store releases, use App Store Connect's phased rollout controls or submit the previous version for expedited review.

### molly-android rollback

In Google Play Console, halt the current release and promote the previous release. Under the target track, click **Halt rollout**, then navigate to the previous release and **Re-release**.

---

## How to Check Logs

### molly-api and molly-astro (Railway)

**Via Railway dashboard:**
1. Railway dashboard → select service → **Logs** tab
2. Filter by time range or search for error patterns

**Via Railway CLI:**
```bash
npm install -g @railway/cli  # if not installed
railway login
railway logs                 # streams live logs for the linked service
railway logs --tail 200      # last 200 lines
```

**Structured log fields** (molly-api uses pino):
- `level`: `info`, `warn`, `error`, `fatal`
- `msg`: human-readable message
- `req.method`, `req.url`, `res.statusCode`, `responseTime`
- `err.message`, `err.stack` on errors

**Key log patterns to watch:**
```
# Startup failures
"Config validation failed"      → missing required env var
"Database connection failed"    → Postgres unreachable

# Runtime errors
"level":"error"                 → application error
"level":"fatal"                 → process crash

# Health check
GET /health 200                 → healthy
GET /health 500                 → unhealthy — check dependencies
```

**Via GitHub Actions logs:**
Navigate to GitHub → Actions → select the failed workflow run → expand failing step.

### molly-ios

- **Crash logs:** Xcode → Window → Devices and Simulators → View Device Logs
- **Production crashes:** App Store Connect → Crashes (via MetricKit)
- **TestFlight:** App Store Connect → TestFlight → Crashes

### molly-android

- **Logcat (device):** `adb logcat -s Molly`
- **Production crashes:** Google Play Console → Android vitals → Crashes & ANRs
- **Firebase Crashlytics** (if integrated): Firebase Console → Crashlytics

---

## How to Restart Services

### molly-api and molly-astro (Railway)

Railway's `railway.toml` is configured with:
```toml
[deploy]
restartPolicyType = "on_failure"
restartPolicyMaxRetries = 3
```

The service auto-restarts on crash (up to 3 times). For a manual restart:

**Via Railway dashboard:**
1. Railway dashboard → select service
2. Click **...** (more options) → **Restart**

**Via Railway CLI:**
```bash
railway redeploy --detach    # Redeploys the current image (triggers a restart)
```

**Verify service came back up:**
```bash
curl https://<service-url>/health
# Expect: 200 OK with JSON body
```

If the service refuses to start after 3 auto-restart attempts, Railway stops retrying. Check logs for the root cause before restarting again.

---

## Common Troubleshooting Scenarios

### Deploy workflow not triggering after merge to main

**Cause:** The `workflow_run` trigger only fires when the CI workflow completes on `main` — not on PR branches.

**Check:**
1. GitHub → Actions → CI workflow → confirm it ran on the `main` branch and succeeded
2. GitHub → Actions → Deploy workflow → check if it was triggered

**If CI failed:** Fix the failing test/lint/typecheck and push again.
**If CI passed but Deploy didn't trigger:** Check if the RAILWAY_TOKEN secret is set (missing secret causes the deploy step to fail, not skip).

### Railway deploy succeeds but health check returns 500

**Check order:**
1. Railway logs for startup errors
2. Verify all required env vars are set in Railway service settings (compare against `.env.example`)
3. Check database connectivity:
   - Postgres: `DATABASE_URL` must include `sslmode=require` in production
   - Neo4j: `NEO4J_URI` and `NEO4J_PASSWORD` must be set
   - Qdrant: `QDRANT_URL` and `QDRANT_API_KEY` must be set

**Common missing vars for molly-api:**
- `DATABASE_URL` (Postgres with SSL)
- `NEO4J_URI` / `NEO4J_PASSWORD`
- `QDRANT_URL` / `QDRANT_API_KEY`
- `ANTHROPIC_API_KEY`
- `JWT_SECRET` (min 32 chars)
- `APPLE_*` vars (for Sign in with Apple)
- `GOOGLE_CLIENT_ID`
- `REVENUECAT_WEBHOOK_SECRET`

**Common missing vars for molly-astro:**
- `HOST=0.0.0.0` (must be set for Railway to reach the service)
- `PORT` (Railway sets this automatically via `$PORT`)

### RAILWAY_TOKEN secret is missing or expired

**Symptom:** Deploy workflow fails at the `railway up` step with auth error.

**Fix:**
1. Railway dashboard → Service → Settings → Tokens → generate a new token
2. GitHub → repo Settings → Secrets and variables → Actions → update `RAILWAY_TOKEN`
3. Re-run the failed Deploy workflow (or push a new commit)

### Docker image build fails (molly-api)

**Symptom:** GitHub Actions Deploy workflow fails at the `Build and push Docker image` step.

**Check:**
1. Look at the build step output for the specific error
2. Common causes: missing `Dockerfile`, build context issues, base image pull failure

**Fix:** Address the Dockerfile issue locally:
```bash
docker build -t molly-api .   # Reproduce the failure locally
```
Then push the fix to main.

### Tests fail in CI, blocking deploy

**Symptom:** CI fails → Deploy workflow never triggers.

**Fix:**
1. Reproduce locally:
   ```bash
   # molly-api
   npm ci && npm run lint && npm run typecheck && npm test -- --run

   # molly-astro
   pip install -e ".[dev]" && ruff check && pytest
   ```
2. Fix the failing test/lint issue
3. Push to main

### Service is up but behaving incorrectly (no crash)

1. Check recent deployments: did something merge recently? (`git log --oneline -10`)
2. Check Railway logs for `warn` or `error` level entries
3. If a specific feature is broken, check if its required external service is reachable (Anthropic API, RevenueCat, Firebase)
4. Consider reverting the last merge if the regression is clear

---

## Emergency Contacts and Escalation

### Escalation Levels

| Severity | Condition | Response |
|----------|-----------|----------|
| **P0 — Critical** | Production is completely down (both molly-api and molly-astro returning 5xx / unreachable) | Immediate rollback via Railway dashboard; page on-call |
| **P1 — High** | Core feature broken for all users (auth, AI responses, astrology engine) | Rollback within 30 min; alert team |
| **P2 — Medium** | Degraded functionality (slow responses, partial feature outage) | Fix forward or rollback within 2 hours |
| **P3 — Low** | Minor issue, workaround exists | Normal sprint cycle |

### Immediate Response Steps (P0)

1. **Verify the outage:** `curl https://<service>/health` — is it really down?
2. **Check Railway dashboard:** Is the service running? Any recent failed deployments?
3. **Rollback immediately** (Option B — Railway instant rollback above) — don't wait for root cause
4. **Verify recovery:** Health check returns 200
5. **Then investigate root cause** in logs and git history

### Contacts

| Role | Contact | When to use |
|------|---------|------------|
| Engineering lead | Ryan MacMillan (@RyanMacMillanSoftware) | All P0/P1 incidents |
| Railway support | railway.app/help | Railway platform issues (not app bugs) |
| GitHub Status | githubstatus.com | If GitHub Actions / GHCR is down |
| Anthropic API status | status.anthropic.com | If AI features are failing |

### Gas Town Escalation (for autonomous agents)

If a Gas Town agent detects a deployment failure or infrastructure issue:

```bash
gt escalate -s HIGH "Deploy: <brief description of failure>"
# or for total outage:
gt escalate -s CRITICAL "Deploy: production down — molly-api health check failing"
```

The Mayor receives all escalations. CRITICAL ones also notify the Overseer.
