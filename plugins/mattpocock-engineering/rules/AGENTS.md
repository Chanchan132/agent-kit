# Matt Pocock engineering skills: harness adapter

These skills were written for Claude Code and Codex. When following one of them in Antigravity:

- "Call the Skill tool for X" or "/X" means: read the `SKILL.md` of the skill named X (from this plugin's `skills/` directory, or any other installed skill with that name) and follow it.
- `disable-model-invocation: true` in a skill's frontmatter means the skill is meant to be user-invoked. Only run it when the user explicitly asks for it by name.
- "Sub-agents" / "background agents" map to Antigravity subagents (`invoke_subagent`).
- Ignore the `agents/openai.yaml` files; they are Codex-only metadata.
