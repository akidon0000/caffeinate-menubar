# Release & CI

This project ships three GitHub Actions workflows:

| Workflow | Trigger | What it does |
| --- | --- | --- |
| [`ci.yml`](../.github/workflows/ci.yml) | push to `main`, every PR | Generates the Xcode project, builds Release (ad-hoc signed), uploads the `.app` as a 7-day artifact. |
| [`release-app-store.yml`](../.github/workflows/release-app-store.yml) | tag `v*`, `workflow_dispatch` | Signs with Apple Distribution + Mac App Store profile, archives, exports a `.pkg`, uploads to App Store Connect. |
| [`xcode-version.yml`](../.github/workflows/xcode-version.yml) | weekly cron | Opens an issue when the macOS runner ships a newer Xcode than we're pinning. |

`dependabot.yml` is configured to grouped-bump GitHub Actions weekly. (No SPM deps yet — slot is ready in `.github/dependabot.yml` for when we add them.)

## One-time setup for App Store releases

You'll need an active **Apple Developer Program** membership and an app record created in **App Store Connect** (with the bundle id `com.akidon0000.CaffeinateMenuBar` or whatever you change it to).

### 1. Certificates & profile

In Xcode (locally), under Settings → Accounts:

1. Create an **Apple Distribution** certificate and export it as `.p12` with a password.
2. In the [Apple Developer portal](https://developer.apple.com/account/resources/profiles/list), create a **Mac App Store** provisioning profile bound to that certificate and your app id. Download the `.provisionprofile`.

### 2. App Store Connect API key

In [App Store Connect → Users and Access → Integrations → App Store Connect API](https://appstoreconnect.apple.com/access/api):

1. Create a key with **App Manager** role.
2. Download the `AuthKey_XXXXXXXXXX.p8` (you only get one chance).
3. Note the **Key ID** and **Issuer ID**.

### 3. GitHub Secrets

Add these under **Repo Settings → Secrets and variables → Actions** (preferably as an `appstore` Environment so they're gated by a manual approval):

| Secret | Value |
| --- | --- |
| `APPLE_TEAM_ID` | 10-char team id (e.g. `ABCDE12345`) |
| `BUILD_CERTIFICATE_BASE64` | `base64 -i Distribution.p12 | pbcopy` |
| `P12_PASSWORD` | the password you set when exporting the `.p12` |
| `PROVISIONING_PROFILE_BASE64` | `base64 -i profile.provisionprofile | pbcopy` |
| `KEYCHAIN_PASSWORD` | any throwaway string used only inside the runner |
| `APP_STORE_CONNECT_KEY_ID` | from step 2 |
| `APP_STORE_CONNECT_ISSUER_ID` | from step 2 |
| `APP_STORE_CONNECT_KEY_BASE64` | `base64 -i AuthKey_*.p8 | pbcopy` |

## Cutting a release

```bash
# Bump version in project.yml (MARKETING_VERSION) — optional; the workflow also
# accepts the tag as the marketing version.
git tag v1.0.1
git push origin v1.0.1
```

The `release-app-store.yml` workflow will pick the tag up, sign, archive, export, and upload. After it succeeds, finish the release in App Store Connect (release notes → submit for review).

To do a release-build dry run without uploading, trigger the workflow via **Actions → Release to App Store → Run workflow** in a branch without the secrets present — the upload step will fail, but the archive + export artifact will be retained.
