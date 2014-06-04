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
      promises =
        (for action in @actions
          action.url = Settings.url.current
          action.shop_code_val = @shop_code_val if @shop_code_val

          @reporter.report(url, action)
        )

      Promise.all(promises).then => callback() for callback in @callbacks

    _parseActions: ->
      api = Settings.api
      while item = @actions_queue.pop()
        switch item[1]
          when api.settings.set_account
            @shop_code_val = item[2]
          when api.settings.set_callback
            @callbacks.push item[2]
          when api.settings.redirect_to
            @redirect_data =
              url: item[2]
              time: parseInt(item[3],10) or 0
          when Settings.api.ecommerce.add_transaction, Settings.api.ecommerce.add_item
            @actions.push category: item[0], type: item[1], data: item[2], sig: item[3]
          else
            @actions.push category: item[0], type: item[1], data: item[2]

      @actions.push {category: api.site.key, type: api.site.send_pageview} unless @actions.length
      return

  return ActionsManager
