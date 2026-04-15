#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
生成された config.json を確認
"""
import json

try:
    with open('output/presentation_config.json', 'r', encoding='utf-8') as f:
        config = json.load(f)
    
    print('📋 Config structure:')
    for part, part_data in config.items():
        print(f'\n{part}:')
        print(f'  Title: {part_data.get("title")}')
        print(f'  Slides: {len(part_data.get("slides", []))}')
        
        for i, slide in enumerate(part_data.get("slides", [])[:3]):
            print(f'    [{i+1}] title: {slide.get("title", "N/A")[:50]}')
            print(f'        audio_files: {len(slide.get("audio_files", []))} files')
            print(f'        duration: {slide.get("total_duration")}s')
        
        if len(part_data.get("slides", [])) > 3:
            print(f'    ... ({len(part_data["slides"]) - 3} more)')

except FileNotFoundError:
    print('❌ presentation_config.json not found')
except json.JSONDecodeError as e:
    print(f'❌ JSON decode error: {e}')
