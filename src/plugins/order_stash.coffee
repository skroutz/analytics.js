###
Plugin which prompts the user to save his/her order
###
class OrderStash
  CTA_READMORE_TEXT = 'Αποθήκευση της παραγγελίας'

  settings = window.sa_plugins.settings
  context = -> window.sa_plugins.order_stash

  asset_url = (source) -> "#{settings.url.base}/assets/#{source}"
  stash_endpoint = (order_code) ->
    "#{settings.url.application_base}/account/analytics/orders/#{order_code}/save"

  STYLE = (configuration) -> """
  @keyframes sa-order-stash-slide-in-right {
    0%   { right: -250px; }
    100% { right: 35px; }
  }

  @keyframes sa-order-stash-slide-out-right {
    0%   { right: 35px; }
    100% { right: -250px; }
  }

  @keyframes sa-order-stash-slide-in-left {
    0%   { left: -250px; }
    100% { left: 35px; }
  }

  @keyframes sa-order-stash-slide-out-left {
    0%   { left: 35px; }
    100% { left: -250px; }
  }

  #sa-order-stash-plugin * {
    all: unset;
    padding: 0;
    overflow: hidden;
    width: initial;
    height: initial;
  }

  #sa-order-stash-plugin {
    all: unset;
    display: block;

    position: fixed;
    background-color: white;
    bottom: 35px;
    padding: 0 0 10px 0;
    width: 250px;
    height: 220px;
    text-align: center;
    font-family: Verdana, Arial, sans-serif;
    box-shadow: 0px 1px 11px 0px rgba(77,77,77,0.33);

    #{switch configuration.position
      when 'bottom-left' then 'left: 35px;'
      when 'bottom-right' then 'right: 35px;'}

    border: 1px solid #eee;
    border-radius: 2px 2px 0 0;
    z-index: 2147483647;

    animation: sa-order-stash-slide-in-#{configuration.position.split('-')[1]} 1s;
  }

  #sa-order-stash-plugin.sa-order-stash-slide-out {
    animation: sa-order-stash-slide-out-#{configuration.position.split('-')[1]} .5s;
    animation-fill-mode: forwards;
  }

  #sa-order-stash-plugin #sa-order-stash-header {
    display: block;

    padding: 35px;

    background-image: url('#{asset_url("logo.png")}');
    background-position: center;
    background-position-y: 20px;
    background-position-x: 66px;
    background-repeat: no-repeat;
    background-size: 120px 33px;
  }

  #sa-order-stash-plugin #sa-order-stash-header.sa-order-stash-no-logo {
    background: none;
    padding: 10px;
  }

  #sa-order-stash-plugin #sa-order-stash-dismiss {
    display: block;
    position: absolute;
    top: 9px;
    right: 10px;

    width: 15px;
    height: 15px;

    background: url('#{asset_url("btn_close.png")}');
    background-position: center;
    background-repeat: no-repeat;

    cursor: pointer;
  }

  #sa-order-stash-plugin #sa-order-stash-prompt {
    display: inline-block;
    margin: 0;
    padding: 0 20px;
    color: #333;
    font-size: 13px;
    font-family: Verdana, Arial, sans-serif;
  }

  #sa-order-stash-plugin #sa-order-stash-privacy {
    font-style: italic;
  }

  #sa-order-stash-plugin #sa-order-stash-button {
    display: inline-block;
    width: 185px;
    height: 36px;
    line-height: 16px;
    background-color: #f68b24 !important;
    color: white;
    font-family: Verdana, Arial, sans-serif;
    font-weight: bold;
    font-size: 14px;

    margin-top: 18px;
    padding: 10px 15px;

    text-align: center;
    cursor: pointer;
    border-radius: 2px;

    text-decoration: none;
    overflow-x: hidden;
    background: url('#{asset_url("arrow.png")}');
    background-size: 10px;
    background-repeat: no-repeat;
    background-position: 200px 16px;

    box-sizing: border-box;

    transition: none;
    transition: background-color .2s, background-position .2s, padding-right .2s ease-in-out;
  }

  #sa-order-stash-plugin #sa-order-stash-button.sa-order-stash-read-less:hover {
    background-color: #d8721c !important;
    background-position-x: 152px;
    padding-right: 30px;
  }

  #sa-order-stash-plugin #sa-order-stash-button.sa-order-stash-read-more {
   width: 220px;
   margin-bottom: 8px;

   font-weight: normal;
   font-size: 12px;
   background-position: 220px 17px;

   transition: none;
   transition: background-color .2s,
               background-position .2s,
               padding-right .2s ease-in-out;
  }

  #sa-order-stash-plugin #sa-order-stash-button.sa-order-stash-read-more:hover {
    padding-right: 28px;
    background-color: #d8721c !important;
    background-position: 200px 17px;
  }

  #sa-order-stash-plugin #sa-order-stash-why {
    display: inline-block;
    margin-top: 17px;
    color: #909090;

    font-size: 12px;
    font-style: italic;
    line-height: 13px;
    box-sizing: border-box;

    transition: none;
    text-decoration: none;

    cursor: pointer;
  }

  #sa-order-stash-plugin #sa-order-stash-why:hover {
    color: #666;
    border-bottom: 1px dashed #909090;
  }

  #sa-order-stash-plugin #sa-order-stash-rationale {
    display: none;
    padding: 0 15px;
    text-align: left;
  }

  #sa-order-stash-plugin #sa-order-stash-rationale p:first-child {
    font-size: 14px;
  }

  #sa-order-stash-plugin #sa-order-stash-rationale p {
    display: inline-block;
    margin: 13px 0 6px 0;
    line-height: 17px;
    color: #333;
    font-family: Verdana, Arial, sans-serif;
    font-size: 13px;
  }

  #sa-order-stash-plugin #sa-order-stash-rationale p.sa-order-stash-privacy {
    font-size: 11px;
    color: #909090;
    margin-bottom: 0;
  }

  @media only screen and (-webkit-min-device-pixel-ratio: 2),
         only screen and (min--moz-device-pixel-ratio: 2),
         only screen and (  -o-min-device-pixel-ratio: 2/1),
         only screen and (     min-device-pixel-ratio: 2),
         only screen and (     min-resolution: 192dpi),
         only screen and (     min-resolution: 2dppx) {

    #sa-order-stash-plugin #sa-order-stash-header {
      background-image: url('#{asset_url("logo@2x.png")}');
    }

    #sa-order-stash-plugin #sa-order-stash-dismiss {
      background-image: url('#{asset_url("btn_close@2x.png")}');
    }

    #sa-order-stash-plugin #sa-order-stash-button {
      background-image: url('#{asset_url("arrow@2x.png")}');
    }
  }
  """

  TEMPLATE = (assigns) -> """
  <div id="sa-order-stash-header">
    <span id="sa-order-stash-dismiss"></span>
  </div>

  <div id="sa-order-stash-content">
    <p id="sa-order-stash-prompt">
      Αποθήκευση της παραγγελίας σου στο Skroutz;
    </p>

    <div id="sa-order-stash-rationale">
      <p>
        Γιατί να αποθηκεύσω την παραγγελία μου στο Skroutz;
      </p>

      <p>
        Ώστε να μπορείς να ανατρέξεις σε πληροφορίες σχετικά με τις αγορές που έκανες,
        μέσα στο λογαριασμό σου στο Skroutz.
      </p>

      <p class="sa-order-stash-privacy">
        Τα δεδομένα αυτά είναι προσωπικά και παραμένουν ασφαλή στο Skroutz.
      </p>
    </div>
  </div>
  <a id="sa-order-stash-button" class="sa-order-stash-read-less" href="#{assigns.endpoint}">Αποθήκευση</a>
  <a id="sa-order-stash-why" href="javascript:void(0)">Γιατί να την αποθηκεύσω;</a>
  """

  constructor: ->
    order_id = context().order_id
    return if !order_id? || order_id in ['', 'null']

    @addStyle()
    @render()
    @_bindHandlers()

  ###
  Displays the plugin
  ###
  render: ->
    @$el = document.createElement('div')
    @$el.id = 'sa-order-stash-plugin'
    @$el.innerHTML = TEMPLATE(endpoint: @_endpoint())
    @_document().body.appendChild(@$el)

  $header: -> @_document().getElementById('sa-order-stash-header')
  $dismissButton: -> @_document().getElementById('sa-order-stash-dismiss')
  $stashButton: -> @_document().getElementById('sa-order-stash-button')
  $whyButton: -> @_document().getElementById('sa-order-stash-why')
  $prompt: -> @_document().getElementById('sa-order-stash-prompt')
  $rationale: -> @_document().getElementById('sa-order-stash-rationale')

  ###
  Adds the required css for the plugin
  ###
  addStyle: ->
    style = window.document.createElement('style')
    style.id = 'sa-order-stash-style'
    style.type = 'text/css'

    # IE compatibility
    if style.styleSheet
      style.styleSheet.cssText = STYLE(context().configuration)
    else
      style.appendChild(document.createTextNode(STYLE(context().configuration)))

    @_head().appendChild(style)

  _bindHandlers: ->
    @_attachEvent(@$dismissButton(), 'click', @_onClickDismiss)
    @_attachEvent(@$whyButton(), 'click', @_onClickWhy)
    @_attachEvent(@$stashButton(), 'click', @_onClickStash)

  _attachEvent: (element, event, handler) ->
    return element.addEventListener event, handler, false  if element.addEventListener
    element.attachEvent "on#{event}", handler              if element.attachEvent

  _onClickDismiss: =>
    return @$el.className = 'sa-order-stash-slide-out' if @_transitionSupport()

    @$el.parentNode.removeChild(@$el)

  _onClickWhy: =>
    @$prompt().style.display = 'none'
    @$whyButton().style.display = 'none'
    @$header().className = "sa-order-stash-no-logo"
    @$rationale().style.display = 'block'
    @$el.style.height = 'auto'

    ((button) ->
      # http://caniuse.com/#feat=innertext
      if 'innerText' in button
        button.innerText = CTA_READMORE_TEXT
      else
        button.textContent = CTA_READMORE_TEXT
      button.className = 'sa-order-stash-read-more')(@$stashButton())

  _onClickStash: (e) =>
    return unless @_transitionSupport()

    e.preventDefault()

    @$stashButton().removeEventListener('click', @_onClickStash, false)
    @_attachEvent(@$el, 'transitionend', => @$stashButton().click())
    @$el.className = 'sa-order-stash-slide-out'

  _head: -> @_document().head || @_document().getElementsByTagName('head')[0]
  _document: -> window.parent.document
  _transitionSupport: -> @$el.style.transition?

  _endpoint: ->
    params =
      shop_code: context().shop_code
      analytics_session: context().analytics_session

    serialized_params = ("#{k}=#{v}" for k, v of params).join('&')

    "#{stash_endpoint(encodeURIComponent(context().order_id))}?#{serialized_params}"

new OrderStash
