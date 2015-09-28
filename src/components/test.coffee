_ = require 'lodash'
React = require 'react'

{DOM} = React

module.exports = React.createFactory React.createClass
  getInitialState: ->
    latestMessages: []

  componentDidMount: ->
    @room = @props.post?.slug ? "idk"
    @socket = @props.getSocket 'public-blog-component-test',
      postId: @room

    @socket.on 'data', @onData
    @socket.on 'reconnect', @reconnecting
    @socket.on 'reconnected', @join
    @join()

    latestMessages = null
    try
      latestMessages = JSON.parse localStorage.getItem "room-#{@props.post?.slug}"
    catch ex
      'nothing'

    if latestMessages?.length > 0
      @setState
        latestMessages: latestMessages

  componentWillUnmount: ->
    @socket.off 'data', @onData
    @socket.off 'reconnect', @reconnecting
    @socket.off 'reconnected', @join

  join: ->
    @socket.write
      action: 'join'
      room: @room

  reconnecting: (opts = {}) ->
    msg = 'Reconnecting '
    if opts.schedules
      msg += "in #{opts.scheduled} ms "
    msg += "(attempt #{opts.attempt} out of #{opts.retries})"
    @onData
      room: @room
      msg: msg
      t: Date.now()

  onData: (data) ->
    console.log 'received some data', data
    return unless @isMounted()
    return unless data.room == @room

    latestMessages = [data].concat(@state.latestMessages).slice(0, 10)

    try
      localStorage.setItem "room-#{@props.post?.slug}", JSON.stringify latestMessages
    catch ex
      'nothing'
    @setState
      latestMessages: latestMessages

  sendMessage: (e) ->
    e.preventDefault()
    el = React.findDOMNode @refs.msg
    msg = el?.value
    console.log 'send', msg
    if el and msg
      @socket.write
        room: @room
        msg: msg
      el.value = ''

  render: ->
    DOM.div null,
      DOM.form
        onSubmit: @sendMessage
      ,
        DOM.input
          ref: 'msg'
          placeholder: 'send a message'
          style:
            color: '#222'
            width: '100%'
      if @state.latestMessages
        _.map @state.latestMessages, (data) ->
          msg = if data.id or data.msg
            data.msg
          else
            JSON.stringify data
          DOM.div
            key: "#{data.t}-#{data.id ? msg}"
          ,
            if data.id
              DOM.span null,
                DOM.strong null, "#{data.id}:"
                ' '
                DOM.span null, msg
            else
              DOM.em
                style:
                  color: '#555'
              , msg
