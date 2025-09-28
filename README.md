# CoppeliaSim Python Snippets for VSCode

This repository contains a CoppeliaSim add-on that automatically exports all available CoppeliaSim API functions and constants as **Python snippets for Visual Studio Code**.  
With these snippets, you get autocomplete-like suggestions when coding against the Remote API in Python.

---

## ✨ Features
- Generates `.code-snippets` file for VSCode.
- Includes both **functions** (e.g. `sim.setObjectPosition(...)`) and **constants** (e.g. `sim.handle_world`).
- Snippets are automatically derived from the official CoppeliaSim API → always up-to-date with your simulator version.
- Works out of the box in **Python development** inside VSCode.

---

## 📦 Installation

1. Clone this repository or download the `coppeliaSnippets.lua` file.
2. Copy the file into your CoppeliaSim `addOns/` folder:
3. Start CoppeliaSim – the add-on will run and generate a file:

4. Place the file into your VSCode user snippets folder:
- **Windows**: `%APPDATA%\Code\User\snippets\`
- **Linux**: `~/.config/Code/User/snippets/`
- **macOS**: `~/Library/Application Support/Code/User/snippets/`

5. Restart VSCode.  
You should now get autocomplete suggestions for all CoppeliaSim API calls in Python.

---

## 🖼 Example

Typing `sim.setO` in VSCode will expand to:

```python
sim.setObjectPosition(objectHandle, position, relativeToObjectHandle)
