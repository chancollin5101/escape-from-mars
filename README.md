# Escape From Mars

This is a horizontal scrolling game made in Mips assembly code emulated using the Mars Mips Simulator. It requires the Keyboard and Display MMIO and the Bitmap Display to be connected to MIPS.

Bitmap Display Settings:
```
  Unit Width: 8

  Unit Height: 8

  Display Width: 256

  Display Height: 256
  
  Base Address for Display: 0x10008000 ($gp)
```

This game is similar to the game Space Invaders, in the sense that the player is controling a spaceship across space and there are a lot of obstacles/enemy ships along the way. The theme of the game is escaping from an explosion from Mars. The player can use WASD for directional input, p to restart and q to quit the game at the Game Over stage. 

Demo: [Demo Link](https://www.youtube.com/watch?v=SOpnTmNc1zI&ab_channel=CollinChan)
