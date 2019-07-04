define ['promise'], (Promise)->
  class BrowserHelper
    ###
     * IE:
     *  Versions < IE8 do not support inline images.
     *  So we have to listen to the onerror event on them.
     *  IE >= 8 support inline images, so we listen to the onload event.
     * All other:
     * Watching the .complete attr is sufficient
     * The .readyState check depends on the src attribute been set before the appending of the img element
    ###
    @checkImages: ->
      promise     = new Promise()
      img_enabled = false

      parent = document.getElementsByTagName('head')[0]
      src  = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'

      img = document.createElement('img')
      img.onload = img.onerror = -> img_enabled = true
      img.src = src

      parent.appendChild img

      setTimeout (->
        promise.resolve(img.complete or img_enabled)
        parent.removeChild img
      ), 0

      promise


  return BrowserHelper
