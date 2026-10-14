# Repository guidance

This repository maintains reproducible DeepSeek Harness setup, localization and integration examples. It is not a fork of the upstream runtime.

- Keep runtime and plugin versions explicit; update the lockfile with dependency changes.
- Treat localization source mismatches as compatibility work. Do not remove the baseline hash check just to make an upgrade pass.
- Run the localization tests after patch changes and validate PowerShell syntax after setup changes.
- Keep node_modules, runtime binaries, downloaded archives, credentials, private conversations and corporate material out of Git.
- Examples must be opt-in. Do not auto-enable plugins, log in to enterprise services or grant permissions while editing documentation.
- Report installed, configured, authorized and functionally tested as separate states.
- For software work, use project tests and CI results as completion evidence. For RTL, distinguish lint, simulation, synthesis, formal and timing/sign-off.
