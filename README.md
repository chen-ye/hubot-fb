# hubot-fb
[![npm version](https://badge.fury.io/js/hubot-fb.svg)](https://badge.fury.io/js/hubot-fb)

A (quick and dirty) [Hubot](https://hubot.github.com) adapter for the [Facebook Messenger Platform](https://messengerplatform.fb.com/).

## Installation
- For setting up a Hubot, [see here](https://hubot.github.com/docs/)
- Install hubot-fb into your Hubot instance using by running ```npm -save install hubot-fb``` in your Hubot's root.  

## Setup
- Set hubot-fb as your adapter by launching with ```bin/hubot -a fb```. Edit your Procfile to do the same on Heroku.  
- See [Facebook's quickstart](https://developers.facebook.com/docs/messenger-platform/quickstart) for setup instructions on Facebook's side.
- You need to set a config/environment variable called ```FB_PAGE_TOKEN``` containing your API token.

## Warnings
The API doesn't currently support messages longer than 320 characters. This adapter will chunk messages longer than this in the future, but for now, I suggest using something like [hubot-longtext](https://github.com/ClaudeBot/hubot-longtext).
