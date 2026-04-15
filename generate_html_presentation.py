#!/usr/bin/env python3
"""
reveal.js プレゼンテーション自動生成スクリプト

用途: KNOWLEDGE_SHARE_SLIDES.md + speech_data.json → HTML5 reveal.js プレゼンテーション

使用方法:
    python generate_html_presentation.py
"""

import json
import re
import shutil
from pathlib import Path
from typing import Dict, List, Any
from jinja2 import Environment

class HTMLPresentationGenerator:
    """reveal.js プレゼンテーション自動生成クラス"""
    
    def __init__(self):
        self.repo_root = Path(__file__).parent
        self.output_dir = self.repo_root / "output"
        self.voicevox_output = self.repo_root / "VOICEVOX_OUTPUT"
        self.speech_data_path = self.repo_root / "voicevox_scripts" / "speech_data.json"
        self.slides_md_path = self.repo_root / "KNOWLEDGE_SHARE_SLIDES.md"
        
        # ディレクトリ作成
        self.output_dir.mkdir(exist_ok=True)
        
        # Jinja2 環境設定
        self.env = Environment(autoescape=True)
        
    def _load_speech_data(self) -> List[Dict[str, Any]]:
        """speech_data.json を読み込む"""
        with open(self.speech_data_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            # "scenes" キーから音声エントリを取得
            scenes = data.get('scenes', [])
            print(f"   [DEBUG] speech_data.json loaded: {len(scenes)} scenes available")
            return scenes
    
    def _load_markdown_slides(self) -> str:
        """KNOWLEDGE_SHARE_SLIDES.md を読み込む"""
        with open(self.slides_md_path, 'r', encoding='utf-8') as f:
            return f.read()
    
    def _parse_marp_slides(self, content: str) -> Dict[str, Any]:
        """
        Marp マークダウンをスライド別に分割・パース
        
        Marp フォーマット: --- で各スライドが区切られる
        """
        # フロントマター（--- ～ ---）を削除
        if content.startswith('---'):
            frontmatter_end = content.find('\n---', 1)
            if frontmatter_end != -1:
                content = content[frontmatter_end + 4:].lstrip('\n')
        
        # --- で個別スライドに分割
        # 先頭スライドを落とさないように空要素のみ除外
        slide_blocks = [b for b in content.split('\n---\n') if b.strip()]
        print(f"   [DEBUG] Total slide blocks split: {len(slide_blocks)}")
        
        # パート別スライド集約
        parts = {
            'A': {'title': 'Part A: イントロダクション', 'slides': []},
            'B1': {'title': 'Part B-1: 基本プロジェクト', 'slides': []},
            'B2': {'title': 'Part B-2: 発展プロジェクト', 'slides': []},
            'C': {'title': 'Part C: 学習成果', 'slides': []},
        }
        
        current_part = 'A'  # デフォルト: Part A
        
        global_slide_no = 1
        for block_idx, block in enumerate(slide_blocks):
            block = block.strip()
            if not block:
                print(f"   [DEBUG] Block {block_idx}: Empty, skipping")
                continue
            
            # Part 判定（コメントまたはマークダウンテキストから）
            if 'PART B-1' in block or 'Part B-1' in block:
                current_part = 'B1'
            elif 'PART B-2' in block or 'Part B-2' in block:
                current_part = 'B2'
            elif 'PART C' in block or 'Part C' in block:
                current_part = 'C'
            elif 'PART A' in block or 'Part A' in block or '# VibeCoding' in block[:100]:
                current_part = 'A'
            
            # スライドコンテンツをパース
            slide = self._parse_slide_content(block, current_part, block_idx)
            if slide:
                slide['global_slide_no'] = global_slide_no
                split_slides = self._split_slide_for_viewport(slide)
                parts[current_part]['slides'].extend(split_slides)
                split_info = f" (+{len(split_slides)-1} split)" if len(split_slides) > 1 else ""
                print(
                    f"   [DEBUG] Block {block_idx}: ✅ Added to Part {current_part} "
                    f"- Slide#{global_slide_no} - Title: {slide['title'][:50]}...{split_info}"
                )
                global_slide_no += 1
            else:
                print(f"   [DEBUG] Block {block_idx}: ❌ Rejected (no title extracted)")
        
        return parts

    def _split_slide_for_viewport(self, slide: Dict[str, Any]) -> List[Dict[str, Any]]:
        """16:9表示で見切れにくくするため、長いスライドを分割する。"""
        lines = [line for line in slide['content'].split('\n') if line.strip()]
        max_lines = 14
        max_chars = 900

        if len(lines) <= max_lines and len(slide['content']) <= max_chars:
            slide['is_continuation'] = False
            slide['split_index'] = 1
            slide['split_total'] = 1
            return [slide]

        chunks: List[List[str]] = []
        current_chunk: List[str] = []
        current_chars = 0

        for line in lines:
            line_len = len(line)
            need_new_chunk = (
                len(current_chunk) >= max_lines
                or (current_chars + line_len) > max_chars
            )
            if need_new_chunk and current_chunk:
                chunks.append(current_chunk)
                current_chunk = []
                current_chars = 0

            current_chunk.append(line)
            current_chars += line_len

        if current_chunk:
            chunks.append(current_chunk)

        result: List[Dict[str, Any]] = []
        total_chunks = len(chunks)
        for i, chunk_lines in enumerate(chunks, start=1):
            suffix = "" if i == 1 else f" (続き {i-1})"
            chunk_md = "\n".join(chunk_lines)
            result.append({
                'part': slide['part'],
                'index': slide['index'],
                'title': f"{slide['title']}{suffix}",
                'content': chunk_md,
                'html_content': self._markdown_to_html(chunk_md),
                'global_slide_no': slide['global_slide_no'],
                'is_continuation': i > 1,
                'split_index': i,
                'split_total': total_chunks,
            })

        return result
    
    def _parse_slide_content(self, content: str, part: str, slide_idx: int = 0) -> Dict[str, Any]:
        """個別スライドコンテンツをパース"""
        lines = content.strip().split('\n')
        
        # タイトル抽出：最初の見出し（# または ##）
        title = 'Untitled'
        body_start = 0
        
        for i, line in enumerate(lines):
            if line.startswith('# ') or line.startswith('## '):
                title = line.replace('##', '').replace('#', '').strip()
                body_start = i + 1
                break
        
        body_lines = lines[body_start:]
        
        # コメント部を除外（<!-- ～ --> 部分）
        body_text = '\n'.join(body_lines)
        body_text = re.sub(r'<!--.*?-->', '', body_text, flags=re.DOTALL).strip()
        
        if not title or title == 'Untitled':
            return None
        
        return {
            'part': part,
            'index': slide_idx,
            'title': title,
            'content': body_text,
            'html_content': self._markdown_to_html(body_text),
        }
    
    def _markdown_to_html(self, md_text: str) -> str:
        """簡易 Markdown → HTML 変換"""
        html = md_text
        
        # **bold**
        html = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', html)
        
        # *italic*
        html = re.sub(r'\*(.+?)\*', r'<em>\1</em>', html)
        
        # `code`
        html = re.sub(r'`(.+?)`', r'<code>\1</code>', html)
        
        # 改行
        html = html.replace('\n', '<br/>')
        
        return html
    
    def generate_presentation_config(self, speech_data: List[Dict], slides: Dict) -> Dict[str, Any]:
        """
        スライド ↔ 音声マッピング JSON 生成
        
        Returns:
            Config dict with structure:
            {
              'Part': {
                'slides': [
                  {
                    'slide_num': int,
                    'title': str,
                    'audio_files': list,
                    'duration': float,
                  }
                ]
              }
            }
        """
        config = {}
        slide_counter = 1

        # 手動確認しやすいように scene を global slide 番号でまとめる
        scenes_by_global_slide: Dict[int, List[Dict[str, Any]]] = {}
        for scene in speech_data:
            slide_no = scene.get('slide')
            if isinstance(slide_no, int):
                scenes_by_global_slide.setdefault(slide_no, []).append(scene)
        
        for part_key in ['A', 'B1', 'B2', 'C']:
            part_data = slides[part_key]
            config[part_key] = {
                'title': part_data['title'],
                'slides': []
            }
            
            # 各パートのスライド（global_slide_no でマッピング）
            for slide_idx, slide in enumerate(part_data['slides']):
                audio_files = []
                audio_tracks = []
                total_duration = 0
                source_slide_no = slide['global_slide_no']
                matched_scenes = scenes_by_global_slide.get(source_slide_no, [])

                # 分割スライドは先頭だけ音声を持たせる
                if slide.get('is_continuation'):
                    matched_scenes = []

                for scene in matched_scenes:
                    if 'output_file' in scene:
                        filename = Path(scene['output_file']).name
                        audio_files.append(filename)
                    audio_part = scene.get('part', part_key)
                    audio_tracks.append({'part': audio_part, 'file': filename})
                    print(f"   [AUDIO] Slide {source_slide_no}: {audio_part}/{filename}")
                    if 'duration' in scene:
                        total_duration += scene['duration']
                
                config[part_key]['slides'].append({
                    'slide_num': slide_counter,
                    'source_slide_num': source_slide_no,
                    'title': slide['title'],
                    'content': slide['html_content'],
                    'audio_files': audio_files,
                    'audio_tracks': audio_tracks,
                    'total_duration': total_duration,
                    'is_continuation': slide.get('is_continuation', False),
                    'split_index': slide.get('split_index', 1),
                    'split_total': slide.get('split_total', 1),
                })
                
                slide_counter += 1
        
        return config
    
    def generate_html(self, config: Dict[str, Any]) -> str:
        """reveal.js HTML を生成"""
        
        html_template = '''<!doctype html>
<html lang="ja">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VibeCoding ナレッジシェア</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/4.5.0/reveal.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/4.5.0/theme/black.min.css">
    <link rel="stylesheet" href="css/custom.css">
    <style>
      @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;700&display=swap');
      
      .reveal {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        font-family: 'Noto Sans JP', 'Segoe UI', sans-serif;
      }
      
      .reveal h1, .reveal h2, .reveal h3 {
        font-family: 'Noto Sans JP', sans-serif;
        text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
      }
      
      .reveal section {
        min-height: 100vh;
        display: flex;
        flex-direction: column;
        justify-content: flex-start;
        padding-top: 4vh;
      }

      .slide-content {
        text-align: left;
        max-width: 90%;
        width: 90%;
        margin: 1.2rem auto;
        max-height: 62vh;
        overflow-y: auto;
        padding-right: 8px;
      }
      
      .audio-control {
        position: fixed;
        bottom: 20px;
        right: 20px;
        background: rgba(0, 0, 0, 0.7);
        padding: 15px 25px;
        border-radius: 5px;
        color: #fff;
        z-index: 1000;
        font-size: 14px;
      }
      
      .audio-control audio {
        margin-top: 10px;
        width: 250px;
      }
      
      .slide-info {
        position: fixed;
        bottom: 20px;
        left: 20px;
        background: rgba(0, 0, 0, 0.5);
        padding: 10px 15px;
        border-radius: 5px;
        color: #fff;
        font-size: 12px;
      }
    </style>
  </head>
  <body>
    <div class="reveal">
      <div class="slides">
        
        <!-- タイトルスライド -->
        <section>
          <h1>🎯 VibeCoding ナレッジシェア</h1>
          <h3>AI時代の開発パラダイムを理解する</h3>
          <p style="margin-top: 40px; font-size: 18px;">
            <em>45個の音声ナレーション + 33枚スライド</em>
          </p>
        </section>
        
        {% for part_key, part_data in config.items() %}
        
        <!-- {{ part_key }} セクションヘッダー -->
        <section>
          <h2>{{ part_data.title }}</h2>
          <p style="font-size: 18px; margin-top: 30px;">
            📊 {{ part_data.slides|length }} スライド
          </p>
        </section>
        
        <!-- 各スライド -->
        {% for slide in part_data.slides %}
        <section>
          <h2>{{ slide.title }}</h2>
          <div class="slide-content">
            {{ slide.content | safe }}
          </div>
          
          <!-- 音声埋め込み -->
          {% if slide.audio_tracks %}
          <div class="slide-audio" data-part="{{ part_key }}" data-source-slide="{{ slide.source_slide_num }}" style="display: none;">
            {% for track in slide.audio_tracks %}
            <audio class="slide-audio-item" preload="metadata" data-file="{{ track.file }}" src="audio/{{ track.part }}/{{ track.file }}"></audio>
            {% endfor %}
          </div>
          {% endif %}
          
          <p style="font-size: 12px; margin-top: 20px; color: #888;">
            ⏱️ {{ slide.total_duration | round(1) }}秒
          </p>
        </section>
        {% endfor %}
        
        {% endfor %}
        
        <!-- エンディング -->
        <section>
          <h1>🎓 学習完了！</h1>
          <h3>次なるステップへ</h3>
          <p style="margin-top: 40px;">
            <em>スライドキー: ← → 矢印キー</em><br/>
            <em>全画面: F キー</em>
          </p>
        </section>
        
      </div>
    </div>
    
    <!-- 音声制御パネル -->
    <div class="audio-control" id="audio-panel" style="display: none;">
      <p>🎤 現在の音声:</p>
      <div id="current-audio"></div>
    </div>
    
    <!-- スライド情報 -->
    <div class="slide-info">
      <span id="slide-counter">1/33</span>
    </div>
    
    <!-- reveal.js スクリプト -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/4.5.0/reveal.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/4.5.0/plugin/notes/notes.min.js"></script>
    <script src="audio_sync.js"></script>
    
    <script>
      Reveal.initialize({
        hash: true,
        width: 1600,
        height: 900,
        margin: 0.04,
        minScale: 0.4,
        maxScale: 2.0,
        transition: 'slide',
        backgroundTransition: 'fade',
      });
      
      // スライドカウンター更新
      Reveal.on('slidechanged', event => {
        const totalSlides = document.querySelectorAll('.reveal .slides > section').length;
        const currentSlide = event.indexh + 1;
        document.getElementById('slide-counter').textContent = currentSlide + '/' + totalSlides;
      });
    </script>
  </body>
</html>'''
        
        return html_template
    
    def copy_audio_files(self, speech_data: List[Dict]):
        """VOICEVOX 出力ディレクトリから audio/ にコピー"""
        audio_out = self.output_dir / "audio"
        audio_out.mkdir(exist_ok=True)
        
        for part in ['Part_A', 'Part_B1', 'Part_B2', 'Part_C']:
            src = self.voicevox_output / part
            part_key = part.replace('_', '')[-1] if part != 'Part_A' else 'A'
            part_key = part.replace('Part_', '')
            dst = audio_out / part_key
            
            if src.exists():
                if dst.exists():
                    shutil.rmtree(dst)
                shutil.copytree(src, dst)
                print(f"✅ Copied {part} → {dst}")
    
    def create_custom_css(self):
        """カスタム CSS ファイル作成"""
        css_dir = self.output_dir / "css"
        css_dir.mkdir(exist_ok=True)
        
        custom_css = '''/* VibeCoding Presentation Custom Styles */

.reveal {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.reveal h1, .reveal h2, .reveal h3 {
  font-family: 'Noto Sans JP', sans-serif;
  color: #fff;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
}

.reveal p {
  font-size: 28px;
  line-height: 1.45;
}

.reveal li {
  font-size: 0.95em;
  line-height: 1.35;
  margin: 0.2em 0;
}

.reveal code {
  background: rgba(255, 255, 255, 0.1);
  padding: 2px 6px;
  border-radius: 3px;
  font-family: 'Courier New', monospace;
}

.reveal strong {
  color: #ffeb3b;
  font-weight: bold;
}

.reveal em {
  color: #81c784;
  font-style: italic;
}

.slide-content {
  text-align: left;
  margin: 12px auto;
  max-width: 90%;
  max-height: 62vh;
  overflow-y: auto;
  padding-right: 8px;
}

.slide-content br {
  margin: 10px 0;
}

/* モバイル対応 */
@media (max-width: 768px) {
  .reveal {
    font-size: 20px;
  }
  
  .reveal h1 {
    font-size: 48px;
  }
  
  .reveal h2 {
    font-size: 34px;
  }
}
'''
        (css_dir / "custom.css").write_text(custom_css, encoding='utf-8')
        print("✅ Created css/custom.css")
    
    def create_audio_sync_js(self):
        """音声同期 JavaScript 作成"""
        audio_sync_js = '''// Audio Synchronization Controller for reveal.js

class AudioSyncController {
  constructor() {
    this.currentAudio = null;
    this.currentToken = 0;
    this.isAutoPlayEnabled = true;
    this.setupEventListeners();
  }

  setupEventListeners() {
    Reveal.on('slidechanged', (event) => {
      this.onSlideChange(event);
    });

    document.addEventListener('keydown', (e) => {
      if (e.key.toLowerCase() === 'p') this.toggleAudioPanel();
      if (e.key.toLowerCase() === 'a') this.toggleAutoPlay();
    });
  }

  stopCurrentAudio() {
    if (this.currentAudio) {
      this.currentAudio.onended = null;
      this.currentAudio.pause();
      this.currentAudio.currentTime = 0;
      this.currentAudio = null;
    }
  }

  async onSlideChange(event) {
    this.currentToken += 1;
    const token = this.currentToken;

    this.stopCurrentAudio();
    if (!this.isAutoPlayEnabled) return;

    const audioNodes = Array.from(event.currentSlide.querySelectorAll('.slide-audio-item'));
    if (audioNodes.length === 0) {
      this.updateAudioPanel(null, 0, 0);
      return;
    }

    for (let i = 0; i < audioNodes.length; i += 1) {
      if (token !== this.currentToken) return;

      const audio = audioNodes[i];
      this.currentAudio = audio;
      this.updateAudioPanel(audio, i + 1, audioNodes.length);

      const completed = await this.playSingleAudio(audio, token);
      if (!completed) return;
    }

    if (token === this.currentToken) {
      setTimeout(() => {
        if (token === this.currentToken) Reveal.next();
      }, 250);
    }
  }

  playSingleAudio(audio, token) {
    return new Promise((resolve) => {
      const cleanup = () => {
        audio.onended = null;
        audio.onerror = null;
      };

      audio.onended = () => {
        cleanup();
        resolve(token === this.currentToken);
      };

      audio.onerror = () => {
        cleanup();
        console.warn('Audio load/play error:', audio.currentSrc || audio.src);
        resolve(token === this.currentToken);
      };

      audio.currentTime = 0;
      const playPromise = audio.play();
      if (playPromise && typeof playPromise.then === 'function') {
        playPromise.catch((err) => {
          cleanup();
          if (err && err.name !== 'AbortError') {
            console.warn('Audio playback failed:', err);
          }
          resolve(false);
        });
      }
    });
  }

  updateAudioPanel(audio, sequence, total) {
    const panel = document.getElementById('audio-panel');
    const currentDiv = document.getElementById('current-audio');
    if (!panel || !currentDiv) return;

    panel.style.display = 'block';
    if (!audio) {
      currentDiv.innerHTML = '<p style="margin:0;">このスライドに音声はありません</p>';
      return;
    }

    const fileName = (audio.dataset.file || audio.currentSrc || '').split('/').pop();
    currentDiv.innerHTML = `
      <p style="margin:0; line-height:1.5;">
        <strong>${fileName}</strong><br/>
        <span>${sequence}/${total} トラック</span>
      </p>
    `;
  }

  toggleAudioPanel() {
    const panel = document.getElementById('audio-panel');
    if (panel) {
      panel.style.display = panel.style.display === 'none' ? 'block' : 'none';
    }
  }

  toggleAutoPlay() {
    this.isAutoPlayEnabled = !this.isAutoPlayEnabled;
    if (!this.isAutoPlayEnabled) this.stopCurrentAudio();
    console.log(`Auto-play ${this.isAutoPlayEnabled ? 'enabled' : 'disabled'}`);
  }
}

window.addEventListener('DOMContentLoaded', () => {
  new AudioSyncController();
  console.log('✅ AudioSyncController initialized');
  console.log('Keyboard shortcuts: P=Toggle panel, A=Toggle auto-play');
});
'''
        (self.output_dir / "audio_sync.js").write_text(audio_sync_js, encoding='utf-8')
        print("✅ Created audio_sync.js")

    def save_mapping_report(self, config: Dict[str, Any], speech_data: List[Dict[str, Any]]):
        """スライド↔音声マッピングの検証レポートを保存（手動確認用）。"""
        used_audio = set()
        mapped_rows = []

        for part_key in ['A', 'B1', 'B2', 'C']:
            for slide in config.get(part_key, {}).get('slides', []):
                for track in slide.get('audio_tracks', []):
                    used_audio.add((track.get('part'), track.get('file')))
                mapped_rows.append({
                    'part': part_key,
                    'slide_num': slide.get('slide_num'),
                    'source_slide_num': slide.get('source_slide_num'),
                    'title': slide.get('title'),
                    'audio_files': slide.get('audio_files', []),
                    'audio_tracks': slide.get('audio_tracks', []),
                    'is_continuation': slide.get('is_continuation', False),
                })

        all_audio = []
        for scene in speech_data:
            part = scene.get('part')
            if part in ['A', 'B1', 'B2', 'C'] and scene.get('output_file'):
                all_audio.append((part, Path(scene['output_file']).name, scene.get('slide'), scene.get('scene_id')))

        unmapped_audio = [
            {
                'part': p,
                'file': f,
                'source_slide_num': s,
                'scene_id': sid,
            }
            for (p, f, s, sid) in all_audio
            if (p, f) not in used_audio
        ]

        report = {
            'summary': {
                'mapped_slide_count': len(mapped_rows),
                'total_audio_scene_count': len(all_audio),
                'unmapped_audio_count': len(unmapped_audio),
            },
            'slides': mapped_rows,
            'unmapped_audio': unmapped_audio,
        }

        report_path = self.output_dir / "audio_slide_mapping_report.json"
        report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
        print(f"✅ Saved {report_path}")
    
    def save_config_json(self, config: Dict[str, Any]):
        """設定 JSON を保存"""
        config_file = self.output_dir / "presentation_config.json"
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump(config, f, ensure_ascii=False, indent=2)
        print(f"✅ Saved {config_file}")
    
    def run(self):
        """メイン処理"""
        print("🚀 Starting HTML Presentation Generation...\n")
        
        # 1. データ読み込み
        print("📖 Loading data...")
        speech_data = self._load_speech_data()
        slides_md = self._load_markdown_slides()
        print(f"   ✅ Loaded {len(speech_data)} speech entries")
        print(f"   ✅ Loaded Marp slides ({len(slides_md)} chars)\n")
        
        # 2. スライド解析
        print("🔍 Parsing slides...")
        slides = self._parse_marp_slides(slides_md)
        total_slides = sum(len(part['slides']) for part in slides.values())
        print(f"   ✅ Parsed {total_slides} slides")
        for part_key in ['A', 'B1', 'B2', 'C']:
            count = len(slides[part_key]['slides'])
            print(f"      - Part {part_key}: {count} slides")
        print()
        
        # 3. 設定生成
        print("⚙️  Generating configuration...")
        config = self.generate_presentation_config(speech_data, slides)
        self.save_config_json(config)
        self.save_mapping_report(config, speech_data)
        print("   ✅ Config generated\n")
        
        # 4. HTML 生成
        print("📝 Generating HTML...")
        html_content = self.generate_html(config)
        output_html = self.output_dir / "index.html"
        template = self.env.from_string(html_content)
        rendered_html = template.render(config=config)
        output_html.write_text(rendered_html, encoding='utf-8')
        print(f"   ✅ Generated {output_html}\n")
        
        # 5. 補助ファイル
        print("🛠️  Creating auxiliary files...")
        self.create_custom_css()
        self.create_audio_sync_js()
        print()
        
        # 6. 音声ファイルコピー
        print("🎵 Copying audio files...")
        self.copy_audio_files(speech_data)
        print()
        
        # 完了
        print("✅ Generation complete!")
        print(f"\n📊 Summary:")
        print(f"   Output directory: {self.output_dir}")
        print(f"   Total slides: {total_slides}")
        print(f"   Audio files: {len(speech_data)}")
        print(f"\n🌐 To view locally:")
        print(f"   cd {self.output_dir}")
        print(f"   python -m http.server 8000")
        print(f"   Open http://localhost:8000 in your browser")

if __name__ == "__main__":
    generator = HTMLPresentationGenerator()
    generator.run()
