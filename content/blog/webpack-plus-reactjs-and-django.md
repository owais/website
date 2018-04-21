+++
title = "Using Webpack transparently with Django + hot reloading React components as a bonus"
date = "2015-05-23T00:31:14+08:00"
keywords = ["blog"]
tags = ["React", "Django", "Webpack"]
description = "Learn how to use Django transparently with webpack. Keep your frontend build pipeline de-coupled from your Django project to get the best of both worlds."
readingtime = 10
ogtype = "article"
ogsection = "Web Development"
+++



If you don't already know <a href="http://webpack.github.io/docs/what-is-webpack.html">webpack</a>, you've some <a href="https://egghead.io/lessons/javascript-intro-to-webpack" target="_blank">catching up to do</a>.

> Webpack is a module bundler that bundles javascript and other assets for the browser. It works really well for applications and javascript libraries and is very simple frontend build tool.
>
>\- Kent C. Dodds <small> -  https://egghead.io/lessons/javascript-intro-to-webpack</small>

<!-- more -->

## Objectives and reasoning

We'll be setting up webpack and keeping it decoupled from django's staticfiles system. Read <a href="http://owais.lone.pw/blog/modern-frontends-with-django/" target="_blank">my earlier post</a> explaining why we'll be handling things this way and not integrating with staticfiles. We'll be using <a href="https://github.com/owais/webpack-bundle-tracker" target="_blank">webpack-bundle-tracker</a> to extract information from webpack and <a href="https://github.com/owais/django-webpack-loader/">django-webpack-loader</a> to use the extracted information for django integration.

## Setting up webpack
We'll use <a href="http://npmjs.com/">npm</a> to manage our frontend dependencies instead of managing them manually in one of the static files directories. You can also use <a href="http://bower.io/">bower</a> in addition to npm.

First let's setup npm in the root of your django project. This will generate a file called `package.json` in your project root. It serves 2 purposes. Imagine requirements.txt and setup.py merged into one. That is package.json for npm packages. If you use the `--save` or `--save-dev` flag when installing a package, it'll save the packages as dependencies in the package.json file. To reinstall the packages, all you need to is run `npm install`. Awesome, right? It gets better. The packages will be installed locally specific to your project under a directory called node_modules like virtualenv. To install a package globally, all you need to do is to use `-g` with npm install.

So, let's generate a package.json file in our project root using npm init

```bash
npm init
```

### Npm dependencies
In addition to webpack, we'll at least need the webpack-bundle-tracker plugin to extract useful information from webpack and store it in as json in a file. This file will act as the link between webpack and django.

Since we'll be setting up webpack with an example reactjs app, we'll also need <a href="https://babeljs.io/" tatget="_blank">babel</a>. Babel is a great Javascript compiler that compiles ES6 into ES5 among other things. This lets use write next generation javascript today and still have run work in current browsers. Babel also supports react's JSX language so we don't need an additional compiler for that. 

We'll also need babel-loader to integrate babel with webpack. Webpack supports pluggable libraries called loaders that add support for different types of files and languages. Loaders can also be chained. For example, you can make a less file go through a less loader to compile it to css and then pass the output  through a css loader. <a href="http://webpack.github.io/docs/using-loaders.html" target="_blank">More on loaders here</a>.

### save vs save-dev
`--save` saves the packages you install as dependencies of your package. The packages that must be installed in order to run your package. `--save-dev` saves the packages as build dependencies, the packages that must be installed to hack on your package. Since we are not going to be publishing a real npm package, either one works. I like to use --save-dev as I only need the packages to build my bundles. Whatever the bundle depends on is included in the bundle itself.


Let's install our first npm packages
```bash
npm install --save-dev react webpack webpack-bundle-tracker babel babel-loader
```


### Create webpack config
```
mkdir -p assets/js
touch webpack.config.js
touch assets/js/index.js
```

Let's create a simple webpack config to load `.jsx` files using babel and use the `webpack-bundle-tracker` plugin to extract information to `webpack-stats.json`. <a href="http://webpack.github.io/docs/configuration.html" target="_blank">More on webpack configuration here</a>.

`webpack.config.js`
```javascript
var path = require("path")
var webpack = require('webpack')
var BundleTracker = require('webpack-bundle-tracker')

module.exports = {
  context: __dirname,

  entry: './assets/js/index', // entry point of our app. assets/js/index.js should require other js modules and dependencies it needs

  output: {
      path: path.resolve('./assets/bundles/'),
      filename: "[name]-[hash].js",
  },

  plugins: [
    new BundleTracker({filename: './webpack-stats.json'}),
  ],

  module: {
    loaders: [
      { test: /\.jsx?$/, exclude: /node_modules/, loader: 'babel-loader'}, // to transform JSX into JS
    ],
  },

  resolve: {
    modulesDirectories: ['node_modules', 'bower_components'],
    extensions: ['', '.js', '.jsx']
  },
}

```

At this point, our directory structure will look something like this.
```
root/
├── manage.py
├── package.json
│── webpack.config.js
│── webpack-stats.json # generated by webpack
├── node_modules/ #contains our JS dependencies. This is like python's virtualenv directory
├── assets/ #added to STATICFILES_DIRS
│   └── js/ # contains out JS source code
│   └── bundles/ # generated by webpack
```


### Compiling our first bundle
Binaries shipped with node packages are installed to `node_modules/.bin/` and it not added to `$PATH` automatically so we need to use full paths to the binaries. Installing binaries globablly like `npm install -g webpack` will add them to one of the binary location on in `$PATH`.

Let's go ahead and compile our first bundle
```bash
./node_modules/.bin/webpack --config webpack.config.js
```

This should create bundle at `assets/bundles/main-[hash].js`. This is good but we don't want to create bundles manually every time we make changes to our code.


### Watch mode
```bash
./node_modules/.bin/webpack --config webpack.config.js --watch
```

This will leave the compiler running and compile bundles automatically when you change any of your source files. You'll need to restart it if you make any changes to the webpack configuration though.

<hr>

## Example react app

<a href="#Django_integration">Skip this part</a> if you already have a react app running.

Let's write a simple "hello, world" react app and use webpack to compile it. We refer to `./assets/js/index` as the entry point of our app in `webpack.config.js` which will look for `index`, `index.js` or `index.jsx` because we've added these three extensions to our webpack config under the key `resolve`.


`assets/js/index.jsx`
```javascript
var React = require('react')
var App = require('./app')

React.render(<App/>, document.getElementById('react-app'))
```

<br>
`assets/js/app.jsx`
```javascript
var React = require('react')

module.exports = React.createClass({
   render: function(){
       return <h1>Hello, world.</h1>
   }
})
```

If you left webpack running in watch mode, it should automatically pick up the changes and compile a new bundle.
<br>

<hr>
## Django integration

Now that we've handed off the build process webpack, only thing we need on the django side is to know which bundle to include in our html pages. This is where `django-webpack-loader` comes in. It'll also raise exceptions when webpack fails to build a bundle and will show some useful information to help debug the problem. During development, webpack loader will also block requests while a new bundle is being generated so that only the latest bundles are loaded.

### Requirements
```bash
pip install django-webpack-loader
```

### Configuration
#### settings.py
```python
import sys
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

STATICFILES_DIRS = (
    os.path.join(BASE_DIR, 'assets'), # We do this so that django's collectstatic copies or our bundles to the STATIC_ROOT or syncs them to whatever storage we use.
)

WEBPACK_LOADER = {
    'DEFAULT': {
        'BUNDLE_DIR_NAME': 'bundles/',
        'STATS_FILE': os.path.join(BASE_DIR, 'webpack-stats.json'),
    }
}

INSTALLED_APPS = (
 ...
 'webpack_loader',
)
```

### Usage
#### In templates
```html
{% load render_bundle from webpack_loader %}
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>Example</title>
  </head>

  <body>
    <div id="react-app"></div>
    {% render_bundle 'main' %}
  </body>
</html>
```
`render_bundle` will render the required `<script>` and `<link>` tags in the template.

Everything we need is in place now. Bundles will be automatically generated (provided you start webpack with --watch). Django will automatically pick up latest bundles from `assets/bundles` directory. During development, django will also block any requests while the bundles are being compiled. It'll also propagate errors generated by webpack to django.

Now that we've webpack working with django, let's make things a little more fun by setting up hot reloading for our react components.

<hr>
## Bonus: Live editing react components
Since we are using pure webpack without any abstraction, we are free to use it however we want without the need to integrate any special with django. Whenever something new comes up for webpack, we can immediately use it without worrying if staticfiles, pipeline or compressor will support it or not. Decoupling FTW!

We'll use a library called <a href="http://gaearon.github.io/react-hot-loader/" target="_blank">react-hot-loader</a> by <a href="https://github.com/gaearon/react-hot-loader" target="_blank">Dan Abramov</a>. We'll also need <a href="https://github.com/webpack/webpack-dev-server">webpack-dev-server</a> to build and serve our bundles if we want to hot reload any modules.

### Requirements
```bash
npm install --save-dev webpack-dev-server react-hot-loader
```

Let's modify `webpack.config.js` to use webpack-dev-server and react-hot-loader
```javascript
var path = require("path")
var webpack = require('webpack')
var BundleTracker = require('webpack-bundle-tracker')


module.exports = {
  context: __dirname,
  entry: [
      'webpack-dev-server/client?http://localhost:3000',
      'webpack/hot/only-dev-server',
      './assets/js/index'
  ],

  output: {
      path: path.resolve('./assets/bundles/'),
      filename: '[name]-[hash].js',
      publicPath: 'http://localhost:3000/assets/bundles/', // Tell django to use this URL to load packages and not use STATIC_URL + bundle_name
  },

  plugins: [
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NoErrorsPlugin(), // don't reload if there is an error
    new BundleTracker({filename: './webpack-stats.json'}),
  ],

  module: {
    loaders: [
      // we pass the output from babel loader to react-hot loader
      { test: /\.jsx?$/, exclude: /node_modules/, loaders: ['react-hot', 'babel'], },
    ],
  },

  resolve: {
    modulesDirectories: ['node_modules', 'bower_components'],
    extensions: ['', '.js', '.jsx']
  }
}
```

Instead of running `webpack --watch`, we'll run webpack-dev-server to both compile and serve our bundles. The server will run on port 3000. `publicPath` in our webpack config refers to this server. Note that the server will by default keep the bundles in memory and not write to disk, so don't be surprised if you don't see anything new in `assets/bundles/`. Let's use webpack-dev-server's API to create a new instance of the server and pass webpack initialized without config file to it. We'll store this as `server.js` in our project root and use node run the server.

`server.js`
```javascript
var webpack = require('webpack')
var WebpackDevServer = require('webpack-dev-server')
var config = require('./webpack.config')

new WebpackDevServer(webpack(config), {
  publicPath: config.output.publicPath,
  hot: true,
  inline: true,
  historyApiFallback: true
}).listen(3000, '0.0.0.0', function (err, result) {
  if (err) {
    console.log(err)
  }

  console.log('Listening at 0.0.0.0:3000')
})
```

Taken from https://github.com/gaearon/react-hot-boilerplate/

Now instead of running webpack in watch mode, we run webpack-dev-server like this
```bash
node server.js
```

Done! Any changes made to the react components will reflect in the browser. No reload needed. Magic! right?

If you are interested in hot reloading react components, you should read this https://medium.com/@dan_abramov/the-death-of-react-hot-loader-765fa791d7c4

<hr>

## Production environments

Production bundles are different from local ones for various reason. I like to have slightly different webpack config for production, generate them locally and commit the bundle(s) and stats file to the code base. As we store our bundles in assets and django is configured to look for static files in the assets directory, we don't need to do anything special here. Everything should just work with your existing system of serving static content in production.

We can either treat the bundles as part of source code or distribution. I like to treat them as source code even though they are not because I don't like building bundles on production or having my production systems depend on dev dependencies. By treating them as source code, I build them locally before preparing a new release, sync them to my static file server, commit the new stats file to source and push out the new release to the production servers. As soon as they workers on production restart, they automatically refer to the new bundles. That said, you are completely free to handle them the opposite way. You can tell git to ignore the generated bundles and stats file so they are not pushed to production and then run webpack on production just before running collectstatic. You'll need all your npm dependencies on production as well obviously.

**Important**: Make sure production config doesn't use react-hot-loader or webpack-dev-server. Also make sure you use something like Uglify to compress your code and strip off any code only meant to be used in development.
**Note**: You should add our local webpack stats file and local bundles to .gitignore as they serve no purpose outside your local environment.
**Note**: I like to store all common configuration between local, staging and production in a "base" config file and import this file from final configs.


`webpack.base.config.js`
```javascript
var path = require("path")
var webpack = require('webpack')
var BundleTracker = require('webpack-bundle-tracker')

module.exports = {
  context: __dirname,

  entry: './assets/js/index',

  output: {
      path: path.resolve('./assets/bundles/'),
      filename: "[name]-[hash].js"
  },

  plugins: [
  ], // add all common plugins here

  module: {
    loaders: [] // add all common loaders here
  },

  resolve: {
    modulesDirectories: ['node_modules', 'bower_components'],
    extensions: ['', '.js', '.jsx']
  },
}
```

<br/>
`webpack.local.config.js`
```javascript
var path = require("path")
var webpack = require('webpack')
var BundleTracker = require('webpack-bundle-tracker')

var config = require('./webpack.base.config.js')

// Use webpack dev server
config.entry = [
  'webpack-dev-server/client?http://localhost:3000',
  'webpack/hot/only-dev-server',
  './assets/js/index'
]

// override django's STATIC_URL for webpack bundles
config.output.publicPath = 'http://localhost:3000/assets/bundles/'

// Add HotModuleReplacementPlugin and BundleTracker plugins
config.plugins = config.plugins.concat([
  new webpack.HotModuleReplacementPlugin(),
  new webpack.NoErrorsPlugin(),
  new BundleTracker({filename: './webpack-stats.json'}),
])

// Add a loader for JSX files with react-hot enabled
config.module.loaders.push(
  { test: /\.jsx?$/, exclude: /node_modules/, loaders: ['react-hot', 'babel'] }
)

module.exports = config
```


<br/>
`webpack.prod.config.js`
```javascript
var webpack = require('webpack')
var BundleTracker = require('webpack-bundle-tracker')

var config = require('./webpack.base.config.js')

config.output.path = require('path').resolve('./assets/dist')

config.plugins = config.plugins.concat([
  new BundleTracker({filename: './webpack-stats-prod.json'}),

  // removes a lot of debugging code in React
  new webpack.DefinePlugin({
    'process.env': {
      'NODE_ENV': JSON.stringify('production')
  }}),

  // keeps hashes consistent between compilations
  new webpack.optimize.OccurenceOrderPlugin(),

  // minifies your code
  new webpack.optimize.UglifyJsPlugin({
    compressor: {
      warnings: false
    }
  })
])

// Add a loader for JSX files
config.module.loaders.push(
  { test: /\.jsx?$/, exclude: /node_modules/, loader: 'babel' }
)

module.exports = config
```
<br>
`settings.py`

```python
if not DEBUG:
    WEBPACK_LOADER['DEFAULT'].update({
        'BUNDLE_DIR_NAME': 'dist/',
        'STATS_FILE': os.path.join(BASE_DIR, 'webpack-stats-prod.json'
    })
```

Generate production bundles by invoking webpack one time with production config
```bash
./node_modules/.bin/webpack --config webpack.prod.config.js
```

This will create production bundles in `./assets/dist/` and the stats file at `./webpack-stats-prod.json`.

`collectstatic` will automatically pick up the newly created bundles.


## Tip

Typing the full path of the webpack binary is hard. We can create aliases for the above commands in our package.json to fix this.

```javascript
  ...
  'scripts': {
    'build': 'webpack --config webpack.config.js --progress --colors',
    'build-production': 'webpack --config webpack.prod.config.js --progress --colors',
    'watch': 'node server.js'
  },
  ...
```

Now we can run `npm run build`, `npm run build-production` or `npm run watch`. There is no need to specify the full path of the webpack binary as NPM knows where to find it.
