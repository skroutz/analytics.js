define ['settings', 'promise'], (Settings, Promise)->
  class Utils
    @_setUpCallbacks: (base_obj, promise)->
      base_obj.step1_complete = -> Utils._createScript(Settings.url.utils.third_party_step2())
      base_obj.step2_complete = (status)-> promise.resolve(status)

    @_cleanUpCallbacks: (base_obj)->
      delete base_obj.step1_complete
      delete base_obj.step2_complete

    @_createScript: (url)->
      element = document.createElement('script')
      element.src = url

      sibling = document.getElementsByTagName('script')[0]
      sibling.parentNode.insertBefore(element, sibling)

    @_firstPartyCookiesEnabled: ->
      document.cookie = "TemporaryTestCookie=yes;";
      cookies_enabled = document.cookie.indexOf("TemporaryTestCookie=") isnt -1
      document.cookie = "TemporaryTestCookie=; expires=Thu, 01 Jan 1970 00:00:00 GMT";
      return cookies_enabled

    @_thirdPartyCookiesEnabled: ->
      promise = new Promise()

      Utils._setUpCallbacks Settings.actions_queue, promise
      Utils._createScript Settings.url.utils.third_party_step1()

      promise.then -> Utils._cleanUpCallbacks Settings.actions_queue

    @checkCookies: ->
      promise = new Promise()

      Utils._thirdPartyCookiesEnabled().then (third_enabled)->
        promise.resolve
          first: Utils._firstPartyCookiesEnabled()
          third: third_enabled

      promise

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

  return Utils
