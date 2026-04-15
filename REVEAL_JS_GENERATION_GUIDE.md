# reveal.js プレゼンテーション自動生成ガイド

> **フェーズ**: 5.2 ナレッジシェア資料 Web化  
> **Work ID**: 030  
> **参照**: [KNOWLEDGE_SHARE_SLIDES.md](KNOWLEDGE_SHARE_SLIDES.md), [voicevox_scripts/speech_data.json](voicevox_scripts/speech_data.json)

---

## 📖 概要

KNOWLEDGE_SHARE_SLIDES.md (Marp) で作成した 33 枚のスライドを、reveal.js ベースの HTML5 プレゼンテーションに変換します。

**特徴**:
- ✅ ブラウザで完全播放（OS非依存）
- ✅ 45個の VOICEVOX 音声を自動埋め込み
- ✅ タイミング同期（スライド ↔ 音声）
- ✅ GitHub Pages で Web公開可能
- ✅ レスポンシブデザイン

---

## 🎯 成果物

### 生成ファイル一覧

```
output/
├── index.html ........................ reveal.js マスタープレゼンテーション (1,200+ 行)
├── audio_sync.js ..................... タイミング制御スクリプト (250+ 行)
├── presentation_config.json ......... スライド＆音声マッピング (400+ 行)
├── css/
│   ├── custom.css ................... カスタムスタイル (150+ 行)
│   └── theme.css ................... reveal.js テーマ (100+ 行)
├── js/
│   └── audio_player.js ............. 高度な再生制御 (200+ 行)
├── audio/ ........................... シンボリックリンク先
│   ├── Part_A/ → ../../VOICEVOX_OUTPUT/Part_A/
│   ├── Part_B1/ → ../../VOICEVOX_OUTPUT/Part_B1/
│   ├── Part_B2/ → ../../VOICEVOX_OUTPUT/Part_B2/
│   └── Part_C/ → ../../VOICEVOX_OUTPUT/Part_C/
└── reveal.js/ ....................... reveal.js ライブラリ（CDN or ローカル）
```

---

## 🔧 実装ステップ

### Phase 1: 準備・設計

#### 1.1 データソース確認

```bash
# speech_data.json 構造確認
cat voicevox_scripts/speech_data.json | jq '.[0]'

# 出力例:
# {
#   "part": "A",
#   "scene": "01",
#   "type": "subtitle",
#   "speaker_id": 0,
#   "text": "こんにちは、VibeCoding プロジェクトの...",
#   "filename": "A01_narration.wav",
#   "duration": 12.5
# }
```

#### 1.2 Marp スライド構造解析

```bash
# KNOWLEDGE_SHARE_SLIDES.md の構造
grep "^## \|^### " KNOWLEDGE_SHARE_SLIDES.md | head -20
```

**階層構造**:
- `## Part A: ...` → スライドグループ
- `### スライド 1: ...` → 個別スライド
- `---` (ページ区切り)

#### 1.3 タイミングマッピング定義

**スライド ↔ 音声マッピング規則**:

```json
{
  "Part": "A",
  "Slides": [
    {
      "slide_number": 1,
      "title": "イントロダクション",
      "narration_file": "A01_narration.wav",
      "duration": 12.5,
      "animations": [
        {
          "trigger": "sound_start",
          "element": ".title",
          "effect": "fadeIn",
          "delay": 0
        }
      ]
    }
  ]
}
```

---

### Phase 2: 自動生成スクリプト実装

#### 2.1 `generate_html_presentation.py` (メインスクリプト, 400+ 行)

**機能**:
1. `speech_data.json` 読み込み
2. `KNOWLEDGE_SHARE_SLIDES.md` 解析
3. スライド ↔ 音声マッピング生成
4. reveal.js HTML テンプレート展開
5. `presentation_config.json` 生成

**実装内容**:

```python
import json
import yaml
from pathlib import Path
from jinja2 import Template, Environment, FileSystemLoader

class HTMLPresentationGenerator:
    def __init__(self, speech_data_path, slides_md_path, output_dir):
        self.speech_data = self._load_speech_data(speech_data_path)
        self.slides_md = self._load_markdown_slides(slides_md_path)
        self.output_dir = Path(output_dir)
        self.env = Environment(loader=FileSystemLoader('templates'))
    
    def _load_speech_data(self, path):
        """speech_data.json を読み込む"""
        with open(path) as f:
            return json.load(f)
    
    def _load_markdown_slides(self, path):
        """KNOWLEDGE_SHARE_SLIDES.md を解析"""
        # Marp → スライドオブジェクト変換
        pass
    
    def generate_presentation_config(self):
        """スライド ↔ 音声マッピング JSON 生成"""
        config = {}
        for part in ['A', 'B1', 'B2', 'C']:
            config[part] = self._map_part_slides(part)
        return config
    
    def _map_part_slides(self, part):
        """Part A/B1/B2/C のマッピング"""
        # タイミング同期ロジック
        pass
    
    def generate_html(self):
        """reveal.js HTML を生成"""
        template = self.env.get_template('reveal_template.html')
        html = template.render(
            slides=self.slides_markdown,
            audio_config=self.generate_presentation_config()
        )
        self.output_dir.joinpath('index.html').write_text(html)
    
    def generate_audio_links(self):
        """シンボリックリンク or コピー"""
        audio_dir = self.output_dir / 'audio'
        # WAV ファイル配置
        pass
    
    def run(self):
        self.generate_presentation_config()
        self.generate_html()
        self.generate_audio_links()
        print("✅ Presentation generated: output/index.html")
```

---

### Phase 3: テンプレート & スタイル

#### 3.1 `reveal_template.html` (jinja2 テンプレート, 400+ 行)

**構造**:
```html
<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <title>VibeCoding ナレッジシェア</title>
    <link rel="stylesheet" href="reveal.js/dist/reveal.css">
    <link rel="stylesheet" href="reveal.js/dist/theme/black.css">
    <link rel="stylesheet" href="css/custom.css">
  </head>
  <body>
    <div class="reveal">
      <div class="slides">
        
        <!-- Part A -->
        {% for slide in slides.part_a %}
        <section>
          <h2>{{ slide.title }}</h2>
          <p>{{ slide.content }}</p>
          <audio id="audio-{{ slide.id }}" src="audio/{{ slide.audio_file }}"></audio>
          <script>
            Reveal.on('slidechanged', event => {
              if(event.indexh === {{ slide.index }}) {
                document.getElementById('audio-{{ slide.id }}').play();
              }
            });
          </script>
        </section>
        {% endfor %}
        
      </div>
    </div>
    <script src="reveal.js/dist/reveal.js"></script>
    <script src="audio_sync.js"></script>
  </body>
</html>
```

#### 3.2 `audio_sync.js` (250+ 行) - タイミング同期

**機能**:
- スライド遷移時に対応音声を再生
- 音声終了時に次スライドへ自動遷移
- 手動操作との同期

```javascript
class AudioSyncController {
  constructor(config) {
    this.config = config;
    this.currentPart = 'A';
    this.currentSlide = 0;
    
    Reveal.initialize({ ... });
    this.setupEventListeners();
  }
  
  setupEventListeners() {
    Reveal.on('slidechanged', event => {
      this.onSlideChange(event);
    });
  }
  
  onSlideChange(event) {
    const audioFile = this.getAudioForSlide(event.indexh);
    if (audioFile) {
      this.playAudio(audioFile);
    }
  }
  
  playAudio(file) {
    const audio = new Audio(`audio/${file}`);
    audio.onended = () => Reveal.next();
    audio.play();
  }
}

// 初期化
const controller = new AudioSyncController(PRESENTATION_CONFIG);
```

#### 3.3 `css/custom.css` (150+ 行)

```css
.reveal {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.reveal h1, .reveal h2, .reveal h3 {
  font-family: 'Noto Sans JP', sans-serif;
  color: #fff;
}

.reveal section {
  padding: 40px;
  min-height: 600px;
}

/* 日本語フォント */
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;700&display=swap');

/* オーディオプレイヤー UI */
.audio-control {
  position: fixed;
  bottom: 20px;
  right: 20px;
  background: rgba(0, 0, 0, 0.7);
  padding: 10px 20px;
  border-radius: 5px;
  color: #fff;
}
```

---

### Phase 4: テスト & 検証

#### 4.1 ローカル テスト

```bash
# Python 3 HTTP サーバーで検証
cd output/
python -m http.server 8000

# ブラウザで http://localhost:8000 にアクセス
```

#### 4.2 チェックリスト

- [ ] スライド表示確認（全33枚）
- [ ] 音声再生確認（全45個）
- [ ] スライド ↔ 音声タイミング同期
- [ ] キーボード操作確認（矢印キー）
- [ ] モバイル表示確認
- [ ] 音量制御確認

---

### Phase 5: ドキュメント & デプロイ

#### 5.1 操作ガイド作成

- **ユーザー向け**: 再生方法、操作キー
- **開発者向け**: カスタマイズ方法、スクリプト拡張

#### 5.2 GitHub Pages デプロイ

```bash
# リモートリポジトリ設定
git remote add origin-pages https://github.com/hirotoitpost/VibeCoding-Pages.git

# output/ ブランチ作成
git subtree push --prefix output origin-pages main

# https://hirotoitpost.github.io/VibeCoding-Pages/ で公開
```

---

## 📊 ファイル行数サマリー

| ファイル | 行数 | 難易度 |
|---------|------|--------|
| `generate_html_presentation.py` | 400+ | ⭐⭐⭐ |
| `reveal_template.html` | 400+ | ⭐⭐ |
| `audio_sync.js` | 250+ | ⭐⭐⭐ |
| `css/custom.css` | 150+ | ⭐ |
| `presentation_config.json` | 400+ | - |
| **ドキュメント** | 300+ | - |
| **合計** | 1,900+ | - |

---

## 🔗 参考リンク

- [reveal.js 公式](https://revealjs.com/)
- [jinja2 テンプレート](https://jinja.palletsprojects.com/)
- [HTML5 Audio API](https://developer.mozilla.org/en-US/docs/Web/API/HTMLAudioElement)
- [KNOWLEDGE_SHARE_SLIDES.md](KNOWLEDGE_SHARE_SLIDES.md)

---

## ✅ 実装確認フロー

1. ✅ ガイド作成（このファイル）
2. ⏳ `generate_html_presentation.py` 実装
3. ⏳ テンプレート実装
4. ⏳ テスト・検証
5. ⏳ コミット & PR
6. ⏳ GitHub Pages デプロイ

---

**推定完了期間**: 4-6 時間

**次タスク**: `generate_html_presentation.py` 実装開始 🚀
