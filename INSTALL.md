# hubot-fb Detailed Installation Instructions
### Setup Hubot and install hubot-fb
- For setting up a Hubot instance, [see here](https://hubot.github.com/docs/)
- Install hubot-fb into your Hubot instance using by running `npm install -save hubot-fb` in your Hubot's root.

### Setup Facebook Page + App, and configure hubot-fb
Now we'll create the Facebook Page your bot will send and receive as, and the Facebook App that will be used to manage it from Facebook's end.
- Create a Facebook Page [here](https://www.facebook.com/pages/create/)
    - Set your `FB_PAGE_ID` from `https://www.facebook.com/<YOUR PAGE USERNAME>/info?tab=page_info`.
- Create a Facebook App [here](https://developers.facebook.com/quickstarts/?platform=web). 
    - After you create an app ID and enter you email, press 
      ![Skip Quick Start](https://cloud.githubusercontent.com/assets/1904031/14837112/f635ca32-0c15-11e6-8fb2-3bd2185a3cd7.png)
    - Go to your app dashboard, and set your `FB_APP_ID` and `FB_APP_SECRET` from there.
    - Click "Messenger" on the App Dashboard sidebar.  It should look something like this:
      
      ![image](https://cloud.githubusercontent.com/assets/1904031/14604183/71017e6e-0572-11e6-888e-1cea71ca34e0.png)
      
    - Under "Token Generation", select a page, and copy the page access token that is generated:
      
      ![image](https://cloud.githubusercontent.com/assets/1904031/14604243/da3d106e-0572-11e6-822e-ac15322bf94b.png)
      
    - Set your `FB_PAGE_TOKEN` environment variable as the page access token you copied. This will allow your bot to send as your page.
    - Pick an alphanumeric string and set it as your `FB_VERIFY_TOKEN`.

### Launch hubot-fb
- Launch your hubot instance using hubot-fb by running `bin/hubot -a fb` (edit your Procfile to do the same on a Heroku-hosted instance)
- You're now set up to send and receive messages to your hubot instance from Facebook Messenger.


