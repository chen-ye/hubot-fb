# hubot-fb
[![npm version](https://badge.fury.io/js/hubot-fb.svg)](https://badge.fury.io/js/hubot-fb)

A (quick and dirty) [Hubot](https://hubot.github.com) adapter for the [Facebook Messenger Platform](https://messengerplatform.fb.com/).

Supported features:
- Token validation and botside autosetup
- Resolving user profiles (name and profile pictures from ids)
- Send and receive messages
- Image attachments

## Installation
- For setting up a Hubot instance, [see here](https://hubot.github.com/docs/)
- Install hubot-fb into your Hubot instance using by running ```npm install -save hubot-fb``` in your Hubot's root.  
- Set hubot-fb as your adapter by launching with ```bin/hubot -a fb```. (Edit your Procfile to do the same on Heroku.)
- [Configure](#configuration) hubot-fb.
- See [Facebook's quickstart](https://developers.facebook.com/docs/messenger-platform/quickstart) for setup instructions on Facebook's side.


## Configuration
Required variables are in **bold**.

| config variable           | type    | default   | description                                                                                                                                                                                                                               |
|---------------------------|---------|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **```FB_PAGE_TOKEN```**   | string  | -         | Your [page access token](https://developers.facebook.com/docs/facebook-login/access-tokens#pagetokens). You can get one at ```https://developers.facebook.com/apps/[YOUR APP ID]/messenger/```.                                           |
| **```FB_VERIFY_TOKEN```** | string  | -         | Your [verification token](https://developers.facebook.com/docs/graph-api/webhooks#setup). This is the string your app expects when you modify a webhook subscription at ```https://developers.facebook.com/apps/YOUR APP ID/webhooks/```. |
| ```FB_ROUTE_URL```        | string  | "/hubot/" | The webhook url hubot-fb monitors for new message events.                                                                                                                                                                                         |
| ```FB_SEND_IMAGES```      | boolean | true      | Whether or not hubot-fb should automatically convert compatible urls into image attachments                                                                                                                                               |

## Sending Rich Messages (Templates, Images)
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

For example,
``` 
envelope = 
{
    fb: {
        richMsg: {
            attachment: {
                "type": "image",
                "payload": {
                    "url":"https://petersapparel.com/img/shirt.png"
                }
            }
        }
        
    },
    user[...]
}
```

or

``` 
envelope = 
{
    fb: {
        richMsg: {
            attachment: {
                type: "template",
                payload: {
                    template_type: "button",
                    text: "What do you want to do next?",
                    buttons: [
                        {
                            type: "web_url",
                            url: "https://petersapparel.parseapp.com",
                            title: "Show Website"
                        },
                        {
                            type: "postback",
                            title: "Start Chatting",
                            payload: [USER_DEFINED_PAYLOAD]
                        }
                    ]
                }
            }
        }

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

## Warnings
This adapter will truncate messages longer than 320 characters (the maximum allowed by Facebook's API).  For alternate behavor, use a script like [hubot-chunkify](https://github.com/chen-ye/hubot-chunkify) or [hubot-longtext](https://github.com/ClaudeBot/hubot-longtext)
