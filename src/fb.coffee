try
    {Robot,Adapter,TextMessage,User} = require 'hubot'
catch
    prequire = require('parent-require')
    {Robot,Adapter,TextMessage,User} = prequire 'hubot'

Mime = require 'mime'
crypto = require 'crypto'
inspect = require('util').inspect


class FBMessenger extends Adapter

    constructor: ->
        super

        @page_id    = process.env['FB_PAGE_ID']
        @app_id     = process.env['FB_APP_ID']
        @app_secret = process.env['FB_APP_SECRET']

        @token      = process.env['FB_PAGE_TOKEN']
        @vtoken     = process.env['FB_VERIFY_TOKEN'] or crypto.randomBytes(16).toString('hex')

        @routeURL   = process.env['FB_ROUTE_URL'] or '/hubot/fb'
        @webhookURL = process.env['FB_WEBHOOK_BASE'] + @routeURL

        _sendImages = process.env['FB_SEND_IMAGES']
        if _sendImages is undefined
            @sendImages = true
        else
            @sendImages = _sendImages is 'true'

        @autoHear = process.env['FB_AUTOHEAR'] is 'true'

        @apiURL = 'https://graph.facebook.com/v2.6'
        @pageURL = @apiURL + '/'+ @page_id
        @messageEndpoint = @pageURL + '/messages?access_token=' + @token
        @subscriptionEndpoint = @pageURL + '/subscribed_apps?access_token=' + @token
        @appAccessTokenEndpoint = 'https://graph.facebook.com/oauth/access_token?client_id=' + @app_id + '&client_secret=' + @app_secret + '&grant_type=client_credentials'
        @setWebhookEndpoint = @pageURL + '/subscriptions'

        @msg_maxlength = 320

        @_dataQueue = []

    send: (envelope, strings...) ->
        @_sendText envelope.user.id, msg for msg in strings
        if envelope.fb?.richMsg?
            @_sendRich envelope.user.id, envelope.fb.richMsg

    _sendText: (user, msg) ->
        data = {
            recipient: {id: user},
            message: {}
        }

        if @sendImages
            mime = Mime.lookup(msg)

            if mime is "image/jpeg" or mime is "image/png" or mime is "image/gif"
                data.message.attachment = { type: "image", payload: { url: msg }}
            else
                data.message.text = msg.substring(0,@msg_maxlength)
        else
            data.message.text = msg

        @_sendAPI data

    _sendRich: (user, richMsg) ->
        data = {
            recipient: {id: user},
            message: richMsg
        }
        @_sendAPI data

    _sendAPI: (data) ->
      @_dataQueue.push data
      if @_dataQueue.length == 1
          # Nothing else is queued up, so initiate the API request
          @_sendData()

    _sendData: () ->
        self = @
        data = @_dataQueue[0]
        return unless data

        @robot.http(@messageEndpoint)
            .query({access_token:self.token})
            .header('Content-Type', 'application/json')
            .post(JSON.stringify(data)) (error, response, body) ->
                self._dataQueue.shift()
                # If there are other items in the queue, send them
                if self._dataQueue.length > 0
                  self._sendData()
                if error
                    self.robot.logger.error 'Error sending message: #{error}'
                    return
                unless response.statusCode in [200, 201]
                    self.robot.logger.error "Send request returned status " +
                    "#{response.statusCode}. data='#{data}'"
                    self.robot.logger.error body
                    return

    reply: (envelope, strings...) ->
        @send envelope, strings...

    _receiveAPI: (event) ->
        self = @

        user = @robot.brain.data.users[event.sender.id]
        unless user?
            self.robot.logger.debug "User doesn't exist, creating"
            @_getUser event.sender.id, event.recipient.id, (user) ->
                self._dispatch event, user
        else
            self.robot.logger.debug "User exists"
            self._dispatch event, user

    _dispatch: (event, user) ->
        envelope = {
            event: event,
            user: user,
            room: event.recipient.id
        }

        if event.message?
            @_processMessage event, envelope
        else if event.postback?
            @_processPostback event, envelope
        else if event.delivery?
            @_processDelivery event, envelope
        else if event.optin?
            @_processOptin event, envelope

    _processMessage: (event, envelope) ->
        @robot.logger.debug inspect event.message
        if event.message.attachments?
            envelope.attachments = event.message.attachments
            @robot.emit "fb_richMsg", envelope
            @_processAttachment event, envelope, attachment for attachment in envelope.attachments
        if event.message.text?
            text = if @autoHear then @_autoHear event.message.text, envelope.room else event.message.text
            msg = new TextMessage envelope.user, text, event.message.mid
            @receive msg
            @robot.logger.info "Reply message to room/message: " + envelope.user.name + "/" + event.message.mid

    _autoHear: (text, chat_id) ->
        # If it is a private chat, automatically prepend the bot name if it does not exist already.
        if (chat_id > 0)
            # Strip out the stuff we don't need.
            text = text.replace(new RegExp('^@?' + @robot.name.toLowerCase(), 'gi'), '');
            text = text.replace(new RegExp('^@?' + @robot.alias.toLowerCase(), 'gi'), '') if @robot.alias
            text = @robot.name + ' ' + text

        return text

    _processAttachment: (event, envelope, attachment) ->
        unique_envelope = {
            event: event,
            user: envelope.user,
            room: envelope.room,
            attachment: attachment
        }
        @robot.emit "fb_richMsg_#{attachment.type}", unique_envelope

    _processPostback: (event, envelope) ->
        envelope.payload = event.postback.payload
        @robot.emit "fb_postback", envelope

    _processDelivery: (event, envelope) ->
        @robot.emit "fb_delivery", envelope

    _processOptin: (event, envelope) ->
        envelope.ref = event.optin.ref
        @robot.emit "fb_optin", envelope
        @robot.emit "fb_authentication", envelope

    _getUser: (userId, page, callback) ->
        self = @

        @robot.http(@apiURL + '/' + userId)
            .query({fields:"first_name,last_name,profile_pic",access_token:self.token})
            .get() (error, response, body) ->
                if error
                    self.robot.logger.error 'Error getting user profile: #{error}'
                    return
                unless response.statusCode is 200
                    self.robot.logger.error "Get user profile request returned status " +
                    "#{response.statusCode}. data='#{body}'"
                    self.robot.logger.error body
                    return
                userData = JSON.parse body

                userData.name = userData.first_name
                userData.room = page

                user = new User userId, userData
                self.robot.brain.data.users[userId] = user

                callback user


    run: ->
        self = @

        unless @token
            @emit 'error', new Error 'The environment variable "FB_PAGE_TOKEN" is required. See https://github.com/chen-ye/hubot-fb/blob/master/README.md for details.'

        unless @page_id
            @emit 'error', new Error 'The environment variable "FB_PAGE_ID" is required. See https://github.com/chen-ye/hubot-fb/blob/master/README.md for details.'

        unless @app_id
            @emit 'error', new Error 'The environment variable "FB_APP_ID" is required. See https://github.com/chen-ye/hubot-fb/blob/master/README.md for details.'

        unless @app_secret
            @emit 'error', new Error 'The environment variable "FB_APP_SECRET" is required. See https://github.com/chen-ye/hubot-fb/blob/master/README.md for details.'

        unless process.env['FB_WEBHOOK_BASE']
            @emit 'error', new Error 'The environment variable "FB_WEBHOOK_BASE" is required. See https://github.com/chen-ye/hubot-fb/blob/master/README.md for details.'

        @robot.http(@subscriptionEndpoint)
            .query({access_token:self.token})
            .post() (error, response, body) ->
                self.robot.logger.info "subscribed app to page: " + body

        @robot.router.get [@routeURL], (req, res) ->
            if req.param('hub.mode') == 'subscribe' and req.param('hub.verify_token') == self.vtoken
                res.send req.param('hub.challenge')
                self.robot.logger.info "successful webhook verification"
            else
                res.send 400

        @robot.router.post [@routeURL], (req, res) ->
            self.robot.logger.debug "Received payload: " + JSON.stringify(req.body)
            messaging_events = req.body.entry[0].messaging
            self._receiveAPI event for event in messaging_events
            res.send 200

        @robot.http(@appAccessTokenEndpoint)
            .get() (error, response, body) ->
                self.app_access_token = body.split("=").pop()
                self.robot.http(self.setWebhookEndpoint)
                .query(
                    object: 'page',
                    callback_url: self.webhookURL
                    fields: 'messaging_optins, messages, message_deliveries, messaging_postbacks'
                    verify_token: self.vtoken
                    access_token: self.app_access_token
                    )
                .post() (error2, response2, body2) ->
                    self.robot.logger.info "FB webhook set/updated: " + body2

        @robot.logger.info "FB-adapter initialized"
        @emit "connected"


exports.use = (robot) ->
    new FBMessenger robot
