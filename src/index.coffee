# below are examples integrating this component with:
# A.) a gateway to interact with a post via SMS
# B.) a location autoresponder

module.exports = (System) ->

  # A.) part of the sms example
  # socket = null
  # expectingResponseBy = 0
  # respondToRoom = null

  getID = ->
    me = System.getMe()
    displayNames = []
    if me?.data
      for platform, profile of me.data
        displayNames.push profile.nickname ? profile.fullName
    displayName = null
    for n in displayNames
      displayName = n if n and (!displayName? or n?.length > displayName.length)
    displayName

  # A.) part of the sms example
  # receiveSms = (obj) ->
  #   if respondToRoom and expectingResponseBy > Date.now()
  #     socket.primus
  #       .room respondToRoom
  #       .write
  #         room: respondToRoom
  #         msg: obj.message
  #         id: getID()
  #         t: Date.now()
  #     expectingResponseBy = 0
  #     respondToRoom = null
  #   obj

  # A.) part of the sms example
  # events:
  #   sms:
  #     receive:
  #       pre: receiveSms
  #     send:
  #       pre: (obj) ->
  #         expectingResponseBy = 0
  #         respondToRoom = null
  #         obj

  init: (next) ->
    socket = System.getSocket 'public-blog-component-test'
    counter = 0
    socket.on 'connection', (spark) ->
      spark._count = counter++
      spark.on 'data', (data) ->
        return unless data?.room

        # # A.)
        # # an example of sending an SMS when someone is talking to the author
        # # not filtered, limited, or otherwise intelligent
        # # just neat.
        # if data.msg and !spark.request.isUser
        #   obj =
        #     notify: true
        #     message: data.msg
        #   System.do 'sms.send', obj
        #   .then ->
        #     expectingResponseBy = Date.now() + 1000 * 60 * 10
        #     respondToRoom = data.room

        # # B.)
        # # an example of sending my last known location (city name)
        # # sends as a response to every message, which is silly
        # System.do 'me.location.last', {}
        # .then (item) ->
        #   return unless item?.city
        #   # console.log 'got this', item
        #   spark.write
        #     room: data.room
        #     msg: item.city
        #     t: Date.now()

    next()
