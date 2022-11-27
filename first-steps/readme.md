Code in here is me attempting to get my head around raylib and the haxe bindings raylib-hx - https://github.com/foreignsasquatch/raylib-hx

I've made some tweaks to the haxelib which may end up in the main repo after I discuss with the lib maintainer but for now you need to use the `tweaks` branch of my fork.

To install my tweaked version of the lib do this -

```shell
haxelib git raylib-hx https://github.com/jobf/raylib-hx.git tweaks
```

To build and run the project - 

```shell
haxe build.hxml
```

Currently the project consists of

 - a player object with simple velocity based movement
 - cursor key bindings to steer the player around
 - simple scene with a background
 - simple camera which centers on the player