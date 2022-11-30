Code in here is me attempting to get my head around raylib and the haxe bindings raylib-hx - https://github.com/foreignsasquatch/raylib-hx
ks` branch of my fork.

To install the lib do this -

```shell
haxelib git raylib-hx https://github.com/foreignsasquatch/raylib-hx.git
```

To build and run the project - 

```shell
haxe build.hxml
```

Currently the project consists of

 - a player object with simple velocity based movement (zero friction)
 - cursor key bindings to steer the player around
 - simple scene with a background
 - simple camera which centers on the player, and keeps within scene boundaries
 - collidable obstacles placed on mouse click
 - simple collision between player and obstacles