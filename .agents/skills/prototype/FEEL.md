# Feel Prototype

A Godot test scene where the user **plays a mechanic and tunes it until it feels right**. Use this when the question is about game feel or behaviour: movement, jumping, attacks, hit feedback, camera, enemy or boss patterns. These things look fine as numbers on paper and only feel wrong with a controller in hand.

If the question is "what should this look like", this is the wrong branch. Use [LOOK.md](LOOK.md).

## When this is the right shape

- "Does the jump feel too floaty?"
- "How fast should the knight run, how hard should he stop?"
- "Is this attack combo readable, does the hit feel heavy enough?"
- "Does the boss's charge give enough warning?"
- Anything where someone wants to **hold a controller, play, and say 'more' or 'less'**.

## Process

### 1. State the question

Before writing code, write down what is being prototyped and what question it answers. One or two sentences, shown in the on-screen header (not just a comment), so it can be checked later.

### 2. Build the mechanic as its own script

The mechanic (e.g. the knight's movement) is one script with a clear surface. It owns its state and exposes it for reading. No overlay code, no test-room code inside it.

Every tunable value is an `@export` var, grouped with `@export_group` (e.g. "Laufen", "Sprung", "Wand"), with a sensible `@export_range` and a short German comment saying what it does and in which unit (px, px/s, px/s², s). Start from known reference values (research tickets, the web version) and note the source next to the value.

### 3. Build the test room

A small level that pushes the mechanic through the awkward cases, not just the happy path. Build it from the project's real building blocks where they exist (e.g. the block grid), otherwise from placeholder shapes. Name the areas in the room so feedback can point at them ("the gap at the overhang feels too wide").

For movement, for example: flat ground, a gap of exactly the max jump width, a wall to slide and jump on, an overhang, platform blocks, a long run-up, a narrow shaft.

### 4. Make tuning fast

- **Live editing:** the user changes `@export` values in the Inspector's remote scene tree while the game runs. Say so in the hand-over.
- **Presets:** 2–4 named value sets (e.g. "Broforce-Werte", "schwerer Ritter", "Arcade"), switched with F1–F4. Presets must be **really different**, not ±5 %. They answer "which direction?" before live tuning answers "how much?".
- **Dump values:** one key (e.g. F9) prints all current values to the output as copy-ready GDScript lines, so a tuned state can be pasted into the ticket.
- **Reset:** one key (e.g. R) puts the player back at the start.

### 5. Surface the state

The overlay shows, every frame: active preset, controls, and the mechanic's live state (e.g. velocity, on floor/wall/ceiling, coyote and buffer timers, current animation state). Where a value just changed meaningfully (landed, wall contact lost), make it visible long enough to read.

### 6. Hand it over and tune together

Give the user the run command and the controls. The interesting moments are "that felt wrong just now": ask what exactly happened, check the overlay, change one value at a time. If they want a new case in the test room or a new preset, add it. Prototypes evolve.

### 7. Capture the answer and the prototype

Record the final values and the reasons in the ticket, then capture the prototype as the [SKILL](SKILL.md) describes. The mechanic script is the part worth lifting; the test room, presets and overlay stay on the throwaway branch.

## Anti-patterns

- **Don't tune by reasoning alone.** If the user hasn't played it, the value isn't validated.
- **Don't change several values at once** when chasing a specific complaint. You won't know which one helped.
- **Don't build the real architecture.** No base classes, no reusable component system. One question, one scene.
- **Don't blur mechanic and test harness.** If the mechanic script references the overlay or the presets, it's no longer liftable.
- **Don't merge the prototype folder into the working branch.** It's rewritten properly when folded in.
