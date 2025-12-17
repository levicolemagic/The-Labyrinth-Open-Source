# Contributing

We welcome contributions to The Labyrinth!

## Legal Agreement

By contributing to this project, you agree that your contributions will be licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](./LICENSE).

**Important:** You also acknowledge and agree to the "No Warranty" disclaimer provided in the [README](./README.md#license) and the [LICENSE](./LICENSE) file. This software is provided "AS IS" without any warranty of any kind.

## Getting Started

1.  Fork the repository.
2.  Create a feature branch (`git checkout -b feature/amazing-feature`).
3.  Commit your changes (`git commit -m 'Add amazing feature'`).
4.  Push to the branch (`git push origin feature/amazing-feature`).
5.  Open a Pull Request.

## Safety Guidelines

Since this project involves autonomous agents with file system access:
*   **Test Safely:** Always test your changes in a sandboxed environment first.
*   **No Destructive Defaults:** Ensure your changes do not default to destructive actions (e.g., `rm -rf` without checks).
*   **Documentation:** Update documentation if your changes affect security or setup.
