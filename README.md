![Loading Screen](https://raw.github.com/ndrwhr/tumbler/master/images/loading.png)

### What is this?

A simple physics simulation/meditation/relaxation experiment. Which you can view [here](http://andrew-hoyer.com/experiments/tumbler)

### Why?

Ultimately the main motivating factor for this experiment was my desire to learn a bunch of "new" technologies:

* [Box2dWeb](https://code.google.com/p/box2dweb/) - Rather than roll my own physics I decided to finally take the plunge and learn how to use a real physics engine.
* SVG - Most of my prior experiments were built using Canvas or DOM rendering. This turned out to be a good chance to try out SVG.
* [CoffeeScript](http://coffeescript.org/) - 99.9% of my coding at work is in JS. I was curious what all the hubbub was about.
* [Web Audio API](http://www.w3.org/TR/webaudio/) - As a last minute decision, I decided it would be nice to play with something entirely new.

What came out of the combination of the above is something that I find myself staring at for unexpectedly long periods of time.

### Reference Links:

* [iforce 2d - Box2d C++ tutorials](http://www.iforce2d.net/b2dtut/)
* [Box2d Flash API Docs](http://www.box2dflash.org/docs/2.1a/reference/)
* [HTML5 Rocks - Getting Started with Web Audio API](http://www.html5rocks.com/en/tutorials/webaudio/intro/)
* [HTML5 Rocks - Developing Game Audio with the Web Audio API](http://www.html5rocks.com/en/tutorials/webaudio/games/)
* [CoffeeScript](http://coffeescript.org/)
* [Freesound.org](http://www.freesound.org/)
    * All sounds are from the the [glockenspiel pack](http://www.freesound.org/people/pmedig/packs/10341/) by [pmedig](http://www.freesound.org/people/pmedig/)

### Building

1. Run `npm install`.
2. `grunt`.
3. In another terminal run a server to serve this projects directory (e.g. `python -m SimpleHTTPServer 8080`).
4. Open up the browser