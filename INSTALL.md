# hubot-fb Installation Instructions
### Setup Hubot
- For setting up a Hubot instance, [see here](https://hubot.github.com/docs/)

### Setup Facebook Page + App
- Create a Facebook Page [here](https://www.facebook.com/pages/create/)
- Create a Facebook App [here](https://developers.facebook.com/quickstarts/?platform=web). 
    - After you create an app ID and enter you email, press 
      ![Skip Quick Start](https://cloud.githubusercontent.com/assets/1904031/14837112/f635ca32-0c15-11e6-8fb2-3bd2185a3cd7.png)
    - Go to your app dashboard and click "Messenger" on the sidebar.  It should look something like this:
      
      ![image](https://cloud.githubusercontent.com/assets/1904031/14604183/71017e6e-0572-11e6-888e-1cea71ca34e0.png)
      
    - Under "Token Generation", select a page, and copy the page access token that is generated:
      
      ![image](https://cloud.githubusercontent.com/assets/1904031/14604243/da3d106e-0572-11e6-822e-ac15322bf94b.png)

### Setup hubot-fb
- Install hubot-fb into your Hubot instance using by running `npm install -save hubot-fb` in your Hubot's root.
- Set your `FB_PAGE_TOKEN` environment variable as the page access token you copied. This will allow your bot to send as your page.
- __ADVICE__: You can skip all the steps below; they are now done automatically by this module if you provide the needed config variables. We keep below as reference.
- __IMPORTANT__: In your console, run 
`curl -ik -X POST "https://graph.facebook.com/v2.6/me/subscribed_apps?access_token=[FB_PAGE_TOKEN]"`. This tells Facebook to forward page messages to your app
- Pick an alphanumeric string and set it as your `FB_VERIFY_TOKEN`.
- Launch your hubot instance using hubot-fb by running `bin/hubot -a fb` (edit your Procfile to do the same on a Heroku-hosted instance)
- In your app dashboard, under the webhooks section, click setup webhooks:
    ![image](https://cloud.githubusercontent.com/assets/1904031/14604352/68dbc5c2-0573-11e6-9891-cd79b020b642.png).  
- You should see a dialog like this: 
    ![image](https://cloud.githubusercontent.com/assets/1904031/14604367/859b3e68-0573-11e6-8d6e-96e41663786f.png)
- Under "Callback URL", input `[your hubot domain]/hubot/` (eg, `test-bot.herokuapp.com/hubot/`) (you can customize the route by setting `FB_ROUTE_URL`).
- Under "Verify Token", input the token you set for `FB_VERIFY_TOKEN`.
- Check all the boxes under "Subscription Fields" and click "Verify and Save". This creates webhooks which allow your page to receive Page messages. If you update a webhook, allow up to 10 minutes for Facebook to propagate your webhook, then it will start posting to the new webhook url.
- You're now set up to send and receive messages to your hubot instance from Facebook Messenger.

