define [
  'settings'
  'actions_manager'
  'session'
], (Settings, ActionsManager, Session)->
  class Analytics
    constructor: ->
      @session = new Session()
      @actions = new ActionsManager()

      @session.then (analytics_session) =>
        console.log "%canalytics_session: #{analytics_session}", 'color: green'

        beacon_url = Settings.url.beacon(analytics_session)
        @actions.sendTo(beacon_url).then ->
          console.log "%cAll actions reported!!", 'color: green'

  return Analytics
