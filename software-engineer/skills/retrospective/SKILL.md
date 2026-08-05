---
name: retrospective
description: Use this skill after completing a git commit, or when asked to conduct a retrospective, extract reusable project conventions, or update AGENTS.md.
---

# Retrospective Workflow

## Gotchas

- **Avoid Rule Bloat**: Do not convert one-off mistakes into permanent rules. Only extract recurring friction, team conventions, or explicit user preferences.
- **Imperative & Concise Rules**: Format `AGENTS.md` additions as concise, imperative directives without filler or meta-commentary.
- **Mandatory Approval**: NEVER update `AGENTS.md` without presenting a diff preview and securing explicit user confirmation.

## Workflow

Progress:

- [ ] **Step 1: Gather Context & Signals**
  - Check for `AGENTS.md` in the project root; offer to initialize one if missing.
  - Review conversation history (user corrections, plan shifts, failed commands) and recent git commits (`git log -n 1 -p --stat`).

- [ ] **Step 2: Analyze & Extract Rules**
  - Identify recurring friction or missing project conventions.
  - Draft proposed additions using direct, imperative language.

- [ ] **Step 3: Interactive Review**
  - If no new rules are needed, report a concise summary of the clean run and finish.
  - If rules are proposed, present them (Category, Observation, Proposed Update) for user feedback ([Ignore] or [Adopt / Refine]).

- [ ] **Step 4: Update AGENTS.md**
  - Show the diff preview for approved rules.
  - Apply changes to `AGENTS.md` only after explicit user approval.
