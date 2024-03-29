define [
  'settings'
  'reporter'
  'runnable'
  'biskoto'
  'validator'
  'analytics_url'
], (Settings, Reporter, Runnable, Biskoto, Validator, AnalyticsUrl) ->
  class ActionsManager
    ActionsManager::[key] = method for key, method of Runnable

    constructor: (@session, @plugins_manager) ->
      @reporter = new Reporter()
      @pageview_timeout = null
      @reported_line_items = 0

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
            data = new Validator(data, 'addItem').present('order_id', 'product_id').data
          catch e
            if e.name == 'ValidationError'
              return console?.error? "#{Settings.flavor}Analytics | #{e.message}"
            else
              throw e

          data.rpos = @reported_line_items++ # line item reported position
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
      payload[params.url] = Settings.url.current
      payload[params.referrer] = Settings.url.referrer
      payload[params.shop_code] = @session.shop_code
      payload[params.metadata] = @_buildMetadata(JSON.parse(data))
      payload[params.cookie_policy] = @session.cookie_policy
      payload[params.cookie_type] = @_determineCookieType()
      payload[params.actions] = [{
        category: category
        type: type
        data: data
      }]

      payload

    _buildMetadata: (data) ->
      # When using 3rd-party cookies, metadata will be undefined
      # In this case, the server will fallback to using the meta cookie
      return '' unless @session.metadata

      sbm = data.sbm
      sbm_tag = data.sbm_tag

      # Return metadata as is if sbm is not present
      return @session.metadata unless sbm || sbm_tag

      # Clone
      meta = JSON.parse(JSON.stringify(@session.metadata))

      tags = if meta.tags then meta.tags.split(',') else []
      if sbm || sbm_tag
        tags.push('sbm') if sbm && !('sbm' in tags)
        tags.push(sbm_tag) if sbm_tag && !(sbm_tag in tags)

      meta.tags = tags.join() if tags

      meta

    _determineCookieType: ->
      if Biskoto.get(Settings.cookies.basic.session.name) then '1' else '3'

  return ActionsManager
