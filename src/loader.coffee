###
Analytics Payload Loader

This is the `analytics.js` file that loads the actual Analytics payload. It
utilizes the Friendly iFrames (FiF) technique in order to load the JavaScript
library without blocking the `window.onload` event.

@see http://goo.gl/VLDc3F More information on FiF technique
@see https://developer.akamai.com/blog/2012/12/12/non-blocking-script-loader-pattern
###
((url)->
  try
    # Avoid executing multiple Skroutz Analytics scripts, which leads to
    # load Payload multiple times.
    window["@@flavorAnalyticsLoader"] ||= { count: 0 }
    window["@@flavorAnalyticsLoader"].count += 1

    if window["@@flavorAnalyticsLoader"].count > 1
      return console.warn("@@flavorAnalytics loaded #{window["@@flavorAnalyticsLoader"].count} times")

  # Section 1
  iframe = document.createElement('iframe')
  iframe.src = "javascript:false"
  iframe.title = ""
  iframe.name = "frame-#{new Date().getTime()}" # https://stackoverflow.com/a/26191196/4375736
  # iframe.role = "presentation" # a11y

  (iframe.frameElement or iframe).style.cssText =
    "position: absolute; top: 0; left: 0; width: 1px; height: 1px; opacity: 0; border: none;"

  if document.body
    document.body.appendChild(iframe)
  else
    where = document.getElementsByTagName('script')
    where = where[where.length - 1]
    where.parentNode.insertBefore(iframe, where)

  # Section 2
  try
    doc = iframe.contentWindow.document
  catch err
    # In IE < 11 there is an issue if the main page sets document.domain, even
    # if document.domain is set to itself (document.domain=document.domain).
    # Solution: https://developer.akamai.com/blog/2012/12/12/non-blocking-script-loader-pattern
    dom = document.domain
    iframe.src = "javascript:var d=document.open();d.domain='#{dom}';void(0);"
    doc = iframe.contentWindow.document

  doc.open()._l = ->
    js = this.createElement("script")

    this.domain = dom if(dom)
    js.id = "js-iframe-async"
    js.src = "@@analytics_base_url/#{url}"
    this.body.appendChild(js)

  doc.write('<body onload="window.inDapIF=true; document._l();">')
  doc.close()
)('@@payload_hash')

