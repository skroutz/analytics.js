define [
  'settings'
  'actions_manager'
  'session'
], (Settings, ActionsManager, Session)->
  class Analytics
    constructor: ->
      @session = new Session()
      @actions = new ActionsManager()

      @session.then @onSession, @onNoSession

    onNoSession: ->

    onSession: (analytics_session) =>
      beacon_url = Settings.url.beacon(analytics_session)

      @actions.sendTo(beacon_url).then =>
        @actions.redirect(analytics_session)

  return Analytics
