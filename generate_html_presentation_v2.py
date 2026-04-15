#!/usr/bin/env python3
"""
reveal.js プレゼンテーション自動生成スクリプト v2 - modified

用途: KNOWLEDGE_SHARE_SLIDES.md + speech_data.json → HTML5 reveal.js プレゼンテーション
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
        
        # Jinja2 環境設定（autoescape=False に変更して、HTMLエスケープを制御）
        self.env = Environment(autoescape=False)
        
    def _load_speech_data(self) -> Dict:
        """speech_data.json を読み込む"""
        with open(self.speech_data_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    
    def _load_markdown_slides(self) -> str:
        """KNOWLEDGE_SHARE_SLIDES.md を読み込む"""
        with open(self.slides_md_path, 'r', encoding='utf-8') as f:
            return f.read()
    
    def _parse_marp_slides(self, content: str) -> Dict[str, Any]:
        """Marp形式のスライドを解析"""
        slides = {
            'A': {'title': 'Part A: イントロダクション', 'slides': []},
            'B1': {'title': 'Part B-1: 基本プロジェクト', 'slides': []},
            'B2': {'title': 'Part B-2: 発展プロジェクト', 'slides': []},
            'C': {'title': 'Part C: 学習成果', 'slides': []},
        }
        
        # フロントマター（--- ～ ---）を削除
        lines = content.split('\n')
        start_idx = 0
        if lines and lines[0].strip() == '---':
            for i in range(1, len(lines)):
                if lines[i].strip() == '---':
                    start_idx = i + 1
                    break
        
        content_without_frontmatter = '\n'.join(lines[start_idx:])
        
        # スライドブロックに分割（--- で区切り）
        slide_blocks = content_without_frontmatter.split('\n---\n')
        
        current_part = 'A'
        valid_slides = 0
        
        for block_idx, block in enumerate(slide_blocks):
            block = block.strip()
            if not block:
                continue
            
            # Part 判定（コメントまたはマークダウンテキストから）
            if 'Part B-1' in block or 'PART B-1' in block or '## Part B-1' in block:
                current_part = 'B1'
            elif 'Part B-2' in block or 'PART B-2' in block or '## Part B-2' in block:
                current_part = 'B2'
            elif 'Part C' in block or 'PART C' in block or '## Part C' in block:
                current_part = 'C'
            elif 'Part A' in block or 'PART A' in block or '# VibeCoding' in block[:100]:
                current_part = 'A'
            
            # スライドコンテンツをパース
            slide = self._parse_slide_content(block, current_part, block_idx)
            if slide:
                slides[current_part]['slides'].append(slide)
                valid_slides += 1
        
        print(f"   Total parsed: {valid_slides} slides")
        for part_key in ['A', 'B1', 'B2', 'C']:
            print(f"   {part_key}: {len(slides[part_key]['slides'])} slides")
        
        return slides
    
    def _parse_slide_content(self, content: str, part: str, slide_idx: int = 0) -> Dict[str, Any]:
        """個別スライドコンテンツをパース"""
        lines = content.strip().split('\n')
        
        # タイトル抽出：最初の見出し（# または ##）
        title = None
        body_start = 0
        
        for i, line in enumerate(lines):
            if line.startswith('# ') or line.startswith('## '):
                title = line.replace('##', '').replace('#', '').strip()
                body_start = i + 1
                break
        
        if not title:
            return None
        
        body_lines = lines[body_start:]
        body_text = '\n'.join(body_lines)
        body_text = re.sub(r'<!--.*?-->', '', body_text, flags=re.DOTALL).strip()
        
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
    
    def generate_presentation_config(self, speech_data: Dict, slides: Dict) -> Dict[str, Any]:
        """スライド ↔ 音声マッピング JSON 生成"""
        # speech_data は dict で、'scenes' キーにリストが格納
        scenes = speech_data.get('scenes', []) if isinstance(speech_data, dict) else speech_data
        
        config = {}
        slide_counter = 1
        
        for part_key in ['A', 'B1', 'B2', 'C']:
            part_data = slides[part_key]
            config[part_key] = {
                'title': part_data['title'],
                'slides': []
            }
            
            # 各パートのスライド
            for slide_idx, slide in enumerate(part_data['slides'], 1):
                # 対応する音声ファイル取得
                audio_files = [
                    s.get('output_file', '') for s in scenes 
                    if s.get('part') == part_key and s.get('slide') == slide_idx
                ]
                
                total_duration = sum(
                    s.get('duration', 0) for s in scenes
                    if s.get('part') == part_key and s.get('slide') == slide_idx
                )
                
                config[part_key]['slides'].append({
                    'slide_num': slide_counter,
                    'title': slide['title'],
                    'content': slide['html_content'],
                    'audio_files': audio_files,
                    'total_duration': total_duration,
                })
                
                slide_counter += 1
        
        return config
    
    def generate_html(self) -> str:
        """テンプレートを返す"""
        return '''<!doctype html>
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
        justify-content: center;
      }
    </style>
  </head>
  <body>
    <div class="reveal">
      <div class="slides">
        
        <!-- Title Slide -->
        <section>
          <h1>🎯 VibeCoding ナレッジシェア</h1>
          <h3>AI時代の開発パラダイムを理解する</h3>
          <p style="margin-top: 40px;"><em>45個の音声ナレーション + {{ config|sum(attribute='slides', start=[])|length }}枚スライド</em></p>
        </section>
        
        {% for part_key in ['A', 'B1', 'B2', 'C'] %}
        {% if part_key in config %}
        {% set part_data = config[part_key] %}
        
        <!-- Part Header -->
        <section>
          <h2>{{ part_data.title }}</h2>
          <p style="font-size: 18px; margin-top: 30px;">📊 {{ part_data.slides|length }} スライド</p>
        </section>
        
        <!-- Slides in Part -->
        {% for slide in part_data.slides %}
        <section>
          <h2>{{ slide.title }}</h2>
          <div class="slide-content">
            {{ slide.content }}
          </div>
          <p style="font-size: 12px; margin-top: 20px; color: #888;">
            ⏱️ {{ slide.total_duration | round(1) }}秒
          </p>
        </section>
        {% endfor %}
        
        {% endif %}
        {% endfor %}
        
        <!-- Ending -->
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
    
    <div class="slide-info" style="position: fixed; bottom: 20px; left: 20px; background: rgba(0, 0, 0, 0.5); padding: 10px 15px; border-radius: 5px; color: #fff;">
      <span id="slide-counter">1/{{ config|sum(attribute='slides', start=[])|length }}</span>
    </div>
    
    <script src="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/4.5.0/reveal.min.js"></script>
    <script>
      Reveal.initialize({hash: true, transition: 'slide'});
      Reveal.on('slidechanged', event => {
        const totalSlides = document.querySelectorAll('.reveal .slides > section').length;
        const currentSlide = event.indexh + 1;
        document.getElementById('slide-counter').textContent = currentSlide + '/' + totalSlides;
      });
    </script>
  </body>
</html>'''
    
    def save_config_json(self, config: Dict[str, Any]):
        """設定 JSON を保存"""
        config_file = self.output_dir / "presentation_config.json"
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump(config, f, ensure_ascii=False, indent=2)
        print(f"✅ Saved {config_file}")
    
    def copy_audio_files(self):
        """VOICEVOX 出力ディレクトリから audio/ にコピー"""
        audio_out = self.output_dir / "audio"
        audio_out.mkdir(exist_ok=True)
        
        for part in ['Part_A', 'Part_B1', 'Part_B2', 'Part_C']:
            src = self.voicevox_output / part
            part_key = part.replace('Part_', '')
            dst = audio_out / part_key
            
            if src.exists():
                if dst.exists():
                    shutil.rmtree(dst)
                shutil.copytree(src, dst)
                print(f"✅ Copied {part} → {dst}")
    
    def run(self):
        """メイン処理"""
        print("🚀 Starting HTML Presentation Generation...\n")
        
        # 1. Load data
        print("📖 Loading data...")
        speech_data = self._load_speech_data()
        slides_md = self._load_markdown_slides()
        print(f"   ✅ Loaded speech data\n")
        
        # 2. Parse slides
        print("🔍 Parsing slides...")
        slides = self._parse_marp_slides(slides_md)
        
        # 3. Generate config
        print("[⚙️] Generating config...")
        config = self.generate_presentation_config(speech_data, slides)
        self.save_config_json(config)
        
        # 4. Generate HTML
        print("📝 Generating HTML...")
        template_str = self.generate_html()
        template = self.env.from_string(template_str)
        rendered_html = template.render(config=config)
        
        output_html = self.output_dir / "index.html"
        output_html.write_text(rendered_html, encoding='utf-8')
        print(f"   ✅ Generated {output_html}\n")
        
        # 5. Copy audio
        print("🎵 Copying audio files...")
        self.copy_audio_files()
        
        # Done
        total_slides = sum(len(part['slides']) for part in slides.values())
        print(f"\n✅ Complete! {total_slides} slides generated.")
        print(f"Open file://{output_html}")

# Entry point
if __name__ == '__main__':
    generator = HTMLPresentationGenerator()
    generator.run()
