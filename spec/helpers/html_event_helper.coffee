click_element =  (el) ->
  ev = document.createEvent('MouseEvent')
  ev.initMouseEvent('click', true, true, window, null, 0, 0, 0, 0, false, false,
    false, false, 0, null)

  el.dispatchEvent(ev)

trigger_keyboard_event = (key_code, el = document) ->
  eventObj = if document.createEventObject then document.createEventObject() else document.createEvent('Events')
  eventObj.initEvent 'keyup', true, true if eventObj.initEvent

  eventObj.keyCode = key_code
  eventObj.which = key_code

  if el.dispatchEvent then el.dispatchEvent(eventObj) else el.fireEvent('onkeyup', eventObj)
