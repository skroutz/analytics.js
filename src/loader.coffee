###
Analytics Payload Loader

This is the `analytics.js` file that loads the actual Analytics payload.
###
((url)->
  try
    # Avoid executing multiple Skroutz Analytics scripts, which leads to
    # load Payload multiple times.
    window["@@flavorAnalyticsLoader"] ||= { count: 0 }
    window["@@flavorAnalyticsLoader"].count += 1

    if window["@@flavorAnalyticsLoader"].count > 1
      return console.warn("@@flavorAnalytics loaded #{window["@@flavorAnalyticsLoader"].count} times")

  # Append the payload to the body of the document.
  js = document.createElement("script")
  js.type = "text/javascript"
  js.async = true
  js.src = "@@analytics_base_url/#{url}"

  if document.body
    document.body.appendChild(js)
  else
    where = document.getElementsByTagName('script')
    where = where[where.length - 1]
    where.parentNode.insertBefore(js, where)
)('@@payload_hash')
