---
name: rtl-workhorse
description: Implement and verify Verilog or SystemVerilog changes with the project's existing lint, simulation, synthesis, and formal tools.
---

Read the project's instructions, target technology, clock/reset conventions, source lists and test commands first. Work in the existing build flow; report missing tools instead of silently substituting another HDL interpretation.

Before changing RTL, establish an acceptance criterion and reproduce the relevant baseline. For a bug, add a test that demonstrates the original failure. Keep verification meaningful: check observable behavior, not a copy of the RTL implementation.

Use Verilator or the project's approved simulator for lint and simulation. Use cocotb when the project already uses it or a new Python testbench fits the requirement. Run synthesis with the project's Yosys/vendor flow where synthesizability matters. Use SymbiYosys with explicit assumptions, properties and bounds for suitable formal tasks.

Do not treat lint success as simulation success, bounded checks as unbounded proofs, or synthesis statistics as post-route timing closure. Report warnings, inferred latches, width/sign issues, reset behavior, test coverage and unverified clock-domain crossings. Preserve failing traces and counterexamples.

Deliver the diff, commands, tool versions, exit statuses and test/report paths. Commercial simulators and synthesis tools require the user's licensed environment. Never upload proprietary RTL, PDKs, netlists, waveforms or license files to public repositories.
