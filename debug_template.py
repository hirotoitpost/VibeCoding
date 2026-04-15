#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
テンプレートレンダリングのデバッグ
"""
import json
from jinja2 import Environment

# config を読み込む
with open('output/presentation_config.json', 'r', encoding='utf-8') as f:
    config = json.load(f)

# テンプレートサンプル作成
test_template = '''
{%  for part_key, part_data in config.items() %}
Part: {{ part_key }}
  Title: {{ part_data.title }}
  Slides: {{ part_data.slides|length }}
  {% for slide in part_data.slides %}
  - {{ slide.title }}
  {% endfor %}
{% endfor %}
'''

# Jinja2 レンダリング
env = Environment(autoescape=True)
template = env.from_string(test_template)
rendered = template.render(config=config)

print('📋 Template Rendering Test:')
print(rendered)

# 実際の HTML テンプレートの最初の部分をテスト
html_test = '''
<!-- テスト用 -->
{% for part_key, part_data in config.items() %}
<section>
  <h2>{{ part_data.title }}</h2>
  {% for slide in part_data.slides %}
  <section>
    <h2>{{ slide.title }}</h2>
  </section>
  {% endfor %}
</section>
{% endfor %}
'''

template2 = env.from_string(html_test)
rendered2 = template2.render(config=config)

print('\n📋 HTML Template Rendering Test:')
print(rendered2[:500])
