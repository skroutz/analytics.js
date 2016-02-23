click_element =  (el) ->
  ev = document.createEvent('MouseEvent')
  ev.initMouseEvent('click', true, true, window, null, 0, 0, 0, 0, false, false,
    false, false, 0, null)

  el.dispatchEvent(ev)
