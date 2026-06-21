# Release & CI

Releases are driven by **fastlane** invoked from GitHub Actions.

| Workflow / file | Trigger | What it does |
| --- | --- | --- |
| [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) | push to `main`, every PR | Generates `.xcodeproj`, builds Release (ad-hoc), uploads `.app` as a 7-day artifact. |
| [`.github/workflows/release-app-store.yml`](../.github/workflows/release-app-store.yml) | tag `v*`, `workflow_dispatch` | Runs `bundle exec fastlane mac release`. |
| [`fastlane/Fastfile`](../fastlane/Fastfile) | local or CI | `release` lane = signing setup → `gym` archive/export → `upload_to_app_store`. |
| [`.github/workflows/xcode-version.yml`](../.github/workflows/xcode-version.yml) | weekly cron | Files an issue when the runner ships a newer Xcode. |

Dependabot updates (a) GitHub Actions and (b) Bundler (fastlane / xcodeproj) on a weekly grouped cadence — see [`.github/dependabot.yml`](../.github/dependabot.yml).

## fastlane lanes

```bash
bundle install                            # one-time, installs fastlane locally
bundle exec fastlane mac build_unsigned   # ad-hoc Release build (same thing CI runs on PRs)
bundle exec fastlane mac release          # full App Store flow (needs all secrets)
```

The `release` lane:

1. Regenerates `CaffeinateMenuBar.xcodeproj` via XcodeGen.
2. On CI, imports the Apple Distribution `.p12` and Mac App Store `.provisionprofile` into a temporary keychain (via `setup_ci` + `import_certificate` + `install_provisioning_profile`).
3. Authenticates to App Store Connect with an API key.
4. Calls `gym` with manual signing (`Apple Distribution` + the installed profile), `MARKETING_VERSION` = tag (`v1.2.3` → `1.2.3`), `CURRENT_PROJECT_VERSION` = `GITHUB_RUN_NUMBER` (or `BUILD_NUMBER` env).
5. Calls `upload_to_app_store` to push the `.pkg` (no metadata/screenshots; review submission is left manual).

## One-time setup for App Store releases

You'll need an active **Apple Developer Program** membership and an app record in **App Store Connect** with `com.akidon0000.CaffeinateMenuBar` as the bundle id.

### 1. Certificates & profile

In Xcode (locally), Settings → Accounts:

1. Create an **Apple Distribution** certificate and export it as `.p12` with a password.
2. In the [Apple Developer portal](https://developer.apple.com/account/resources/profiles/list), create a **Mac App Store** provisioning profile bound to that certificate and the app id. Download the `.provisionprofile`.

### 2. App Store Connect API key

[App Store Connect → Users and Access → Integrations → App Store Connect API](https://appstoreconnect.apple.com/access/api):

1. Create a key with **App Manager** role.
2. Download the `AuthKey_XXXXXXXXXX.p8` (one chance to download).
3. Note the **Key ID** and **Issuer ID**.

### 3. GitHub Secrets

Add these under **Repo Settings → Secrets and variables → Actions** (preferably as an `appstore` Environment so a manual approval gates the deploy):

| Secret | Value |
| --- | --- |
| `APPLE_TEAM_ID` | 10-char team id (e.g. `ABCDE12345`) |
| `BUILD_CERTIFICATE_BASE64` | `base64 -i Distribution.p12 \| pbcopy` |
| `P12_PASSWORD` | password set when exporting the `.p12` |
| `PROVISIONING_PROFILE_BASE64` | `base64 -i profile.provisionprofile \| pbcopy` |
| `KEYCHAIN_PASSWORD` | any throwaway string for the ephemeral CI keychain |
| `APP_STORE_CONNECT_KEY_ID` | from step 2 |
| `APP_STORE_CONNECT_ISSUER_ID` | from step 2 |
| `APP_STORE_CONNECT_KEY_BASE64` | `base64 -i AuthKey_*.p8 \| pbcopy` |

## Cutting a release

```bash
# Optional: bump MARKETING_VERSION in project.yml. The tag also drives it.
git tag v1.0.1
git push origin v1.0.1
```

The `release-app-store.yml` workflow picks up the tag and runs the `release` lane. After it succeeds, finish the release in App Store Connect (release notes → submit for review).

For a dry run without secrets, trigger **Actions → Release to App Store → Run workflow** on a branch — fastlane will fail at the signing/upload step but you'll still get the `xcarchive` + `export/` artifacts to inspect.
