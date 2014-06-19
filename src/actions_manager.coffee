define [
  'settings'
  'reporter'
  'promise'
  'helpers/url_helper'
], (Settings, Reporter, Promise, URLHelper)->
  class ActionsManager
    constructor: () ->
      @reporter = new Reporter()
      @parsed_settings = {}
      @callbacks = []
      @actions = []
      @shop_code = null
      @actions_queue = Settings.actions_queue
      @redirect_data = null

      @_parseActions()

    redirect: (analytics_session) ->
      return unless @redirect_data
      data = {}
      data[Settings.params.analytics_session] = analytics_session
      url = URLHelper.appendData @redirect_data.url, URLHelper.serialize(data)
      setTimeout (->
        Settings.redirectTo url
      ), @redirect_data.time
      @

    sendTo: (url) ->
      payload = @_prepareData(@actions)

      @reporter.report(url, payload).then =>
        callback() for callback in @callbacks

    getSettings: -> @parsed_settings

    _prepareData: (data)->
      result = []
      params = Settings.params

      ## TODO REFACTOR
      if Settings.single_beacon
        payload = {}
        payload[params.url] = Settings.url.current
        payload[params.shop_code] = @shop_code if @shop_code
        payload[params.actions] = data
        result.push payload
      else
        for action in data
          payload = {}
          payload[params.url] = Settings.url.current
          payload[params.shop_code] = @shop_code if @shop_code
          payload[params.actions] = [action]
          result.push payload

      return result

    _parseActions: ->
      api = Settings.api
      while item = @actions_queue.pop()
        switch item[1]
          when api.settings.yogurt_session
            @parsed_settings.yogurt_session = item[2]
          when api.settings.set_account
            @shop_code = item[2]
          when api.settings.set_callback
            @callbacks.push item[2]
          when api.settings.redirect_to
            @redirect_data =
              url: item[2]
              time: parseInt(item[3],10) or 0
          else
            action = {
              category: item[0]
              type: item[1]
              data: item[2]
            }
            action.sig = item[3] if item[0] is api.ecommerce.key and item[3]

            @actions.push action

      @actions.push {category: api.site.key, type: api.site.send_pageview} unless @actions.length

      return

  return ActionsManager
