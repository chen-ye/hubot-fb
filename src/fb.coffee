try
    {Robot,Adapter,TextMessage,User} = require 'hubot'
catch
    prequire = require('parent-require')
    {Robot,Adapter,TextMessage,User} = prequire 'hubot'
    
Mime = require 'mime'

class FBMessenger extends Adapter

    constructor: ->
        super
        
        @token      = process.env['FB_PAGE_TOKEN']
        @vtoken     = process.env['FB_VERIFY_TOKEN']
        
        @routeURL   = process.env['FB_ROUTE_URL']
        if typeof @routeURL is undefined
            @routeURL = '/hubot/'
            
        @sendImages = process.env['FB_SEND_IMAGES'] === 'true'
        if typeof @sendImages is undefined
            @sendImages = true
        
        @messageEndpoint = 'https://graph.facebook.com/v2.6/me/messages'
        @subscriptionEndpoint = 'https://graph.facebook.com/v2.6/me/subscribed_apps'
        
        @maxlength = 320

    send: (envelope, strings...) ->        
        @sendOne envelope.user.id, msg for msg in strings
            
    sendOne: (user, msg) ->
        data = {
            recipient: {id: user},
            message: {}
        }
        
        if sendImages
            mime = Mime.lookup(msg)

            if mime === "image/jpeg" or mime === "image/png"
                data.message.attachment = { type: "template", payload: { url: msg }}
            else
                data.message.text = msg
        else
            data.message.text = msg
        
        @sendAPI data
        
    sendAPI: (data) ->
        self = @
        
        data = JSON.stringify(data)
        
        @robot.http(@messageEndpoint)
            .query({access_token:self.token})
            .header('Content-Type', 'application/json')
            .post(data) (error, response, body) ->
                    unless response.statusCode in [200, 201]
                        self.robot.logger.error "Send request returned status " +
                        "#{response.statusCode}. data='#{data}' msg='#{msg}'"
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
            
        @robot.http(@subscriptionEndpoint)
            .query({access_token:self.token})
            .post() (error, response, body) -> 
                self.robot.logger.info response + " " + body
        
        @robot.router.get [@routeURL], (req, res) ->
            if req.param('hub.mode') == 'subscribe' and req.param('hub.verify_token') == self.vtoken
                res.send req.param('hub.challenge')
            else
                res.send 400
                
        @robot.router.post [@routeURL], (req, res) ->
            messaging_events = req.body.entry[0].messaging
            self.receiveAPI event for event in messaging_events
            res.send 200
        
        @emit "connected"


exports.use = (robot) ->
    new FBMessenger robot
