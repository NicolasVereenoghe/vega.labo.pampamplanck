# PamPam Planck

PamPam Planck is a game demo written using [Planck.js](https://github.com/shakiba/planck.js) and Haxe.

You can play the demo **[here](http://a-lyrae.com/demo/pampamplanck/)**

Drag the above red items to build a track. When you're ready, tap the red ball, so that the character shoot at the ball and try to reach the other blue character. Play through 8 levels.

The purpose was to write Haxe externs for Planck.js. This is a Haxe project for the web. Haxe and the JavaScript libraries are embed into the project, you can run the Haxe project without configurating. Open the game.hx file.

Planck.js lib embed with externs : [haxe/lib/planck,js/](./haxe/lib/planck,js/)
World and bodies settings : [src/bayam/game/Tablo.hx](./src/bayam/game/Tablo.hx)

The demo is extracted from a work for a client. I redeveloped a former Flash Box2D game to JavaScript, and with the same settings in order to get the same results.

From the Flash original settings, I only needed to rise the World iterations properties to stabilise stacked items.

All copyright contents (arts, sounds) have been removed or replaced by place-holders.