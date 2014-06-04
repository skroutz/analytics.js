define ->
  Settings =
    window: (global or this)
    redirectTo: (url)-> Settings.window.location.replace(url)
    actions_queue_name: '_saq'
    get_param_name: 'analytics_session'
    cookies:
      first_party_enabled: true
      version: 1
      yogurt:
        name: 'yogurt_session'
      analytics:
        name: 'analytics_session'
        duration: 60 * 60 * 24 * 7 #In seconds: one week
    url:
      base: 'http://analytics.local:9000'
      analytics_session:
        create: (yogurt_session)->
          "#{Settings.url.base}/track/new?yogurt_session=#{yogurt_session}"
        connect: -> "#{Settings.url.base}/track/connect"
      beacon: (analytics_session)->
        "#{Settings.url.base}/track/beacons/new?analytics_session=#{analytics_session}"
      utils:
        third_party_step1: -> "#{Settings.url.base}/track/check/third_party/step_1.js"
        third_party_step2: -> "#{Settings.url.base}/track/check/third_party/step_2.js"
    api:
      shop_code_key: '_setAccount'
      redirect_key: 'redirect'

  Settings.actions_queue = (Settings.window._saq or Settings.window._saq = [])
  Settings.url.current   = Settings.window.location.href

  return Settings
