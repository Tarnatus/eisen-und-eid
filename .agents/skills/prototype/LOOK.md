# Look Prototype

Several **radically different visual variants** in one Godot scene, switchable by key. The user flips between them in the running game, picks one (or steals bits from each), then the rest is thrown away.

If the question is about how something plays rather than how it looks, this is the wrong branch. Use [FEEL.md](FEEL.md).

## When this is the right shape

- "What should the HUD for four players look like?"
- "Which placeholder style for the knight reads best at 480 × 270?"
- "How loud should the hit effects be visually?"
- "What should the title screen look like?"

## Show it in context

A variant is much easier to judge **inside a real game situation**: real resolution, a level behind it, moving characters, four players' worth of HUD. A HUD alone on a grey background looks fine every time. If the real scene exists, show the variants there; otherwise build a rough stand-in situation (a few blocks, a knight, some enemies) at the project's internal resolution.

## Process

### 1. State the question and pick N

Default to **3 variants**, at most 5. Write the plan in one line in the on-screen header, e.g. "Three HUD variants for 1–4 players, switch with ← →".

### 2. Build radically different variants

Each variant is its own scene (`prototyp_<name>_variante_a.tscn`, …) with a short German name shown in the switcher (e.g. "A: Ecken", "B: Leiste unten", "C: über den Köpfen").

Variants must be **structurally different**: different layout, different information hierarchy, different way of reading the state. Not just different colours. If two come out too similar, redo one with an explicit constraint ("no bar along the edge").

All variants respect the project's fixed choices (resolution, pixel scale, palette once it exists).

### 3. Wire them together

The prototype scene instantiates the active variant and swaps it on key press. Shared game state (health, players, boss life) comes from one stand-in source above the variants, so every variant shows the same situation.

Add a few keys to change that situation (e.g. a player joins, takes damage, boss loses health), so variants are judged in motion, not as a still frame.

### 4. Build the switcher

A small overlay bar at the bottom, visually distinct from the game (high contrast, clearly debug):

- **← / →** (keyboard) and **shoulder buttons** (gamepad) cycle the variants, wrapping around.
- The label shows the variant key and name, e.g. `B (Leiste unten)`.
- **F12** hides the switcher and overlay, for a clean look and screenshots.

### 5. Hand it over

Give the user the run command and the keys. The useful feedback is usually "the life display from B with the placement from C": that combination is the actual design.

### 6. Capture the answer and clean up

Record which variant won and why in the ticket, then capture the prototype as the [SKILL](SKILL.md) describes. The winner is rebuilt properly in the real scene; all variants and the switcher stay on the throwaway branch.

## Anti-patterns

- **Variants that differ only in colour.** That's a tweak, not a prototype.
- **Sharing too much between variants.** Each variant must be free to throw out the layout.
- **Judging at the wrong scale.** Always look at the project's internal resolution, scaled the way the real game scales.
- **Promoting a variant scene directly.** It was built under prototype rules; rebuild it properly.
