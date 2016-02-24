define [
  'settings'
  'reporter'
  'runnable'
  'helpers/url_helper'
], (Settings, Reporter, Runnable, URLHelper) ->
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
        productClick: (data, redirect_url, redirect = true) ->
          clearTimeout @pageview_timeout
          @_reportAction 'yogurt', 'productClick', data, (analytics_session) =>
            @_redirect(redirect_url, analytics_session) if redirect_url and redirect
      ecommerce:
        addOrder: (data, callback) ->
          clearTimeout @pageview_timeout
          @_reportAction 'ecommerce', 'addOrder', data, -> callback() if callback
          @plugins_manager.notify('order', data)
        addItem: (data, callback) ->
          clearTimeout @pageview_timeout
          @_reportAction 'ecommerce', 'addItem', data, -> callback() if callback
      site:
        sendPageView: ->
          @_reportAction 'site', 'sendPageView'

    _reportAction: (category, type, data, cb) ->
        url = Settings.url.beacon(@session.analytics_session)
        payload = @_buildBeaconPayload(category, type, data)

        ## TODO: THROW ERROR ON REJECT
        @reporter.sendBeacon(url, payload).then => cb and cb(@session.analytics_session)

    _redirect: (url, _analytics_session) ->
      # TODO: Find a way to safely append analytics session as query param
      # for GetParamEngine to work, see: 9dd1d57a
      Settings.redirectTo url

    # TODO: implement multiple actions per beacon maybe??
    _buildBeaconPayload: (category, type, data = '{}') ->
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
