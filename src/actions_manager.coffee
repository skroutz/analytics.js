define [
  'settings'
  'reporter'
  'promise'
  'session'
  'helpers/url_helper'
], (Settings, Reporter, Promise, Session, URLHelper)->

  class ActionsManager
    constructor: ->
      @reporter = new Reporter()
      @promise = new Promise()

      @session = null

      @run.apply(@, item) while item = Settings.window.sa.q.shift()
      Settings.window.sa = @run

    run: (category, type, args...)=>
      try
        method = @_actions[category][type]
        method.apply @, args
      catch
        ## TODO Create custom error class
        throw new Error('Invalid API call')

    _actions:
      session:
        create: (shop_code, yogurt_session, yogurt_user_id)-> @_sessionAction 'create',
          shop_code: shop_code
          yogurt_session: yogurt_session
          yogurt_user_id: yogurt_user_id
        connect: (shop_code)-> @_sessionAction 'connect',{shop_code: shop_code}
      yogurt:
        productClick: (data, redirect_url, redirect = true)->
          @_reportAction 'yogurt', 'productClick', data, (analytics_session)=>
            @_redirect(redirect_url, analytics_session) if redirect_url and redirect
      ecommerce:
        addOrder: (data, callback)->
          @_reportAction 'ecommerce', 'addOrder', data, -> callback() if callback
        addItem: (data, callback)->
          @_reportAction 'ecommerce', 'addItem', data, -> callback() if callback
      site:
        sendPageView: ->
          @_reportAction 'site', 'sendPageView'

    _sessionAction: (type, args)->
      ## TODO Create custom error class
      throw new Error('Session already initiated') if @session

      @session = new Session(type, args)
      @session.then @promise.resolve, @promise.reject

    _reportAction: (category, type, data, cb)->
      @promise.then (analytics_session)=>
        url = Settings.url.beacon(analytics_session)
        payload = @_buildBeaconPayload(category, type, data)

        ## TODO: THROW ERROR ON REJECT
        @reporter.sendBeacon(url, payload).then => cb and cb(analytics_session)

    _redirect: (url, analytics_session) ->
      data = {}
      data[Settings.params.analytics_session] = analytics_session
      Settings.redirectTo URLHelper.appendData(url, URLHelper.serialize(data))

    # TODO: implement multiple actions per beacon maybe??
    _buildBeaconPayload: (category, type, data = '{}')->
      payload = {}
      params = Settings.params
      payload[params.url] = Settings.url.current
      payload[params.shop_code] = @session.shop_code
      payload[params.actions] = [{
        category: category
        type: type
        data: data
      }]

      payload

  return ActionsManager
