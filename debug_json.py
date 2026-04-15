#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
speech_data.json の実際の構造を確認
"""
import json

with open('voicevox_scripts/speech_data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

print('📋 speech_data.json structure:')
print(f'Type: {type(data)}')
print(f'Top-level keys: {list(data.keys())}')

if 'metadata' in data:
    print(f'\nMetadata:')
    for key, value in data['metadata'].items():
        print(f'  {key}: {value}')

if 'scenes' in data:
    print(f'\nScenes:')
    print(f'  Type: {type(data["scenes"])}')
    print(f'  Count: {len(data["scenes"])}')
    
    if len(data['scenes']) > 0:
        print(f'\n  First scene structure:')
        first = data['scenes'][0]
        print(f'    Type: {type(first)}')
        if isinstance(first, dict):
            for key in list(first.keys())[:10]:
                val = first[key]
                if isinstance(val, list) and len(val) > 0:
                    print(f'      {key}: {type(val)} - first item: {val[0] if len(val) == 1 else val[0]}')
                else:
                    print(f'      {key}: {val}')
        else:
            print(f'    {first}')

# Part ごとの scene 数
print(f'\n📊 Scenes by part:')
if 'scenes' in data:
    from collections import Counter
    parts = Counter(scene.get('part', 'Unknown') for scene in data['scenes'])
    for part in sorted(parts.keys()):
        print(f'  {part}: {parts[part]} scenes')
