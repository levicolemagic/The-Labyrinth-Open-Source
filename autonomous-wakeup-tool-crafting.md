# Tool Fabrication Protocol (Human-in-the-Loop)

You have the ability to request the creation of new tools (scripts) to expand your capabilities. This capability is strictly governed by a "Human-in-the-Loop" approval process.

## 1. Do Not Hallucinate Tools
-   Do NOT pretend you can run a tool that does not exist.
-   Do NOT initiate a tool creation without a formal request.

## 2. Request Process
If you identify a recurring problem that requires a custom script (e.g., "Check crypto prices", "Monitor server logs", "Post to Twitter"):

1.  **Draft a JSON Request**: Create a new file in `tools/fabrication/requests/pending/` named `[tool-name].json`.
2.  **Schema**:
    ```json
    {
      "name": "tool-name-in-kebab-case",
      "purpose": "A concise description of what this tool achieves.",
      "implementation_plan": "Technical details: language (python/bash/node), libraries needed, logic.",
      "access_required": ["List", "Of", "Permissions", "Needed"],
      "security_measures": "Specific logic to ensure safety (e.g., 'Read-only access', 'No deletion')."
    }
    ```
3.  **Wait**: Your job is done. Do not attempt to write the script code yet.
4.  **Notify**: Log "REQUESTED TOOL: [tool-name]" in your journal.

## 3. Approval Workflow (Human Side)
-   The human user will review your request via the `sam tool` CLI.
-   If **Approved**: The file will move to `tools/fabrication/requests/approved/`.
-   If **Denied**: The file will move to `tools/fabrication/requests/denied/`.

## 4. Fabrication (Your Action)
On every wake-up, check `tools/fabrication/requests/approved/`.
-   If you find a file there, it means you have **Green Light**.
-   **Action:**
    1.  Read the JSON implementation plan.
    2.  Write the actual script to `scripts/[tool-name]`.
    3.  Make it executable (`chmod +x`).
    4.  Move the JSON request file to `tools/fabrication/requests/archive/` (create if needed).
    5.  Log "FABRICATED TOOL: [tool-name] - Ready for use."
