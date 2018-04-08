+++
title = "Remember The Rhythm"
date = "2011-11-13T05:30:00+08:00"
tags = ["Projects"]
description = ""
+++


I recently switched to Rhythmbox from Banshee and I'm loving it. It's fast, loads up almost instantly, doesn't consume as much resources as Bansee and doesn't crash after every 3 songs. I do miss some features that Banshee had though like remembering the last playing song. So, I created a plugin for rhythmbox just to do that. It remembers the last playing entry (song, radio station, podcast, etc), playback time, browser filters (genre, artist and album) and playlists. It remembers these things (except playback time) even if Rhythmbox crashes for some reason.

<!-- more -->

Install on Ubuntu

```
sudo add-apt-repository ppa:loneowais/ppa
sudo apt-get update
sudo apt-get install remember-the-rhythm
```

For other distros, install from the [tarball](https://github.com/owais/remember-the-rhythm/tarball/master)
```
sudo make install
```

![](http://feeds.feedburner.com/~r/Owaislone/~4/pls0gRg_P-k)
