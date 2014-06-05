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
      @shop_code_val = null
      @actions_queue = Settings.actions_queue
      @redirect_data = null

      @_parseActions()

    redirect: (analytics_session) ->
      return unless @redirect_data
      data = {}
      data[Settings.get_param_name] = analytics_session
      url = URLHelper.appendData @redirect_data.url, URLHelper.serialize(data)
      setTimeout (->
        Settings.redirectTo url
      ), @redirect_data.time
      @

    sendTo: (url) ->
      @reporter.report(url, @actions).then =>
        callback() for callback in @callbacks

    _parseActions: ->
      while item = @actions_queue.pop()
        switch item[1]
          when Settings.api.settings.set_account
            @shop_code_val = item[2]
          when Settings.api.settings.set_callback
            @callbacks.push item[2]
          when Settings.api.settings.redirect_to
            @redirect_data =
              url: item[2]
              time: parseInt(item[3],10) or 0
          else
            action = {
              category: item[0]
              type: item[1]
              data: item[2]
              url: Settings.url.current
            }
            action.sig = item[3] if item[0] is Settings.api.ecommerce.key

            @actions.push action

      @actions.push {category: 'site', type: 'sendPageview'} unless @actions.length

      for action in @actions
        action.shop_code_val = @shop_code_val if @shop_code_val

      return

  return ActionsManager
