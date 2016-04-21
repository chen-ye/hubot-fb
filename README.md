# hubot-fb
[![npm version](https://badge.fury.io/js/hubot-fb.svg)](https://badge.fury.io/js/hubot-fb)

A [Hubot](https://hubot.github.com) adapter for the [Facebook Messenger Platform](https://messengerplatform.fb.com/). This adapter fully supports everything the v2.6 Messenger platform API is capable of:
- Token validation and botside autosetup
- Resolving user profiles (name and profile pictures from ids)
- Send and receive text messages
- Send templates and images (jpgs; pngs; animated gifs)
- Receive images, location, and other attachments
- Template postbacks

## Installation
- For setting up a Hubot instance, [see here](https://hubot.github.com/docs/)
- Install hubot-fb into your Hubot instance using by running ```npm install -save hubot-fb``` in your Hubot's root.  
- [Configure](#configuration) hubot-fb.
- Set hubot-fb as your adapter by launching with ```bin/hubot -a fb```. (Edit your Procfile to do the same on Heroku.)
- See [Facebook's quickstart](https://developers.facebook.com/docs/messenger-platform/quickstart) for setup instructions on Facebook's side.

## Warnings
This adapter will truncate messages longer than 320 characters (the maximum allowed by Facebook's API).  For alternate behavor, use a script like [hubot-chunkify](https://github.com/chen-ye/hubot-chunkify) or [hubot-longtext](https://github.com/ClaudeBot/hubot-longtext)

## Configuration
Required variables are in **bold**.

| config variable           | type    | default   | description                                                                                                                                                                                                                               |
|---------------------------|---------|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **```FB_PAGE_TOKEN```**   | string  | -         | Your [page access token](https://developers.facebook.com/docs/facebook-login/access-tokens#pagetokens). You can get one at ```https://developers.facebook.com/apps/[YOUR APP ID]/messenger/```.                                           |
| **```FB_VERIFY_TOKEN```** | string  | -         | Your [verification token](https://developers.facebook.com/docs/graph-api/webhooks#setup). This is the string your app expects when you modify a webhook subscription at ```https://developers.facebook.com/apps/YOUR APP ID/webhooks/```. |
| ```FB_ROUTE_URL```        | string  | "/hubot/" | The webhook url hubot-fb monitors for new message events.                                                                                                                                                                                         |
| ```FB_SEND_IMAGES```      | boolean | true      | Whether or not hubot-fb should automatically convert compatible urls into image attachments                                                                                                                                               |

## Use
### Sending Rich Messages (Templates, Images)
_Note: If you just want to send images, you can also send a standard image url in your message text with ```FB_SEND_IMAGES``` set to `true`._
To send rich messages, include in your envelope 
``` 
envelope = 
{
    fb: {
        richMsg: [RICH_MESSAGE]
    },
    user[...]
}
```

In a response, this would look something like:

```
robot.hear /getting chilly/i, (res) ->
    res.envelope.fb = {
      richMsg: {
        attachment: {
          type: "template",
          payload: {
            template_type: "button",
            text: "Do you wanna build a snowman?",
            buttons: [
              {
                type: "web_url",
                url: "http://www.dailymotion.com/video/x1fa7w8_frozen-do-you-wanna-build-the-snowman-1080p-official-hd-music-video_music",
                title: "Yes"
              },
              {
                type: "web_url",
                title: "No",
                url: "http://wallpaper.ultradownloads.com.br/275633_Papel-de-Parede-Meme-Okay-Face_1600x1200.jpg"
              }
            ]
          }
        }
      }
    }
    res.send()
```


See Facebook's API reference [here](https://developers.facebook.com/docs/messenger-platform/send-api-reference#guidelines) for further examples of rich messages.

### Events
Events allow you react to input that Hubot doesn't natively support. This adapter emits `fb_postback`, `fb_delivery`, `fb_richMsg`, and `fb_richMsg_[ATTACHMENT_TYPE]` events. 

Register a listener using `robot.on [EVENT_NAME] [CALLBACK]`.

| event name                     | callback object                                                                            | description                                                                                                                                                                |
|--------------------------------|--------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `fb_postback`                  | ``` { event: msgevent, user: hubot.user, room: string,   payload: string } ``` | Emitted when a postback is triggered.                                                                                                                                      |
| `fb_delivery`                  | ```{ event: msgevent, user: hubot.user, room: string }```                               | Emitted when a delivery confirmation is sent.                                                                                                                              |
| `fb_richMsg`                   | ```{ event: msgevent, user: hubot.user, room: string, attachments: array[msgevent.message.attachment]}```          | Emitted when a message with an attachment is sent. Contains all attachments within that message.                                                                           |
| `fb_richMsg_[ATTACHMENT.TYPE]` | ```{ event: msgevent, user: hubot.user, room: string, attachment: msgevent.message.attachment}```          | Emitted when a message with an attachment is sent. Contains a single attachment of type [ATTACHMENT.TYPE], and multiple are emitted in messages with multiple attachments. |

#### `fb_postback` example

Responding to an event is a bit more manual—here's an example.  

```
# You need this to manually compose a Response
{Response} = require 'hubot'

module.exports = (robot) ->

  # This can exist alongside your other hooks
  robot.on "fb_postback", (envelope) -> 
    res = new Response robot, envelope, undefined
    if envelope.payload is "send_ok_face"
      res.send "http://wallpaper.ultradownloads.com.br/275633_Papel-de-Parede-Meme-Okay-Face_1600x1200.jpg"
```

Of course, postbacks can do anything in your application—not just trigger responses.  

