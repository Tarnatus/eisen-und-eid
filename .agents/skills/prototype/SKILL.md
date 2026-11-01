---
name: prototype
description: Build a throwaway Godot prototype to answer a design question. Use when the user wants to feel out how a mechanic plays (movement, combat, camera, a boss pattern) or explore what something in the game should look like (placeholder sprites, HUD, effects).
---

# Prototype

A prototype is **throwaway Godot code that answers a question**. The question decides the shape. This project is a Godot 4.7.2 game: prototypes are always Godot scenes, never HTML or web pages.

## Pick a branch

Identify which question is being answered, using the user's prompt, the ticket, or by asking if the user is around:

- **"How does this play / does this feel right?"** → [FEEL.md](FEEL.md). A test scene with the mechanic, every value tunable while the game runs, presets switchable by key, live state drawn on screen.
- **"What should this look like?"** → [LOOK.md](LOOK.md). Several radically different visual variants in one scene, switchable by key, shown in a realistic in-game situation.

If the question is genuinely ambiguous and the user isn't reachable, default to FEEL (this is an action game; most open questions are about play) and state the assumption in the on-screen header of the prototype.

## Rules that apply to both

1. **Throwaway from day one, and clearly marked as such.** Put the prototype in its own folder next to the content it prototypes for: `godot-project/<inhalt>/prototyp_<name>/`, e.g. `godot-project/ritter/prototyp_bewegung/`. Prefix the main scene with `prototyp_` too. Project rules from `CLAUDE.md` still apply (typed GDScript, German names, umlauts rewritten), because missing types are configured as errors and the code won't run otherwise.
2. **Trivial to run.** One command starts the prototype scene directly:
   `godot --path godot-project res://<inhalt>/prototyp_<name>/prototyp_<name>.tscn`
   Put that command in the scene's on-screen header and in the hand-over message. **The human starts the game**, never the agent. The agent may run a headless check for script errors: `godot --headless --path godot-project --quit`.
3. **Keyboard and gamepad from the start.** Use Input Map actions, never raw keycodes in game logic. Add any actions the prototype needs to `project.godot`, both keyboard and gamepad bindings.
4. **No persistence.** Values live in the scene and in memory. No save files, no autoloads created just for the prototype.
5. **Skip the polish.** No tests, no error handling beyond what makes it run, no abstractions. Placeholder shapes (`ColorRect`, `draw_rect`) are fine wherever art isn't the question.
6. **Surface the state.** A debug overlay (`CanvasLayer` + `Label`) at the top of the screen shows the question, the active preset/variant, the controls, and the full relevant state, updated every frame.
7. **Keep the answer liftable.** The bit that answers the question (the mechanic, the visual) lives in its own script, separate from the test room and the debug overlay. The overlay reads from it; nothing flows the other way. Once the question is answered, that script is what gets rewritten properly into the real code.
8. **Run gdformat and gdlint** after every GDScript change: `uv run gdformat godot-project` and `uv run gdlint godot-project`.
9. **Capture it when done.** Write the answer (the verdict, the final values, the question it settled) into the ticket. The human commits the prototype to a throwaway branch `prototype/<name>` (never merged) and removes the folder from the working branch; leave a pointer to that branch in the ticket. The working branch keeps only the validated decision. Git writes are always done by the human: tell them exactly which commands to run.
