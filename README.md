# MixablyMac

Player with Magic

## Package the binary

To build the package, follow the steps here using the files inside `Scripts/` folder

1. In Xcode, go to Product -> Archive
2. After a long run, the binary is built
3. In Organizer (you can open this anytime in Window -> Organizer), choose the latest build
4. Export... and select Export as a Mac Application
5. The binary is saved to Desktop
6. Copy the files in `Script/` folder to the same location as the exported binary
7. In command line, go to the same folder
8. Run `appdmg appdmg.json ./Mixably.dmg`, you can change the file name of `dmg` to anything
9. The installation dmg can be distributed using any channel.

Thanks!!
