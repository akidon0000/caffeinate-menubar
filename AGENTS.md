# AGENTS.md

## 修正後は必ず再ビルド & 再インストールまでやる

Swift / `project.yml` を編集したら、以下を順に実行して `/Applications/CaffeinateMenuBar.app` を最新版に差し替える（ユーザーが menu bar アプリとして実利用しているため、ソース変更だけでは挙動が変わらない）。

```bash
cd ~/ghq/github.com/akidon0000/caffeinate-menubar

# 1. project.yml を変更した場合のみ Xcode プロジェクトを再生成
xcodegen generate

# 2. Release ビルド（未署名）
xcodebuild -project CaffeinateMenuBar.xcodeproj \
  -scheme CaffeinateMenuBar -configuration Release \
  -derivedDataPath build \
  CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
  build

# 3. 起動中アプリを終了 → /Applications を上書き → 再起動
/usr/bin/killall CaffeinateMenuBar 2>/dev/null; sleep 1
/bin/cp -Rf build/Build/Products/Release/CaffeinateMenuBar.app/Contents/ /Applications/CaffeinateMenuBar.app/Contents/
open /Applications/CaffeinateMenuBar.app
```

### 運用メモ
- 初回インストール時（`/Applications/CaffeinateMenuBar.app` が無い場合）は `.app` ごと `cp -R ... /Applications/` でコピー。
- 2回目以降は `.app` 自体を `rm -rf` せず `Contents/` を `/bin/cp -Rf` で上書きする（権限ダイアログを回避できることを実機で確認済み）。
- `pkill -x` や `cp -f` がエイリアス経由で sudo を要求するシェルがあるため、絶対パス（`/usr/bin/killall`, `/bin/cp`) で叩く。
