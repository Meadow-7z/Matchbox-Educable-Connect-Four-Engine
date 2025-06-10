Matchbox Educable Connect Four Engine, v1.0.0

---Introduction---

Hello, and thank you for downloading my project! This is mostly a proof-of-concept to practice programming before getting into active game development, but I hope you enjoy it regardless. ^^

If you downloaded this program and want to view or edit the project files, you can find them at this link: https://github.com/Meadow-7z/Matchbox-Educable-Connect-Four-Engine (Or if you're already here, hi!)



---Starting the game---

To get started, you'll see four drop-down menus! These are used to determine the game settings before you start.

Player 1 & Player 2: These are used to decide whether each player will be controlled by a human, by a bot that makes random moves, or by MEC4E, which is the learning algorithm! If you choose MEC4E for either option, it'll prompt you to select a save (see: SAVE SELECT).

Speed: This sets the game speed! Normal lets the chips fall at a leisurely pace, Fast makes them fall at a breakneck pace, and on Instant speed you can't even see the chips falling!

Continue: Manual continuing makes you press a button to go to the next game, while Auto continuing will make the next game start automatically after a second. Combine Auto continuing with Instant speed, and the game won't even wait! (Ideal for training MEC4E against itself or the random bot ^^)

SAVE SELECT: Type whatever you want for the name of your save (it'll stop you from using any invalid characters), or leave it blank if you want to use the default save! When typing in the name of your save, the box will turn green if you have a save file with that name. This is useful if you're trying to access a specific save and you want to make sure you got the name right. Do also note that player 1 and player 2 will have separate saves; since the learning algorithm works by gamestate, there isn't any information it could retain from one side that would be usable to the other. ^^



---Playing the game---

If either player is human, they'll need your input! Simply click the column where you'd like to place your chip, and that's it! Otherwise, you can watch the program play against itself for however long you like. If you have autplay enabled, feel free to use the "Stop Autoplay" button at any time to pause it! (It'll continue the autoplay once you start the next game, so no need to worry about restarting the program ^^)

If you're training MEC4E, make sure to save its training data afterwards!! There should be a "Save" prompt at the end of each game, you'll have to stop the autoplay if you have it enabled!! Once the button changes to "Saved", that's it! You can feel free to close the program after that.



---Importing/exporting data---

If you want to share your training data, or use someone else's shared data, it's as simple as finding the game's ".matchbox" files and moving them around! This project uses Godot's default file paths, so where you can find them depends on your OS.

Windows: %APPDATA%\Godot\app_userdata\Matchbox Educable Connect Four Engine
macOS: ~/Library/Application Support/Godot/app_userdata/Matchbox Educable Connect Four Engine
Linux: ~/.local/share/godot/app_userdata/Matchbox Educable Connect Four Engine

The name of each file will just be the name of your save, with a little "a" or "b" at the end. Those letters are to differentiate the Player 1 and Player 2 training data respectively, so make sure to pick the one you're trying to export (or both)!

If you're importing someone else's training data, simply drag it into that same folder! Once you run the program, you should be able to access that data by typing the filename into the save select, without the "a" or "b" at the end. If it lights up green, you know it's working!
