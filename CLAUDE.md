# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

VibeCoding is a learning project for mastering "Vibe Coding" — the paradigm where AI handles code implementation from natural language instructions. The philosophical goal is: **"Determine what AI can handle"** — how much can you remain ignorant about runtimes and SDKs?

**Repository**: https://github.com/hirotoitpost/VibeCoding  
**Tech stack**: Python, JavaScript/Node.js, React, Express, Docker, Solidity/Hardhat, PowerShell, VOICEVOX, AviUtl

## New Session Startup

`SESSION_PROGRESS.md` and `WORK_ID_REGISTRY.md` are **auto-injected into context** via the `SessionStart` hook in `.claude/settings.json`. At the start of every session, also:

1. Run `git log --oneline main -3` and `git branch -a | grep feature`
2. Present an "Auto-Briefing" to the user using the template in `agents.md`

> **Repo name**: always `VibeCoding` — never `VideoCoding` (common typo).

## Git Workflow Rules

### Branch Naming

- Feature work: `feature/[ID]_[title]` (e.g., `feature/030_reveal-js`)
- Bug fixes: `fix/[ID]_[description]`
- Docs updates: `docs/session-[X]-update`

### Commit Message Format

```
<type>(<scope>): <subject>
```

Types: `feat` | `fix` | `docs` | `refactor` | `test` | `chore` | `restore`

Examples:
- `feat(ID 030): reveal.js プレゼンテーション自動生成`
- `fix(generate_exo): テキスト形式判定エラー修正`
- `docs(Session 28): セッション進捗記録更新`

Full spec in `GIT_COMMIT_CONVENTION.md` and `.instructions.md`.

### PR Workflow

1. AI: create feature branch → commit → `git push` → `gh pr create` → return PR URL to user
2. **User**: review, approve, merge on GitHub
3. User: `git pull origin main`
4. AI: create `docs/session-X-update` branch → update `SESSION_PROGRESS.md` + `WORK_ID_REGISTRY.md` → `gh pr create`
5. **User**: merge docs PR

### Forbidden (AI must never do)

- Merge any feature/docs branch into main via `git merge`
- Approve or merge own PRs
- `git push origin main` (any direct push to main)

## Documentation System (7-Tier)

This repo enforces a tier-based architecture. Alert at 200 lines, split at 400 lines, one document = one domain.

| Tier | Type | Target Size | Key Files |
|------|------|-------------|-----------|
| 1 | Core guides | 100–150 lines | `agents.md`, `README.md` |
| 2 | Operational | 100–200 lines | `GIT_WORKFLOW.md`, `DEVELOPMENT_PROCESS.md` |
| 3 | Roadmaps | 200–300 lines | `LEARNING_PATH.md`, `APP_CANDIDATES*.md` |
| 4 | Registries | 200+ lines | `WORK_ID_REGISTRY.md`, `SESSION_PROGRESS.md` |
| 5 | Theory | 250–600 lines | `docs/vibe_coding_theory.md`, `docs/vibe_coding_instruction_design.md` |
| 6 | Project-specific | 100–150 lines | `examples/*/README.md`, `SETUP_GUIDE.md` |
| 7 | Auxiliary | 200–250 lines | `DOCUMENTATION_CREATION_CHECKLIST.md` |

**Instruction SKILLs** (read before acting):
- `.instructions.md` — Git commit/PR conventions
- `.instructions-doc.md` — Document creation/management

For new document creation, follow the checklist in `DOCUMENTATION_CREATION_CHECKLIST.md`.

## Key Files Index

| File | Purpose |
|------|---------|
| `agents.md` | AI agent operational guide + auto-briefing template |
| `SESSION_PROGRESS.md` | Completed sessions, phase status |
| `WORK_ID_REGISTRY.md` | Work ID history and next-ID allocation |
| `DEVELOPMENT_PROCESS.md` | 6-step debug workflow |
| `GIT_COMMIT_CONVENTION.md` | Commit message format |
| `PULL_REQUEST_GUIDELINES.md` | PR templates and checklist |
| `LEARNING_PATH.md` | Phase roadmap and milestones |
| `APP_CANDIDATES_OVERVIEW.md` | Project candidate index (links to 4 sub-files) |
| `DOCUMENTATION_STRATEGY.md` | Tier definitions and refactoring strategy |

## Project Examples Structure

Each project in `examples/` is self-contained with its own `README.md`, `SETUP_GUIDE.md`, and test suite.

```
examples/
├── 01-basic/weather-tool/                  # Python + OpenWeatherMap API
├── 02-intermediate/web-accounting-app/     # React + Express + Docker
├── 03-intermediate/iot-sensor-simulator/   # Python + MQTT + Docker
├── 04-intermediate/chatbot-web-app/        # React + Flask + Docker
├── 05-advanced/smart-home-iot-hub/         # Microservices: MQTT+Python+Express+React
├── 06-advanced/smart-contract-dapp/        # Solidity + Hardhat + React + ethers.js
└── 07-advanced/
    ├── aviutl_voicevox_pipeline/            # PowerShell + VOICEVOX + AviUtl
    └── tsumugi_explanation_video_system/    # VOICEVOX batch generator
```

## Running Projects

### Python projects
```bash
cd examples/01-basic/weather-tool
pip install -r requirements.txt
python main.py
python -m pytest tests/
```

### Docker-based projects
```bash
cd examples/0X-[project-name]
docker-compose up --build
```

### Smart contract (Hardhat)
```bash
cd examples/06-advanced/smart-contract-dapp
npm install
npx hardhat compile
npx hardhat test
npx hardhat node   # local blockchain
```

### Video pipeline (PowerShell, Windows only)
```powershell
cd examples/07-advanced/aviutl_voicevox_pipeline
./check_env.ps1     # validate environment variables first
./run_all.ps1       # full pipeline
./generate_exo.ps1  # AviUtl Exo file only
```

## Environment Setup

```bash
cp .env.example .env
# Set: OPENWEATHERMAP_API_KEY, AVIUTL_ROOT, VOICEVOX paths, speaker IDs
```

On Windows PowerShell, run `./scripts/setup-dev-env.ps1` to auto-load `.env` at every terminal start.

## Claude Code Configuration (`.claude/settings.json`)

Pre-configured auto-allow rules: `git *`, `gh *`, `python *`, `node *`, `npm *`, `npx *`, `docker *`, `docker-compose *`, `pip *`, plus `Read`/`Edit`/`Write`. Response language is set to Japanese.

The `SessionStart` hook auto-injects the last 60 lines of `SESSION_PROGRESS.md` and 40 lines of `WORK_ID_REGISTRY.md` into every session context.

## Current Status

- **Completed**: Phase 1–5.1, Work IDs 001–029, Session 28
- **Next**: Phase 5.5.2 — INI format Exo file rewrite (Work ID 030+)
- **Full details**: `SESSION_PROGRESS.md`, `WORK_ID_REGISTRY.md`
