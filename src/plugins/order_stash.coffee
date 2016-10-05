###
Plugin which prompts the user to save his/her order
###
class OrderStash
  CTA_READMORE_TEXT = '@@translations.order_stash.cta_readmore_text'
  DOMREADY_TIMEOUT = 2000 # 2 seconds

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
    background-color: white !important;
    bottom: 35px;
    padding: 0 0 10px 0;
    width: 250px;
    height: 220px;
    text-align: center;
    font-family: Verdana, Arial, sans-serif !important;
    box-shadow: 0px 1px 11px 0px rgba(77,77,77,0.33);

    #{switch configuration.position
      when 'bottom-left' then 'left: 35px;'
      when 'bottom-right' then 'right: 35px;'}

    border: 1px solid #eee;
    border-radius: 2px 2px 0 0;
    z-index: 2147483647;

    animation: sa-order-stash-slide-in-#{configuration.position.split('-')[1]} 1s;
  }

  #sa-order-stash-plugin a:hover, #sa-order-stash-plugin p:hover {
    text-shadow: none !important;
  }

  #sa-order-stash-plugin.sa-order-stash-slide-out {
    animation: sa-order-stash-slide-out-#{configuration.position.split('-')[1]} .5s;
    animation-fill-mode: forwards;
  }

  #sa-order-stash-plugin #sa-order-stash-header {
    display: block;

    padding: 35px;

    background-image: url('#{asset_url("logo_@@flavor.png")}');
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
    color: #333 !important;
    font-size: 13px !important;
    font-family: Verdana, Arial, sans-serif !important;
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
    color: white !important;
    font-family: Verdana, Arial, sans-serif !important;
    font-weight: bold;
    font-size: 14px !important;

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

  #sa-order-stash-plugin #sa-order-stash-button:hover {
    color: white !important;
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
   font-size: 12px !important;
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
    color: #909090 !important;

    font-size: 12px !important;
    font-style: italic;
    line-height: 13px;
    box-sizing: border-box;

    transition: none;
    text-decoration: none;

    cursor: pointer;
  }

  #sa-order-stash-plugin #sa-order-stash-why:hover {
    color: #666 !important;
    border-bottom: 1px dashed #909090;
  }

  #sa-order-stash-plugin #sa-order-stash-rationale {
    display: none;
    padding: 0 15px;
    text-align: left;
  }

  #sa-order-stash-plugin #sa-order-stash-rationale p:first-child {
    font-size: 14px !important;
  }

  #sa-order-stash-plugin #sa-order-stash-rationale p {
    display: inline-block;
    margin: 13px 0 6px 0;
    line-height: 17px;
    color: #333 !important;
    font-family: Verdana, Arial, sans-serif !important;
    font-size: 13px !important;
  }

  #sa-order-stash-plugin #sa-order-stash-rationale p.sa-order-stash-privacy {
    font-size: 11px !important;
    color: #909090 !important;
    margin-bottom: 0;
  }

  @media only screen and (-webkit-min-device-pixel-ratio: 2),
         only screen and (min--moz-device-pixel-ratio: 2),
         only screen and (  -o-min-device-pixel-ratio: 2/1),
         only screen and (     min-device-pixel-ratio: 2),
         only screen and (     min-resolution: 192dpi),
         only screen and (     min-resolution: 2dppx) {

    #sa-order-stash-plugin #sa-order-stash-header {
      background-image: url('#{asset_url("logo_@@flavor@2x.png")}');
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
      @@translations.order_stash.prompt
    </p>

    <div id="sa-order-stash-rationale">
      <p>
        @@translations.order_stash.rationale
      </p>

      <p>
        @@translations.order_stash.rationale_why
      </p>

      <p class="sa-order-stash-privacy">
        @@translations.order_stash.privacy
      </p>
    </div>
  </div>
  <a id="sa-order-stash-button" class="sa-order-stash-read-less" href="#{assigns.endpoint}">
    @@translations.order_stash.save
  </a>
  <a id="sa-order-stash-why" href="javascript:void(0)">@@translations.order_stash.save_why</a>
  """

  constructor: ->
    order_id = context().order_id
    return if !order_id? || order_id in ['', 'null']

    @_setParentDoc()

    @addStyle()
    @onDOMReady => @initialize()

  initialize: ->
    @render()
    @_bindHandlers()

  ###
  Detect DOM ready
  ###
  onDOMReady: (cb) ->
    # IE is only safe when readyState is 'complete'
    return cb() if @parent_doc.readyState == 'complete'
    return cb() if !@parent_doc.attachEvent && @parent_doc.readyState in ['interactive', 'complete']

    if @parent_doc.addEventListener # Mozilla, Opera, Webkit
      @parent_doc.addEventListener 'DOMContentLoaded', cb, false
    else if @parent_doc.attachEvent # IE
      @parent_doc.attachEvent('onreadystatechange', (=> cb() if @parent_doc.readyState == 'complete'))
    else
      setTimeout((=> try cb() catch), DOMREADY_TIMEOUT)

  ###
  Displays the plugin
  ###
  render: ->
    @$el = document.createElement('div')
    @$el.id = 'sa-order-stash-plugin'
    @$el.innerHTML = TEMPLATE(endpoint: @_endpoint())
    @parent_doc.body.appendChild(@$el)

  $header: -> @parent_doc.getElementById('sa-order-stash-header')
  $dismissButton: -> @parent_doc.getElementById('sa-order-stash-dismiss')
  $stashButton: -> @parent_doc.getElementById('sa-order-stash-button')
  $whyButton: -> @parent_doc.getElementById('sa-order-stash-why')
  $prompt: -> @parent_doc.getElementById('sa-order-stash-prompt')
  $rationale: -> @parent_doc.getElementById('sa-order-stash-rationale')

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

  _head: -> @parent_doc.head || @parent_doc.getElementsByTagName('head')[0]
  _transitionSupport: -> @$el.style.transition?

  _setParentDoc: -> @parent_doc = window.parent.document

  _endpoint: ->
    params =
      shop_code: context().shop_code
      analytics_session: context().analytics_session

    serialized_params = ("#{k}=#{v}" for k, v of params).join('&')

    "#{stash_endpoint(encodeURIComponent(context().order_id))}?#{serialized_params}"

new OrderStash
