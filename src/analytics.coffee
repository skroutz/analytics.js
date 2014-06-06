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

    onNoSession: () =>
      console.log 'no session returned'

    onSession: (analytics_session) =>
      console.log "%canalytics_session: #{analytics_session}", 'color: green'
      beacon_url = Settings.url.beacon(analytics_session)
      console.log analytics_session
      @actions.sendTo(beacon_url).then =>
        console.log 'Beacons sent: ', (+new Date() - window.top.performance.timing.navigationStart) / 1000
        @actions.redirect(analytics_session)

  return Analytics
