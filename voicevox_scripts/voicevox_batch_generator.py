#!/usr/bin/env python3
"""
VOICEVOX 自動音声生成スクリプト - VibeCoding ナレッジシェア
使用方法: python3 voicevox_batch_generator.py
"""

import json
import os
import requests
import sys
from pathlib import Path
from typing import Dict, List
import time

# ========================================
# 設定
# ========================================

VOICEVOX_API_URL = "http://localhost:50021"
OUTPUT_BASE_DIR = Path(__file__).parent.parent / "VOICEVOX_OUTPUT"
SPEECH_DATA_FILE = Path(__file__).parent / "speech_data.json"

# 話者 ID マッピング
SPEAKER_IDS = {
    "narrator": 0,      # デフォルト男性ボイス
    "assistant": 1      # 女性ボイス
}

# ========================================
# ベースクラス
# ========================================

class VOICEVOXGenerator:
    def __init__(self, api_url: str = VOICEVOX_API_URL):
        self.api_url = api_url
        self.session = requests.Session()
        
    def check_api_health(self) -> bool:
        """VOICEVOX API の稼働確認"""
        try:
            response = self.session.get(f"{self.api_url}/version")
            return response.status_code == 200
        except Exception as e:
            print(f"❌ API ヘルスチェック失敗: {e}")
            return False
    
    def generate_audio(
        self,
        text: str,
        speaker_id: int,
        output_path: Path
    ) -> bool:
        """
        テキストから音声ファイルを生成
        
        Args:
            text: 生成対象のテキスト
            speaker_id: 話者 ID (0=ナレーター, 1=アシスタント)
            output_path: 出力ファイルパス
        
        Returns:
            成功時は True、失敗時は False
        """
        try:
            # Step 1: 音声パラメータを生成
            query_params = {
                "text": text,
                "speaker": speaker_id
            }
            
            response_query = self.session.post(
                f"{self.api_url}/audio_query",
                params=query_params
            )
            
            if response_query.status_code != 200:
                print(f"    ❌ クエリ生成失敗: {response_query.status_code}")
                return False
            
            query_data = response_query.json()
            
            # Step 2: 音声を合成
            synthesis_params = {"speaker": speaker_id}
            response_synthesis = self.session.post(
                f"{self.api_url}/synthesis",
                json=query_data,
                params=synthesis_params
            )
            
            if response_synthesis.status_code != 200:
                print(f"    ❌ 合成失敗: {response_synthesis.status_code}")
                return False
            
            # Step 3: ファイルに保存
            output_path.parent.mkdir(parents=True, exist_ok=True)
            with open(output_path, 'wb') as f:
                f.write(response_synthesis.content)
            
            return True
            
        except Exception as e:
            print(f"    ❌ エラー: {e}")
            return False
    
    def batch_generate(self, scenes: List[Dict]) -> Dict[str, int]:
        """
        複数シーンの音声を一括生成
        
        Args:
            scenes: シーンデータのリスト
        
        Returns:
            生成統計 {"total": 33, "success": 32, "failed": 1}
        """
        stats = {
            "total": len(scenes),
            "success": 0,
            "failed": 0,
            "errors": []
        }
        
        print(f"\n🎙️  VOICEVOX 音声生成開始")
        print(f"📊 合計: {stats['total']} シーン")
        print("=" * 60)
        
        for idx, scene in enumerate(scenes, 1):
            # シーン情報取得
            part = scene.get("part", "?")
            slide = scene.get("slide", "?")
            scene_id = scene.get("scene_id", "?")
            title = scene.get("title", "Unknown")
            speaker = scene.get("speaker", "narrator")
            duration = scene.get("duration", "?")
            output_file = scene.get("output_file", "unknown.wav")
            text = scene.get("text", "")
            
            # 話者 ID を取得
            speaker_id = SPEAKER_IDS.get(speaker, 0)
            
            # 出力パスを作成
            output_path = OUTPUT_BASE_DIR / output_file
            
            # 進捗表示
            progress = f"[{idx:2d}/{stats['total']}]"
            print(
                f"{progress} {part}-S{slide:02d} | {speaker:8s} | "
                f"{duration:>2d}秒 | {title}"
            )
            
            # 音声生成
            if self.generate_audio(text, speaker_id, output_path):
                stats["success"] += 1
                print(f"        ✅ {output_path}")
            else:
                stats["failed"] += 1
                error_msg = f"{scene_id}: {title}"
                stats["errors"].append(error_msg)
                print(f"        ❌ FAILED")
            
            # API 呼び出しレート制限（0.5秒間隔）
            if idx < stats["total"]:
                time.sleep(0.5)
        
        return stats
    
    def print_summary(self, stats: Dict) -> None:
        """生成結果のサマリーを表示"""
        print("\n" + "=" * 60)
        print("📊 生成完了サマリー")
        print("=" * 60)
        print(f"✅ 成功: {stats['success']} / {stats['total']}")
        print(f"❌ 失敗: {stats['failed']} / {stats['total']}")
        
        if stats['failed'] > 0:
            print(f"\n⚠️  失敗したシーン:")
            for error in stats['errors']:
                print(f"   - {error}")
        
        success_rate = (stats['success'] / stats['total'] * 100) if stats['total'] > 0 else 0
        print(f"\n📈 成功率: {success_rate:.1f}%")
        
        if stats['failed'] == 0:
            print("\n🎉 すべてのシーンの音声生成が完了しました！")
        else:
            print(f"\n⚠️  {stats['failed']} 個のシーンが失敗しました。")
            print("   VOICEVOX API の接続を確認して、再度実行してください。")


# ========================================
# メイン処理
# ========================================

def main():
    print("\n" + "=" * 60)
    print("🎙️  VOICEVOX 自動音声生成 - VibeCoding ナレッジシェア")
    print("=" * 60)
    
    # JSON ファイロードチェック
    if not SPEECH_DATA_FILE.exists():
        print(f"❌ セリフデータファイルが見つかりません: {SPEECH_DATA_FILE}")
        sys.exit(1)
    
    print(f"📂 セリフデータ: {SPEECH_DATA_FILE}")
    print(f"📂 出力ディレクトリ: {OUTPUT_BASE_DIR}")
    
    # ジェネレータ初期化
    generator = VOICEVOXGenerator(VOICEVOX_API_URL)
    
    # API ヘルスチェック
    print("\n🔍 VOICEVOX API に接続中...")
    if not generator.check_api_health():
        print("❌ VOICEVOX API に接続できません。")
        print("   以下を確認してください:")
        print(f"   1. VOICEVOX が起動しているか")
        print(f"   2. API URL が正しいか: {VOICEVOX_API_URL}")
        print(f"   3. ファイアウォール設定")
        sys.exit(1)
    
    print("✅ VOICEVOX API への接続成功")
    
    # セリフデータの読み込み
    print("\n📖 セリフデータを読み込み中...")
    try:
        with open(SPEECH_DATA_FILE, 'r', encoding='utf-8') as f:
            data = json.load(f)
        scenes = data.get("scenes", [])
        print(f"✅ {len(scenes)} シーンを読み込みました")
    except Exception as e:
        print(f"❌ セリフデータの読み込みに失敗: {e}")
        sys.exit(1)
    
    # ユーザー確認
    print(f"\n⏱️  推定所要時間: 約 {len(scenes) * 2 // 60} ～ {len(scenes) * 3 // 60} 分")
    response = input("音声生成を開始しますか？ (y/n): ")
    if response.lower() != 'y':
        print("キャンセルしました。")
        sys.exit(0)
    
    # 一括生成実行
    start_time = time.time()
    stats = generator.batch_generate(scenes)
    elapsed_time = time.time() - start_time
    
    # サマリー表示
    generator.print_summary(stats)
    
    print(f"\n⏱️  処理時間: {elapsed_time:.1f} 秒")
    print(f"\n💾 出力ファイル: {OUTPUT_BASE_DIR}")
    print("   以下のような構造で .wav ファイルが生成されています:")
    print("   Part_A/")
    print("     - S01_intro_title.wav")
    print("     - S02_goals.wav")
    print("     - ...(他 5 ファイル)")
    print("   Part_B1/")
    print("     - B1S01_example01_overview.wav")
    print("     - ...(他 15 ファイル)")
    print("   Part_B2/")
    print("     - B2S01_example05_overview.wav")
    print("     - ...(他 15 ファイル)")
    print("   Part_C/")
    print("     - CS01_skills.wav")
    print("     - ...(他 5 ファイル)")
    print("\n次のステップ: PowerPoint に音声を埋め込んでください。")
    print("詳細は VOICEVOX_GENERATION_GUIDE.md を参照してください。")


if __name__ == "__main__":
    main()
