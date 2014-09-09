define [
  'settings'
  'actions_manager'
  'session'
], (Settings, ActionsManager, Session)->

  ###
    Analytics Class

    Analytics is the core class that initiates the tracking process. When a
    session is established, it proceeds with reporting all collected and parsed
    Analytics Actions.

    @example Initialize an Analytics object
      window.sa.analytics = new Analytics()
  ###
  class Analytics

    ###
      Constructs a new Analytics object

      Collect all actions, establish a session and then report all beacons.
    ###
    constructor: ->
      @actions = new ActionsManager()
      @session = new Session(@actions.getSettings())

      @session.then @onSession, @onNoSession

    ###
      Invoked when an Analytics Session can not be established
    ###
    onNoSession: ->

    ###
      Reports the Analytics Actions as soon as an Analytics Session is
      established.

      @param [String] analytics_session The extracted Analytics Session ID
    ###
    onSession: (analytics_session) =>
      beacon_url = Settings.url.beacon(analytics_session)

      @actions.sendTo(beacon_url).then =>
        @actions.redirect(analytics_session)

  return Analytics
