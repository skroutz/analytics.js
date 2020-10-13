define [
  'settings'
  'reporter'
  'runnable'
  'validator'
  'analytics_url'
], (Settings, Reporter, Runnable, Validator, AnalyticsUrl) ->
  class ActionsManager
    ActionsManager::[key] = method for key, method of Runnable

    constructor: (@session, @plugins_manager) ->
      @reporter = new Reporter()
      @pageview_timeout = null

      @_setPageViewTimeout() if Settings.send_auto_pageview

    _setPageViewTimeout: ->
      @pageview_timeout = setTimeout (=> @_commands.site.sendPageView.call(@)),
                                     Settings.auto_pageview_timeout

    _commands:
      yogurt:
        productClick: (data, redirect_callback, redirect_url, url_mode = { type: 'default' }) ->
          clearTimeout @pageview_timeout
          @_reportAction 'yogurt', 'productClick', data, () =>
            if redirect_callback and redirect_url
              redirect_url = new AnalyticsUrl(redirect_url).format_params(url_mode, @session.analytics_session, @session.metadata)

              try redirect_callback(redirect_url) catch then Settings.redirectTo(redirect_url)

      ecommerce:
        addOrder: (data, callback) ->
          clearTimeout @pageview_timeout

          try
            new Validator(data, 'addOrder').present('order_id')
          catch e
            if e.name == 'ValidationError'
              return console?.error? "#{Settings.flavor}Analytics | #{e.message}"
            else
              throw e

          @_reportAction 'ecommerce', 'addOrder', data, -> callback() if callback

          # Do not display OrderStash widget for users that haven't opted in for full experience
          @plugins_manager.notify('order', data) if @session.cookie_policy == 'full'

        addItem: (data, callback) ->
          clearTimeout @pageview_timeout

          try
            new Validator(data, 'addItem').present('order_id', 'product_id')
          catch e
            if e.name == 'ValidationError'
              return console?.error? "#{Settings.flavor}Analytics | #{e.message}"
            else
              throw e

          @_reportAction 'ecommerce', 'addItem', data, -> callback() if callback

      site:
        sendPageView: ->
          @_reportAction 'site', 'sendPageView'

    _reportAction: (category, type, data, cb) ->
        url = Settings.url.beacon(@session.analytics_session)
        payload = @_buildBeaconPayload(category, type, data)

        ## TODO: HANDLE ERROR ON REJECT
        @reporter.sendBeacon(url, payload).then => cb and cb()

    # TODO: implement multiple actions per beacon maybe??
    _buildBeaconPayload: (category, type, data = '{}') ->
      data = JSON.stringify data if typeof data != 'string'
      payload = {}
      params = Settings.params
      payload[params.transaction_id] = @session.transaction_id
      payload[params.url] = Settings.url.current
      payload[params.referrer] = Settings.url.referrer
      payload[params.shop_code] = @session.shop_code
      payload[params.metadata] = @session.metadata || ''
      payload[params.cookie_policy] = @session.cookie_policy
      payload[params.actions] = [{
        category: category
        type: type
        data: data
      }]

      payload

  return ActionsManager
