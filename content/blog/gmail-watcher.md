+++
title = "Announcing GmailWatcher"
date = "2010-07-06T05:30:00+08:00"
tags = ["Gmailwatcher", "Ubuntu", "Projects"]
description = ""
+++


In case you don't already know, GmailWatcher is a Gmail notifier specifically designed for the Ubuntu Operating System. It relies heavily on Ubuntu specific packages like MeMenu, Notifications, DesktopCouch but I'm planning a stock Gnome version also so that people on Fedora, Suse and other rocking distribution can use it too.

<!-- more -->

## Features

*   Multiple Accounts
*   Google Apps support
*   Secure password storage using Gnome-Keyring
*   Themable unread emails page
*   Preferences sync using U1

Right now, my target is to make it stable/usable enough in time for Maverick. I'm planning to release the first stable version and getting it into Universe for Maverick. In fact, I've already submitted it to [REVU](http://revu.ubuntuwire.com/p/gmailwatcher) (MOTU Advocate, Anyone?).

## Request

I intent to spend the next few days polishing the app. This post is essentially a call for user feedback. I would like to know what you don't like about the way GmailWatcher works. Bugs, usability issues, appearance, anything that doesn't count as a new feature.

## Themes

You can also contribute some themes for the email summaries view. A GmailWatcher theme is a simple HTML page styled with CSS. It's pretty basic right now. Once Maverick is released, I'll add JavaScript and local media support. Take a look at [lp:gmailwatcher-themes-extra](http://launchpad.net/gmailwatcher-themes-extra) in case you would like to add a theme or two.

## Install
```
    sudo add-apt-repository ppa:loneowais/ppa
    sudo apt-get update
    sudo apt-get install gmailwatcher
```

![](http://feeds.feedburner.com/~r/Owaislone/~4/oeVHz0sfCKg)
