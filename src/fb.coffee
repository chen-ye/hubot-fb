try
    {Robot,Adapter,TextMessage,User} = require 'hubot'
catch
    prequire = require('parent-require')
    {Robot,Adapter,TextMessage,User} = prequire 'hubot'

class FBMessenger extends Adapter

    constructor: ->
        super
        @robot.logger.info "Constructor"
        @token      = process.env['FB_PAGE_TOKEN']
        @vtoken      = process.env['VERIFY_TOKEN']
        @maxlength = 320

    send: (envelope, strings...) ->
        @robot.logger.info "Send"
        message = strings.join "\n"
        @sendAPI envelope.user.id, msg for msg in strings
        
    sendAPI: (user, msg) ->
        self = @
        
        data = JSON.stringify({
            recipient: {id: user},
            message: {text: msg}
        })
        
        @robot.logger.info data
        
        @robot.http('https://graph.facebook.com/v2.6/me/messages')
            .query({access_token:self.token})
            .header('Content-Type', 'application/json')
            .post(data) (error, response, body) ->
                    unless response.statusCode in [200, 201]
                        self.robot.logger.error "Send request returned status " +
                        "#{response.statusCode}. user='#{user}' msg='#{msg}'"
                        
                        self.robot.logger.error body
                    if error
                        self.robot.logger.error 'Error sending message: ', error
                    else if (response.body.error)
                        self.robot.logger.error 'Error: ', response.body.error
                        
    reply: (envelope, strings...) ->
        @robot.logger.info "Reply"
        @send envelope, strings
        
    receiveAPI: (event) ->
        if event.message
            @receive new TextMessage @robot.brain.userForId(event.sender.id), event.message.text 
    
    run: ->
        self = @
        
        unless @token
            @emit 'error', new Error 'The environment variable "FB_PAGE_TOKEN" is required.'
            
        unless @vtoken
            @emit 'error', new Error 'The environment variable "VERIFY_TOKEN" is required.'
            
        @robot.http("https://graph.facebook.com/v2.6/me/subscribed_apps")
            .query({access_token:self.token})
            .post() (error, response, body) -> 
                self.robot.logger.info response + " " + body
        
        @robot.router.get ['/hubot/'], (req, res) ->
            if req.param('hub.mode') == 'subscribe' and req.param('hub.verify_token') == self.vtoken
                res.send req.param('hub.challenge')
            else
                res.send 400
                
        @robot.router.post ['/hubot/'], (req, res) ->
            messaging_events = req.body.entry[0].messaging
            self.receiveAPI event for event in messaging_events
            res.send 200
        
        @robot.logger.info "Run"
        @emit "connected"


exports.use = (robot) ->
    new FBMessenger robot
