###
Plugin which shows a partner badge
###
class Badge
  DOMREADY_TIMEOUT = 2000 # 2 seconds

  settings = window.sa_plugins.settings
  context = -> window.sa_plugins.badge

  asset_url = (source) -> "#{settings.url.base}/assets/#{source}"

  STYLE = (configuration) -> """
  @keyframes sa-badge-fade-in {
    from { opacity: 0; }
    to   { opacity: 1; }
  }

  @keyframes sa-badge-spin {
    from { transform:rotate(0deg); }
    to   { transform:rotate(360deg); }
  }

  #sa-badge-floating-plugin {
    all: initial;

    -webkit-user-select: none;
    -ms-user-select: none;
    user-select: none;

    display: block;

    position: fixed;
    bottom: 25px;
    #{switch configuration.position
        when 'bottom-left' then 'left: 25px;'
        when 'bottom-right' then 'right: 25px;'}

    width: 90px;
    height: 90px;

    border-radius: 45px;

    background-image: url('#{asset_url("badge/floating/large/theme/#{configuration.theme}/logo_@@flavor.png")}');
    background-position: center;
    background-repeat: no-repeat;
    background-size: 90px 90px;
    background-color: #{switch configuration.theme
                        when 'black' then '#363636'
                        when 'white' then '#F7F7F7'
                        when 'orange' then '#F68B24'};

    cursor: pointer;

    z-index: 2147483647;

    -webkit-animation: sa-badge-fade-in 0.3s ease-in;
    animation: sa-badge-fade-in 0.3s ease-in;

    box-shadow: 0 0 4px rgba(0,0,0,.14), 0 4px 8px rgba(0,0,0,.28);
  }

  #sa-badge-floating-plugin.sa-badge-no-stars {
    background-position-y: 4px;
  }

  #sa-badge-floating-plugin * {
    all: unset;
  }

  #sa-badge-floating-plugin #sa-badge-floating-stars-container {
    position: absolute;

    bottom: 16px;
    left: 20px;
  }

  #sa-badge-floating-plugin #sa-badge-floating-stars-container .sa-badge-star {
    display: inline-block;
    margin-right: -3px;

    width: 9px;
    height: 8px;

    background-position: center;
    background-repeat: no-repeat;
    background-size: 9px 8px;
  }

  #sa-badge-floating-plugin #sa-badge-floating-stars-container .sa-badge-full-star {
    background-image: url('#{asset_url("badge/floating/large/theme/#{configuration.theme}/star_full.png")}');
  }

  #sa-badge-floating-plugin #sa-badge-floating-stars-container .sa-badge-half-star {
    background-image: url('#{asset_url("badge/floating/large/theme/#{configuration.theme}/star_half.png")}');
  }

  #sa-badge-floating-plugin #sa-badge-floating-stars-container .sa-badge-empty-star {
    background-image: url('#{asset_url("badge/floating/large/theme/#{configuration.theme}/star_empty.png")}');
  }

  #sa-badge-embedded-plugin {
    all: initial;

    -webkit-user-select: none;
    -ms-user-select: none;
    user-select: none;

    cursor: pointer;

    display: #{if configuration.display is 'embedded' then 'block' else 'none !important'};

    position: relative;
    clear: both;

    width: 150px;
    height: 65px;
    box-sizing: border-box;

    padding: 10px;
    background-color: #{switch configuration.theme
                        when 'white' then '#ffffff'
                        when 'black' then '#363636'};

    border-radius: 2px;
    border: 1px solid #{switch configuration.theme
                        when 'white' then '#DEDEDE'
                        when 'black' then '#575757'};
  }

  #sa-badge-embedded-plugin * {
    all: unset;
  }

  #sa-badge-embedded-plugin #sa-badge-embedded-logo {
    display: block;

    width: 124px;
    height: 24px;
    margin: 0 auto;

    background-image: url('#{asset_url("badge/embedded/theme/#{configuration.theme}/logo_@@flavor.png")}');
    background-position: center;
    background-repeat: no-repeat;
    background-size: 124px 24px;
  }

  #sa-badge-embedded-plugin.sa-badge-no-stars #sa-badge-embedded-logo {
    margin-top: 7px;
  }

  #sa-badge-embedded-plugin #sa-badge-embedded-rating-container {
    display: block;

    width: 124px;
    margin: 0 auto;
    text-align: center;

    padding-top: 2px;
  }

  #sa-badge-embedded-plugin #sa-badge-embedded-rating-container .sa-badge-embedded-rating-number {
    display: inline-block;

    font-family: Verdana, Arial, sans-serif !important;
    font-weight: bold;
    font-size: 14px !important;
    color: #{switch configuration.theme
               when 'white' then '#000000'
               when 'black' then '#ffffff'};
    -webkit-text-fill-color: currentColor;
  }

  #sa-badge-embedded-plugin #sa-badge-embedded-rating-container .sa-badge-embedded-stars-container {
    display: inline-block;
    margin-left: 4px;
  }

  #sa-badge-embedded-plugin #sa-badge-embedded-rating-container .sa-badge-embedded-stars-container .sa-badge-star {
    display: inline-block;
    margin-right: -3px;

    width: 11px;
    height: 10px;

    background-position: center;
    background-repeat: no-repeat;
    background-size: 11px 10px;
  }

  #sa-badge-embedded-plugin #sa-badge-embedded-rating-container .sa-badge-embedded-stars-container .sa-badge-full-star {
    background-image: url('#{asset_url("badge/embedded/theme/#{configuration.theme}/star_full.png")}');
  }

  #sa-badge-embedded-plugin #sa-badge-embedded-rating-container .sa-badge-embedded-stars-container .sa-badge-half-star {
    background-image: url('#{asset_url("badge/embedded/theme/#{configuration.theme}/star_half.png")}');
  }

  #sa-badge-embedded-plugin #sa-badge-embedded-rating-container .sa-badge-embedded-stars-container .sa-badge-empty-star {
    background-image: url('#{asset_url("badge/embedded/theme/#{configuration.theme}/star_empty.png")}');
  }

  #sa-badge-modal {
    position: fixed;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
    z-index: 2147483647;
    padding: 50px 0;
    background: rgba(0, 0, 0, .5);
  }

  #sa-badge-modal #sa-badge-modal-inner {
    position: relative;
    width: 85%;
    height: 100%;
    max-width: 950px;
    margin: 0 auto;
    background-color: #f1f1f1;
  }

  #sa-badge-modal #sa-badge-modal-iframe-container {
    position: relative;
    padding: 0;
    width: 100%;
    height: 100%;
    z-index: 2;
    -webkit-overflow-scrolling: touch;
    overflow: auto;
  }

  #sa-badge-modal #sa-badge-modal-inner.sa-badge-spinner::before {
    content: "";
    width: 48px;
    height: 48px;
    border-radius: 50%;
    border: 4px solid rgba(255, 255, 255, .5);
    border-top-color: rgba(246, 139, 36, .7);
    position: absolute;
    top: 50%;
    left: 50%;
    margin-top: -24px;
    margin-left: -24px;
    animation: sa-badge-spin 1s linear infinite;
    -webkit-animation: sa-badge-spin 1s linear infinite;
    z-index: 1;
  }

  #sa-badge-modal #sa-badge-modal-inner #sa-badge-modal-iframe {
    display: block;

    position: relative;
    z-index: 3;
  }

  #sa-badge-modal #sa-badge-modal-inner #sa-badge-modal-close-button {
    position: absolute;
    top: -32px;
    right: -32px;

    width: 28px;
    height: 27px;

    background: url('#{asset_url("badge/close.png")}');
    background-position: center;
    background-repeat: no-repeat;
    background-size: 28px 27px;

    cursor: pointer;
  }

  @media only screen and (max-width: 768px) {
    #sa-badge-floating-plugin {
      bottom: 8px;
      #{switch configuration.position
          when 'bottom-left' then 'left: 8px;'
          when 'bottom-right' then 'right: 8px;'}

      width: 70px;
      height: 70px;

      border-radius: 35px;

      background-image: url('#{asset_url("badge/floating/small/theme/#{configuration.theme}/hat_logo.png")}');
      background-size: 70px 70px;
    }

    #sa-badge-floating-plugin.sa-badge-no-stars {
      background-position-y: 9px;
    }

    #sa-badge-floating-plugin #sa-badge-floating-stars-container {
      bottom: 15px;
      left: 8px;
    }

    #sa-badge-floating-plugin #sa-badge-floating-stars-container .sa-badge-star {
      margin-right: -3px;

      width: 10px;
      height: 9px;

      background-position: center;
      background-repeat: no-repeat;
      background-size: 10px 9px;
    }

    #sa-badge-floating-plugin #sa-badge-floating-stars-container .sa-badge-full-star {
      background-image: url('#{asset_url("badge/floating/small/theme/#{configuration.theme}/star_full.png")}');
    }

    #sa-badge-floating-plugin #sa-badge-floating-stars-container .sa-badge-half-star {
      background-image: url('#{asset_url("badge/floating/small/theme/#{configuration.theme}/star_half.png")}');
    }

    #sa-badge-floating-plugin #sa-badge-floating-stars-container .sa-badge-empty-star {
      background-image: url('#{asset_url("badge/floating/small/theme/#{configuration.theme}/star_empty.png")}');
    }

    #sa-badge-modal #sa-badge-modal-inner {
      width: 90%;
    }

    #sa-badge-modal #sa-badge-modal-inner #sa-badge-modal-close-button {
      right: 0px;
    }
  }

  @media only screen and (-webkit-min-device-pixel-ratio: 2),
         only screen and (min--moz-device-pixel-ratio: 2),
         only screen and (  -o-min-device-pixel-ratio: 2/1),
         only screen and (     min-device-pixel-ratio: 2),
         only screen and (     min-resolution: 192dpi),
         only screen and (     min-resolution: 2dppx) {
    #sa-badge-floating-plugin {
      background-image: url('#{asset_url("badge/floating/large/theme/#{configuration.theme}/logo_@@flavor@2x.png")}');
    }

    #sa-badge-floating-plugin #sa-badge-floating-stars-container .sa-badge-full-star {
      background-image: url('#{asset_url("badge/floating/large/theme/#{configuration.theme}/star_full@2x.png")}');
    }

    #sa-badge-floating-plugin #sa-badge-floating-stars-container .sa-badge-half-star {
      background-image: url('#{asset_url("badge/floating/large/theme/#{configuration.theme}/star_half@2x.png")}');
    }

    #sa-badge-floating-plugin #sa-badge-floating-stars-container .sa-badge-empty-star {
      background-image: url('#{asset_url("badge/floating/large/theme/#{configuration.theme}/star_empty@2x.png")}');
    }

    #sa-badge-floating-plugin #sa-badge-modal #sa-badge-modal-inner #sa-badge-modal-close-button {
      background-image: url('#{asset_url("badge/close@2x.png")}');
    }

    #sa-badge-embedded-plugin #sa-badge-embedded-logo {
      background-image: url('#{asset_url("badge/embedded/theme/#{configuration.theme}/logo_@@flavor@2x.png")}');
    }

    #sa-badge-embedded-plugin #sa-badge-embedded-rating-container .sa-badge-embedded-stars-container .sa-badge-full-star {
      background-image: url('#{asset_url("badge/embedded/theme/#{configuration.theme}/star_full@2x.png")}');
    }

    #sa-badge-embedded-plugin #sa-badge-embedded-rating-container .sa-badge-embedded-stars-container .sa-badge-half-star {
      background-image: url('#{asset_url("badge/embedded/theme/#{configuration.theme}/star_half@2x.png")}');
    }

    #sa-badge-embedded-plugin #sa-badge-embedded-rating-container .sa-badge-embedded-stars-container .sa-badge-empty-star {
      background-image: url('#{asset_url("badge/embedded/theme/#{configuration.theme}/star_empty@2x.png")}');
    }
  }

  @media only screen and (-webkit-min-device-pixel-ratio: 2) and (max-width: 768px),
         only screen and (min--moz-device-pixel-ratio: 2) and (max-width: 768px),
         only screen and (  -o-min-device-pixel-ratio: 2/1) and (max-width: 768px),
         only screen and (     min-device-pixel-ratio: 2) and (max-width: 768px),
         only screen and (     min-resolution: 192dpi) and (max-width: 768px),
         only screen and (     min-resolution: 2dppx) and (max-width: 768px) {
    #sa-badge-floating-plugin {
      background-image: url('#{asset_url("badge/floating/small/theme/#{configuration.theme}/hat_logo@2x.png")}');
    }

    #sa-badge-floating-plugin #sa-badge-floating-stars-container .sa-badge-full-star {
      background-image: url('#{asset_url("badge/floating/small/theme/#{configuration.theme}/star_full@2x.png")}');
    }

    #sa-badge-floating-plugin #sa-badge-floating-stars-container .sa-badge-half-star {
      background-image: url('#{asset_url("badge/floating/small/theme/#{configuration.theme}/star_half@2x.png")}');
    }

    #sa-badge-floating-plugin #sa-badge-floating-stars-container .sa-badge-empty-star {
      background-image: url('#{asset_url("badge/floating/small/theme/#{configuration.theme}/star_empty@2x.png")}');
    }
  }

  #sa-badge-floating-plugin, #sa-badge-embedded-plugin {
    -webkit-transform: perspective(1px) translateZ(0);
    transform: perspective(1px) translateZ(0);
    -webkit-transition-duration: 0.1s;
    transition-duration: 0.1s;
    -webkit-transition-property: transform;
    transition-property: transform;
  }

  #sa-badge-floating-plugin:hover, #sa-badge-floating-plugin:focus, #sa-badge-floating-plugin:active,
  #sa-badge-embedded-plugin:hover, #sa-badge-embedded-plugin:focus, #sa-badge-embedded-plugin:active {
    -webkit-transform: scale(1.02);
    transform: scale(1.02);
  }
  """

  FLOATING_TEMPLATE = (assigns) -> """
  #{if assigns.stars.length > 0
      "<div id='sa-badge-floating-stars-container'>
        #{(STAR_TEMPLATE(type) for type in assigns.stars).join("\n")}
      </div>"
    else ''}
  """

  EMBEDDED_TEMPLATE = (assigns) -> """
    <div id="sa-badge-embedded-logo"></div>

    #{if assigns.stars.length > 0
        "<div id='sa-badge-embedded-rating-container'>
          <div class='sa-badge-embedded-rating-number'><span>#{assigns.rating}</span></div>
          <div class='sa-badge-embedded-stars-container'>
            #{(STAR_TEMPLATE(type) for type in assigns.stars).join("\n")}
          </div>
        </div>"
      else ''}
  """

  STAR_TEMPLATE = (type) -> """
  <div class="sa-badge-star sa-badge-#{type}-star"></div>
  """

  MODAL_INNER_TEMPLATE = (assigns) -> """
  <div id="sa-badge-modal-inner" class="sa-badge-spinner">
    <span id="sa-badge-modal-close-button"></span>
      <div id="sa-badge-modal-iframe-container">
        <iframe id="sa-badge-modal-iframe" src="#{assigns.src}" width="100%" height="100%" frameborder="0"></iframe>
      </div>
    </div>
  </div>
  """

  constructor: ->
    @_setParentDoc()

    @addStyle()
    @onDOMReady => @initialize()

  initialize: ->
    return unless @_canRender()

    @render()
    @_bindHandlers()

  ###
  Detect DOM ready
  @todo DRY this method as it is being used in order_stash plugin too.
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
    switch context().configuration.display
      when 'floating' then @_renderFloating()
      when 'embedded' then @_renderEmbedded()

  $floatingBadgePlugin: -> @parent_doc.getElementById('sa-badge-floating-plugin')
  $embeddedBadgePlugin: -> @parent_doc.getElementById('sa-badge-embedded-plugin')
  $closeModalButton: -> @parent_doc.getElementById('sa-badge-modal-close-button')
  $showReviewsButton: ->
    switch context().configuration.display
      when 'floating' then @$floatingBadgePlugin()
      when 'embedded' then @$embeddedBadgePlugin()

  ###
  Adds the required css for the plugin
  ###
  addStyle: ->
    style = document.createElement('style')
    style.id = 'sa-badge-style'
    style.type = 'text/css'

    # IE compatibility
    if style.styleSheet
      style.styleSheet.cssText = STYLE(context().configuration)
    else
      style.appendChild(document.createTextNode(STYLE(context().configuration)))

    @_head().appendChild(style)

  _renderFloating: ->
    $el = document.createElement('div')
    $el.id = 'sa-badge-floating-plugin'
    $el.className += 'sa-badge-no-stars' if @_noStars(context().data.rating)
    $el.innerHTML = FLOATING_TEMPLATE(stars: @_ratingToStars(context().data.rating))
    @parent_doc.body.appendChild($el)

  _renderEmbedded: ->
    rating = context().data.rating
    @$embeddedBadgePlugin().className += ' sa-badge-no-stars' if @_noStars(rating)
    @$embeddedBadgePlugin().innerHTML = EMBEDDED_TEMPLATE(rating: rating.toFixed(1), stars: @_ratingToStars(rating))

  _bindHandlers: ->
    @_attachEvent(@$showReviewsButton(), 'click', @_onClickShowReviewsButton)

  _attachEvent: (element, event, handler) ->
    return element.addEventListener event, handler, false  if element.addEventListener
    element.attachEvent "on#{event}", handler              if element.attachEvent

  _createModal: ->
    @$modal = document.createElement('div')
    @$modal.id = 'sa-badge-modal'
    @$modal.innerHTML = MODAL_INNER_TEMPLATE(src: @_iframeSrc())
    @parent_doc.body.appendChild(@$modal)
    @_attachEvent(@$closeModalButton(), 'click', @_onClickModalCloseButton)
    @_attachEvent(@$modal, 'click', @_onClickModal)
    @_attachEvent(@parent_doc, 'keyup', @_onKeyUp)

  _destroyModal: ->
    return unless @$modal?

    @$modal.parentNode.removeChild(@$modal)
    @$modal = null

  _showModal: ->
    return @_createModal() unless @$modal?

    @$modal.style.display = 'block'

  _hideModal: ->
    return unless @$modal?

    @$modal.style.display = 'none'

    # Destroy modal with its iframe because some mobile browsers (e.g Android
    # Firefox and most of iOS browsers) have a scrolling issue when an
    # iframe transitions from display: 'none' to display: 'block'.
    @_destroyModal()

  _onClickShowReviewsButton: => @_showModal()
  _onClickModal: => @_hideModal()
  _onClickModalCloseButton: => @_hideModal()

  _onKeyUp: (event) =>
    if (event.keyCode || event.which) == 27 # ESC
      # Make sure to destroy modal in order to reload iframe on next _showModal,
      # as browsers interrupt iframe loading on ESC.
      @_hideModal()

  _head: -> @parent_doc.head || @parent_doc.getElementsByTagName('head')[0]

  _setParentDoc: -> @parent_doc = window.parent.document

  _ratingToStars: (rating = 0, limit = 5) ->
    return [] if @_noStars(rating)

    # When rating is X.5 +/- 0.2, round it to X.5
    rating = Math.round(rating * 2) / 2

    return ([0...limit].map -> 'full') if rating >= limit
    return ([0...limit].map -> 'empty') if rating <= 0

    full_stars_count = Math.floor(rating)

    stars = []
    stars.push('full') for star in [0...full_stars_count]
    stars.push(if (rating % 1 == 0.5) then 'half' else 'empty')
    stars.push('empty') for star in [limit...full_stars_count+1]

    stars

  _noStars: (rating) -> rating is 0

  _canRender: ->
    if context().configuration.display == 'embedded' && !@$embeddedBadgePlugin() then false else true

  _iframeSrc: ->
    params =
      shop_code: context().shop_code
      origin: window.location.origin
      pathname: window.location.pathname

    serialized_params = ("#{k}=#{encodeURIComponent(v)}" for k, v of params).join('&')

    "#{settings.url.application_base}/badge/shop_reviews?#{serialized_params}"

new Badge
