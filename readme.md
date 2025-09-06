# 🎮 PICO-8 Games Collection

A collection of retro games created with PICO-8, the fantasy console that captures the essence of 80s video game development.

## 🕹️ About PICO-8

PICO-8 is a fantasy console created by Lexaloffle that simulates the technical limitations of classic consoles:

- **Resolution:** 128x128 pixels
- **Color palette:** 16 fixed colors
- **Audio:** 4 sound channels
- **Code:** Lua with token limitations
- **Sprites:** 128 sprites of 8x8 pixels

## 🎯 Games Included

### 🚀 Available
- Dont Die On The Graph

## 📁 Repository Structure

```
pico8-games/
├── index.html # Main page with game list
├── README.md  # This file
├── games/     # Folder with .p8 files
│   └── ddotg.p8
├── sources/
│   └── ddotg.lua
└── web/        # Exported HTML/JS versions
     ├── ddotg.html
     └── ddotg.js
```

## 🚀 How to Play

### Option 1: Local Web Browser
1. Open `index.html` in your browser
2. Select the game you want to play
3. Enjoy!

### Option 2: Original PICO-8
1. Download and install [PICO-8](https://www.lexaloffle.com/pico-8.php)
2. Load the `.p8` file of the game you want
3. Run with the `run` command

### Option 3: Remote Web Browser
1. Go to github.com/original-pico-8/index.html
3. Run games

## 🎮 Controls

Standard PICO-8 controls are:

- **Arrows/WASD:** Movement
- **Z/C:** O Button (main action)
- **X/V:** X Button (secondary action)
- **Enter:** Pause/Menu

## 🛠️ Development

### Tools Used
- **PICO-8:** Main development engine
- **VSCode:** To get some extra development features

### How to Contribute
1. Fork this repository
2. Create a branch for your feature (`git checkout -b new-feature`)
3. Commit your changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin new-feature`)
5. Open a Pull Request

### Adding a New Game
1. Place the `.p8` file in the `games/` folder
2. Export the web version and place it in `web/`
3. Update the `games` array in `index.html`
4. Update this README

## 📚 PICO-8 Resources

- [Official PICO-8 Site](https://www.lexaloffle.com/pico-8.php)
- [PICO-8 Manual](https://www.lexaloffle.com/dl/docs/pico-8_manual.html)
- [PICO-8 Cheat Sheet](https://ztiromoritz.github.io/pico-8-cheatsheet/)
- [PICO-8 Community](https://www.lexaloffle.com/bbs/?cat=7)

## 🤝 Credits

- **Developer:** SteelCodeTeam
- **Engine:** PICO-8 by Lexaloffle
- **Inspiration:** Classic 80s arcade games

---

*Thank you for visiting my PICO-8 games collection! I hope you enjoy playing them as much as I enjoyed creating them.* 🎮✨
