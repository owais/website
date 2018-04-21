+++
title = "Let's modernize the way we handle frontend code with Django"
date = "2015-05-22T02:03:50+08:00"
tags = ["Django", "Webpack", "React"]
description = "What we should do to make Django play well with the fast moving Javascript ecosystem"
ogtype = "article"
ogsection = "Web Development"
+++

## The problem
Django is great but it's frontend toolchain is stuck in the past. Imagine if someone told you to copy all your python module dependencies in your source tree and import them from there. Unthinkable, right? We've pip and virtualenv for that. We also have npm and bower for frontend packages but we still choose to manage frontend packages manually or write very complex wrappers over javascript tools so that we only have to deal with Python. I think this needs to change. The javascript community has come up with some awesome pieces of software. Npm is one of the best, probably the best package manager I've come across. Tools like grunt, gulp,
 browserify, webpack are too good to ignore.

<!-- more -->

### Problems with the currect approach

  * Manually maintaining dependencies is a pain.
  * No integration with managers like npm and bower.
  * Horrible for frontend engineers and designers to work with.
  * Backend and frontend systems are tightly coupled and sometimes limit each other.


## What about django-npm, pipeline and compressor?
Apps like django-pipeline and django-compressor have done a great job with static assets. I've been a great fan of django-pipeline actually but I hate how they take away all the transparency in order to make things a bit magical. They are limited in what they can do by the staticfiles system. They are opaque and make it harder to debug problems. They also need companion apps for to integrate any new javascript tool like gulp or browserify. Even after having all these wrappers, the experience can be quite rough at times. Documentation and resources available for javascript tools are not directly applicable sometimes when using these wrappers. You've an additional layer of software and configuration to worry about or wonder how your python configuration translates to the javascript. Things can be much better.


### Problems with wrappers

  * They are opaque, slow and hard to debug.
  * Limited by django's staticfiles system.
  * Docs, stackoverflow, blog posts, written for the javascript tools don't directly apply to the django wrapper apps.
  * Limited by staticfiles.
  * Very tightly coupled with django.

## So should we abandon staticfiles?
No, but we should limit it to just collecting pre-bundled static assets to the target directory or static file servers. We should not hook post-processors into it. The build process for frontend assets should be completely decoupled from staticfiles.

## How do we integrate the frontend tools with django then?
For simpler cases, we don't even need to integrate. We can use things like gulp or grunt to compile assets and then use collectstatic to sync the builds, but we need some sort of integration to make things a bit smoother. During development, it makes sense to return 500 error code when a build fails so one knows immediately where to look for the problem. It also makes sense to block a request while a build is being compiled to make sure you don't test older code in the browser. For production use, we can configure our frontend tools to use hashed names in the builds; It would be nice to have an easy way to get reference to hashed bundles in django. In my opinion, integration should stop here. We should not spawn processes from python, translate config in settings.py to native JS config.


I suggest we use bridges, not wrappers. Instead of writing wrappers around something like webpack and spawning webpack processes form within django, we should run webpack independently and pipe the output to django. If we can come up with a standard for this, we would only have to write a single bridge application for django. Then instead of writing django apps that wrap the javascript tools, we write plugins for the tools that emit useful data to be consumed by django or any other framework.

## webpack-bundle-tracker + django-webpack-loader
<a href="https://github.com/owais/django-webpack-loader/" target="_blank">django-webpack-loader</a> and <a href="https://github.com/owais/webpack-bundle-tracker" target="_blank">webpack-bundle-tracker</a> implement a system like this. webpack-bundle-tracker plugin emits necessary information about webpack's compilation process and results so django-webpack-loader can consume it. django-webpack-loader does not care how you use webpack. You could control it from gulp, use the dev server, use the --watch mode or manually run it after every change. Head over to <a href="https://github.com/owais/django-webpack-loader/">https://github.com/owais/django-webpack-loader/</a> to see how it all works or read <a href="http://owais.lone.pw/blog/webpack-plus-reactjs-and-django/" target="_blank">this guide</a> for setting it all up with optional live reload for react components.


### What this solves

 * Use proper package managers like npm and bower instead of manually managing source files.
 * Use webpack transparently without any limitations and leverage all the documentation and resources.
 * Handle your frontend assets however you want. Run webpack in watch mode, use grunt, gulp, webpacks' dev server or anything you desire. No limitations.
 * Make your frontend engineers and designers happy! :)
 * Completely decouple frontend build process from django. You could build and serve your static assets from a completely different system as long you give django access to the stats file generated by webpack-bundle-tracker.

### Limitations of this approach (for now)

 * Harder to store static files in app directories (totally worth it).
 * Doesn't integrate with static files provided by 3rd party apps yet.
 * Need to setup your frontend toolchain manually but that is very easy most of the time.

## Related articles

* <a href="http://owais.lone.pw/blog/webpack-plus-reactjs-and-django/" target="_blank">Using Webpack transparently with Django and + reloading React components as a bonus</a> 
