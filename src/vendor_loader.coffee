((window, document, url)->
  js = document.createElement('script')
  js.id = 'js-vendor-asset'
  js.src = "@@base/#{url}"
  js.onload = -> window.initSocket()
  js.onreadystatechange = ->
    if js.readyState is 'loaded' or js.readyState is 'complete'
      window.initSocket()
  document.head.appendChild(js)
)(window, document, '@@vendor_hash')
