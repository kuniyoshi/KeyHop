# KeyHop

Application launcher for macOS

# Usage

1. 「プライバシーとセキュリティ」の「アクセシビリティ」に KeyHop を追加します
1. Open this App
1. Add a keybinginds to launch a specific app
1. Type the bindings, then specified app will be launched.

# Description

`KeyHop` は macOS 用のアプリケーションランチャーです。
アプリケーション切り替えに `⌘-Tab` を使う代わりに、
特定のキーを押すことでアプリケーションを切り替えます。

アプリケーション切り替えは単に、当該アプリケーションを
起動するだけです。

アプリケーション切り替えに特定のキーを割り当てることで、
即座に目的のアプリケーションを開けるようになります。

# Concept

`KeyHop` はとても簡単なコードで実装される、小さな
アプリケーションです。リッチな機能は実装しません。
アプリケーションをリッチにするよりも、一つの目的
ーーつまり、アプリケーション切り替えーーだけに
集中し、プロジェクトを簡潔に保ちます。プロジェクトの
簡潔さは OS の変更に追従しやすくなるため、
将来にわたって機能を維持しやすくなります。

# CI

```
xcodebuild test -scheme KeyHop -destination platform=macOS
```

# Setup

1. git config core.hooksPath githooks

# BUILD AND DISTRIBUTE

1. Archive
1. Distribute App
1. Copy App
1. Run a command to create DMG: `create-dmg KeyHop.dmg KeyHop.v0.0.1/KeyHop.app`

# Devin setup

## Maintain Dependencies

`cd ~/repos/KeyHop && git config core.hooksPath githooks`
