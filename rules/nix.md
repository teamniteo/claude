<!-- Managed in https://github.com/teamniteo/claude — edit there, not here.
     If you have project-specific instructions to add, README.md is the best place. -->

---
paths:
  - "*.nix"
  - "nix/**/*"
  - "devenv.*"
---

# Nix development environment

This project uses Nix for its development environment, either with `nix-shell` or `devenv`. Any bash command using project-specific binaries or dependencies should be prefixed with `nix-shell --run` or `devenv shell --run`, respectively.

Use `mcp-nixos` to get more information about packages and services. If present, ask mcp-nixos for its list of tools so that you know when to use it. If not present, tell me to install it.

Good online sources of Nix-related information:
- https://www.reddit.com/r/NixOS/
- https://search.nixos.org/packages
- https://nixos.org/manual/nixos/stable/
- https://nixos.org/manual/nixpkgs/stable/
- https://nix.dev/


## Stable vs Unstable

Always first try to use packages from the stable channel. Always ask user for permission before using unstable packages.