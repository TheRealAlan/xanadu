# Xanadu
A text-based game engine.

View a demo [here](http://therealalan.github.io/xanadu/).

### Get the Repo
``` bash
git clone https://github.com/TheRealAlan/xanadu.git
```

### Get the Gems
``` bash
bundle install
```

### Get the Bower Packages
``` bash
bower install
```

### Run It
``` bash
middleman server
```

How it Works
============

At the moment the development environment isn't very flexible. It's built in [Middleman](https://middlemanapp.com/) using HAML, Sass and CoffeeScript. The core engine will be ported to a submodule at some point to make this more flexible.

If you're not familiar with Middleman, the `/source` folder acts as the root of site. A game consists of `.json` files stored in the `/levels` directory. A config system for custom naming will be added but for now they're hardcoded in `js/_levels.coffee`. Levels currently consist of only scenes with valid / invalid responses but will be 
expanded to include acts as well as a global set of interactions that will add layers to the experience.

Effects and themes can also be added / edited to the game. Custom visual effects can be called in an effects array inside of a scene. Custom themes have not yet been added.
