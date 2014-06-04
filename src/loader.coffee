((url)->
  # Section 1
  iframe = document.createElement('iframe')
  iframe.src = "javascript:false"
  iframe.title = ""
  # iframe.role = "presentation" # a11y

  (iframe.frameElement or iframe).style.cssText = "width: 0; height: 0; border: 0"
  where = document.getElementsByTagName('script')
  where = where[where.length - 1]
  where.parentNode.insertBefore(iframe, where)

# Section 2
  try
    doc = iframe.contentWindow.document
  catch err
    dom = document.domain
    iframe.src = "javascript:var d=document.open();d.domain='#{dom}';void(0);"
    doc = iframe.contentWindow.document

  doc.open()._l = ->
    js = this.createElement("script")

    this.domain = dom if(dom)
    js.id = "js-iframe-async"
    js.src = "@@base_url/#{url}"
    this.body.appendChild(js)

  doc.write('<body onload="document._l();">')
  doc.close()
)('@@payload_hash')

