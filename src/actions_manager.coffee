define [
  'settings'
  'reporter'
  'promise'
  'helpers/url_helper'
], (Settings, Reporter, Promise, URLHelper)->
  class ActionsManager
    constructor: () ->
      @reporter = new Reporter()
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
      payload = {}
      payload[Settings.params.url] = Settings.url.current
      payload[Settings.params.shop_code] = @shop_code if @shop_code
      payload[Settings.params.actions] = @actions

      @reporter.report(url, payload).then =>
        callback() for callback in @callbacks

    _parseActions: ->
      api = Settings.api
      while item = @actions_queue.pop()
        switch item[1]
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
            action.sig = item[3] if item[0] is api.ecommerce.key

            @actions.push action

      @actions.push {category: api.site.key, type: api.site.send_pageview} unless @actions.length

      return

  return ActionsManager
