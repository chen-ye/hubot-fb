# hubot-fb
[![npm version](https://badge.fury.io/js/hubot-fb.svg)](https://badge.fury.io/js/hubot-fb)

A (quick and dirty) [Hubot](https://hubot.github.com) adapter for the [Facebook Messenger Platform](https://messengerplatform.fb.com/).

## Installation
- For setting up a Hubot instance, [see here](https://hubot.github.com/docs/)
- Install hubot-fb into your Hubot instance using by running ```npm install -save hubot-fb``` in your Hubot's root.  
- Set hubot-fb as your adapter by launching with ```bin/hubot -a fb```. Edit your Procfile to do the same on Heroku.
- Configure hubot-fb (see below).
- See [Facebook's quickstart](https://developers.facebook.com/docs/messenger-platform/quickstart) for setup instructions on Facebook's side.


## Configuration
| config variable           | type    | default   | description                                                                                                                                                            |
|---------------------------|---------|-----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **```FB_PAGE_TOKEN```**   | string  | -         | Your [page access token](https://developers.facebook.com/docs/facebook-login/access-tokens#pagetokens). You can get one at ```https://developers.facebook.com/apps/[YOUR APP ID]/messenger/```.                                                                |
| **```FB_VERIFY_TOKEN```** | string  | -         | Your [verification token](https://developers.facebook.com/docs/graph-api/webhooks#setup). This is the string your app expects when you modify a webhook subscription. |
| ```FB_ROUTE_URL```        | string  | "/hubot/" | The url hubot-fb monitors for new message events.                                                                                                                      |
| ```FB_SEND_IMAGES```      | boolean | true      | Whether or not hubot-fb should automatically convert compatible urls into image attachments                                                                            |

## Warnings
The API doesn't currently support messages longer than 320 characters. This adapter will chunk messages longer than this in the future, but for now, I suggest using something like [hubot-longtext](https://github.com/ClaudeBot/hubot-longtext).
