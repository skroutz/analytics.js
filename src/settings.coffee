define ->
  Settings =
    actions_queue : (window._saq or window._saq = [])
    url:
      base: 'http://analytics.skroutz.dev:9000'
      current: window.location.href
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

  return Settings
