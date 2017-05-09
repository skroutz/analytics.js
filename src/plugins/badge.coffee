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

    -moz-border-radius: 49px;
    -webkit-border-radius: 49px;
    border-radius: 49px;

    background-image: url('#{asset_url("badge/floating/large/theme/#{configuration.theme}/logo_@@flavor.png")}');
    background-position: center;
    background-repeat: no-repeat;
    background-size: 90px 90px;

    cursor: pointer;

    z-index: 2147483647;

    -webkit-animation: sa-badge-fade-in 0.3s ease-in;
    animation: sa-badge-fade-in 0.3s ease-in;

    box-shadow: 0 0 4px rgba(0,0,0,.14), 0 4px 8px rgba(0,0,0,.28);
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

    display: #{if configuration.display is 'embedded' then 'block' else 'none !important'};

    position: relative;
    clear: both;

    width: 255px;
    height: 93px;
    box-sizing: border-box;

    padding: 15px;
    background-color: #{switch configuration.theme
                        when 'white' then '#ffffff'
                        when 'black' then '#363636'};
  }

  #sa-badge-embedded-plugin * {
    all: unset;
  }

  #sa-badge-embedded-plugin #sa-badge-embedded-header {
    display: block;
    height: 24px;
  }

  #sa-badge-embedded-plugin #sa-badge-embedded-footer {
    display: block;
    margin-top: 10px;
    text-align: center;
  }

  #sa-badge-embedded-header #sa-badge-embedded-logo {
    display: inline-block;

    width: 124px;
    height: 24px;

    background-image: url('#{asset_url("badge/embedded/theme/#{configuration.theme}/logo_@@flavor.png")}');
    background-position: center;
    background-repeat: no-repeat;
    background-size: 124px 24px;
  }

  #sa-badge-embedded-header #sa-badge-embedded-rating {
    display: inline-block;

    width: 90px;
    height: 24px;

    vertical-align: top;
    float: right;

    padding-top: 5px;
  }

  #sa-badge-embedded-header #sa-badge-embedded-rating .sa-badge-rating-number {
    display: inline-block;

    font-family: Verdana, Arial, sans-serif !important;
    font-weight: bold;
    font-size: 14px !important;
    color: #{switch configuration.theme
               when 'white' then '#000000'
               when 'black' then '#ffffff'};
    -webkit-text-fill-color: currentColor;
  }

  #sa-badge-embedded-header #sa-badge-embedded-rating .sa-badge-stars-container {
    display: inline-block;
  }

  #sa-badge-embedded-header #sa-badge-embedded-rating .sa-badge-stars-container .sa-badge-star {
    display: inline-block;
    margin-right: -3px;

    width: 11px;
    height: 10px;

    background-position: center;
    background-repeat: no-repeat;
    background-size: 11px 10px;
  }

  #sa-badge-embedded-header #sa-badge-embedded-rating .sa-badge-stars-container .sa-badge-full-star {
    background-image: url('#{asset_url("badge/embedded/theme/#{configuration.theme}/star_full.png")}');
  }

  #sa-badge-embedded-header #sa-badge-embedded-rating .sa-badge-stars-container .sa-badge-half-star {
    background-image: url('#{asset_url("badge/embedded/theme/#{configuration.theme}/star_half.png")}');
  }

  #sa-badge-embedded-header #sa-badge-embedded-rating .sa-badge-stars-container .sa-badge-empty-star {
    background-image: url('#{asset_url("badge/embedded/theme/#{configuration.theme}/star_empty.png")}');
  }

  #sa-badge-embedded-footer #sa-badge-embedded-more-button {
    display: inline-block;

    padding: 6px 15px 7px 15px;
    min-width: 90px;

    background-color: #f68b24 !important;
    color: white !important;
    -webkit-text-fill-color: currentColor;
    font-family: Verdana, Arial, sans-serif !important;
    font-size: 11px !important;

    cursor: pointer;
    border-radius: 2px;

    text-decoration: none;

    transition: none;
    transition: background-color .2s ease-in-out;
  }

  #sa-badge-embedded-footer #sa-badge-embedded-more-button:hover {
    color: white !important;
    background-color: #d8721c !important;
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
    overflow-y: scroll;
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
      bottom: 15px;
      #{switch configuration.position
          when 'bottom-left' then 'left: 15px;'
          when 'bottom-right' then 'right: 15px;'}

      width: 70px;
      height: 70px;

      -moz-border-radius: 39px;
      -webkit-border-radius: 39px;
      border-radius: 39px;

      background-image: url('#{asset_url("badge/floating/small/theme/#{configuration.theme}/hat_logo.png")}');
      background-size: 70px 70px;
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

    #sa-badge-embedded-header #sa-badge-embedded-logo {
      background-image: url('#{asset_url("badge/embedded/theme/#{configuration.theme}/logo_@@flavor@2x.png")}');
    }

    #sa-badge-embedded-header #sa-badge-embedded-rating .sa-badge-stars-container .sa-badge-full-star {
      background-image: url('#{asset_url("badge/embedded/theme/#{configuration.theme}/star_full@2x.png")}');
    }

    #sa-badge-embedded-header #sa-badge-embedded-rating .sa-badge-stars-container .sa-badge-half-star {
      background-image: url('#{asset_url("badge/embedded/theme/#{configuration.theme}/star_half@2x.png")}');
    }

    #sa-badge-embedded-header #sa-badge-embedded-rating .sa-badge-stars-container .sa-badge-empty-star {
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
  """

  FLOATING_TEMPLATE = (assigns) -> """
  <div id="sa-badge-floating-stars-container">
    #{(STAR_TEMPLATE(star_type, assigns) for star_type in assigns.stars).join("\n")}
  </div>
  """

  EMBEDDED_TEMPLATE = (assigns) -> """
  <div id="sa-badge-embedded-header">
    <div id="sa-badge-embedded-logo"></div>
    <div id="sa-badge-embedded-rating">
      <div class="sa-badge-rating-number"><span>#{assigns.rating}</span></div>
      <div class="sa-badge-stars-container">
        #{(STAR_TEMPLATE(star_type, assigns) for star_type in assigns.stars).join("\n")}
      </div>
    </div>
  </div>
  <div id="sa-badge-embedded-footer">
    <span id="sa-badge-embedded-more-button">@@translations.badge.more</span>
  </div>
  """

  STAR_TEMPLATE = (type, assigns) -> """
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
  $embeddedBadgeMoreButton: -> @parent_doc.getElementById('sa-badge-embedded-more-button')
  $closeModalButton: -> @parent_doc.getElementById('sa-badge-modal-close-button')
  $showReviewsButton: ->
    switch context().configuration.display
      when 'floating' then @$floatingBadgePlugin()
      when 'embedded' then @$embeddedBadgeMoreButton()

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
    $el.innerHTML = FLOATING_TEMPLATE(stars: @_ratingToStars(context().data.rating))
    @parent_doc.body.appendChild($el)

  _renderEmbedded: ->
    rating = context().data.rating
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
