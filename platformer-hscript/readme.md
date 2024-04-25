Code in here builds on exploration in `first-steps`.

It's a simple platformer.

You need haxe and raylib-hx.

To install the lib do this -

```shell
haxelib git raylib-hx https://github.com/foreignsasquatch/raylib-hx.git
```

To build and run the project - 

```shell
haxe build.hxml
```

Currently the project consists of

 - a player object with velocity based movement (including acceleration for more natural motion)
 - cursor keys 🠔 🠖 moves the player
 - cursor key 🠕 makes player jump
 - simple scene with a floor
 - simple camera which centers on the player, and keeps within scene boundaries