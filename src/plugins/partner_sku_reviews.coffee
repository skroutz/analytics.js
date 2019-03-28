###
Plugin which shows SKU reviews for a given product
###

## Helpers

attachEvent = (element, event, handler) ->
  return element.addEventListener event, handler, false  if element.addEventListener
  element.attachEvent "on#{event}", handler if element.attachEvent

format_1_decimal = (num, translate_decimal = true) ->
  decimal_point = if translate_decimal then '@@translations.partner_sku_reviews.decimal_point' else '.'
  num.toFixed(1).replace('.', decimal_point)

## Reusable template fragments

# "1 star", "2 stars", "2.3 stars" etc...
starText = (star_score, fraction = false, translate_decimal = true) ->
  star_score = format_1_decimal(star_score, translate_decimal) if fraction
  star_score + if !fraction && star_score == 1
                 ' @@translations.partner_sku_reviews.star'
               else
                 ' @@translations.partner_sku_reviews.stars'

stars = (reviewscore, reviews_count, fraction = false) ->
  starsWidth = 0;
  if reviewscore
    starsWidth = (reviewscore * 20).toFixed(1)
    title = starText(reviewscore, fraction)

  if reviews_count
    title += " @@translations.partner_sku_reviews.from #{reviews_count} "
    title += if reviews_count == 1
               ' @@translations.partner_sku_reviews.user_from '
             else
               '@@translations.partner_sku_reviews.users_from'

  """
    <div class="sa-star-rating" title="#{title}">
      <div class="sa-star-rating-wrapper">
        <div class="sa-actual-star-rating" style="width: #{starsWidth}%"></div>
      </div>
    </div>
  """

# rating value and stars
starRating = (reviewscore, reviews_count, translate_decimal=true) -> """
    <div class="sa-rating-value">#{format_1_decimal(reviewscore, translate_decimal)}</div>
    #{stars(reviewscore, reviews_count, true)}
    <div class="sa-reviews-count-compact">#{reviews_count}</div>
  """

brandIndicator = -> """
    <div class="sa-brand">
      <div class="sa-brand-inner">
        <span class="sa-brand-powered-by">Powered by</span>
        <div class="sa-brand-logo"></div>
      </div>
    </div>
  """

ratingBreakdown = (breakdown) ->
  list_elements = breakdown.map ({star, percentage, count}) ->
    """
      <li class="sa-rating-breakdown-class">
        <div class="sa-num-stars">
          #{starText(star)}
        </div>
        <div class="sa-rating-bar-wrap">
          <div class="sa-rating-bar" style="width: #{percentage}%"></div>
        </div>
        <div class="sa-rating-count">#{count}</div>
      </li>
    """

  """
    <ul class="sa-rating-breakdown">
      #{list_elements.join('')}
    </ul>
  """

## Components

class BaseComponent
  ###
  @param [Element] el Target to mount onto
  @param [Object] assigns Local assigns
  ###
  constructor: (@el, @assigns) ->

  ###
  Renders the template, adds the classes and attaches interaction event handlers
  ###
  render: ->
    @el.setAttribute('class', (@el.getAttribute('class') || '')+' '+@classes().join(' '))
    @el.innerHTML = @template()
    for {event, selector, handler} in @interaction()
      elements = if selector then @el.querySelectorAll(selector) else [@el]
      for element in elements
        attachEvent(element, event, handler)

  ###
  @return [String] The HTML content to be rendered in el
  ###
  template: -> ''

  ###
  @return [Array[String]] classes to be added to el
  ###
  classes: -> []

  ###
  @return [Array[{event: String, selector?: String, handler: String}]]
          Array with interaction specifying triplets containing:
            event: Event name, such as 'click'
            selector: Specifies elements within el that react to the event
                      If ommited, it is assumed to be el
            handler: Function to be called on event trigger
  ###
  interaction: -> []


class InlineSkuReviews extends BaseComponent
  constructor: (el, assigns) ->
    super(el, assigns)
    {@reviewscore, @reviews_count} = assigns.product_information

  template: -> """
    <div class="sa-rating-with-count">
      #{starRating(@reviewscore, @reviews_count, false)}
    </div>
    <div class="sa-inline-separator"></div>
    <div class="sa-inline-secondary-indicators">
      <div class="sa-reviews-count-texty">
        <span class="sa-reviews-count-value">#{@reviews_count}</span>
        <span class="sa-reviews-count-text">@@translations.partner_sku_reviews.product_reviews</span>
      </div>
      #{brandIndicator()}
    </div>
  """

  classes: -> ['sa-'+@assigns.configuration.inline_widget_theme,
               'sa-reviews-inline-root']

  interaction: -> [
    event: 'click'
    handler: @assigns.showModal
  ]


class ExtendedSkuReviews extends BaseComponent
  BIG_REVIEW_LENGTH = 500

  skuSales = (sales_text) ->
    return '' unless sales_text

    """
      <div class="sa-sales-wrap">
        <span class="sa-sales-text">#{sales_text}</span>
      </div>
    """

  reviewsAggregation = (aggregation) ->
    return '' unless aggregation && aggregation.length

    aggregation_elements = aggregation.map ({label, score, style}) ->
      # possible styles are: "good", "so-so" and "bad"
      # which translate into classes: "sa-good", "sa-so-so" and "sa-bad"
      """
        <li class="sa-reviews-aggregation-feature">
          <span class="sa-reviews-aggregation-label">#{label}</span>
          <div class="sa-reviews-aggregation-bar-wrap">
            <span class="sa-reviews-aggregation-bar sa-#{style}" style="width: #{score}%"></span>
          </div>
        </li>
      """

    """
      <div class="sa-reviews-aggregation-wrap">
        <ul class="sa-reviews-aggregation-list">
          #{aggregation_elements.join('')}
        </ul>
      </div>
    """

  # "53 out of 67 members found this review helpful"
  helpfulVoting = (helpful_votes, total_votes) ->
    return '' if !total_votes

    """
      <span class="sa-review-usefull-voting">
        #{helpful_votes} @@translations.partner_sku_reviews.out_of #{total_votes} @@translations.partner_sku_reviews.users_found_usefull
      </span>
    """

  reviewSentiments = (sentiments) ->
    sentiment_elements = ['positive', 'mediocre', 'negative'].map (sentiment) ->
      features = sentiments[sentiment]
      return '' unless features && features.length

      feature_elements = features.map (feature) -> "<li class='sa-review-feature-sentiment'>#{feature}</li>"
      """
        <ul class="sa-review-sentiment sa-#{sentiment}">
          #{feature_elements.join('')}
        </ul>
      """

    """
      <div class="sa-review-sentiments">
        #{sentiment_elements.join('')}
      </div>
    """

  userReviews = (reviews) ->
    review_elements = reviews.map (review, index) ->
      user = review.user
      expandable = review.review.length > BIG_REVIEW_LENGTH
      expand_button = if expandable
        "<span class='sa-review-expand' data-index='#{index}'>@@translations.partner_sku_reviews.more</span>"
      else
        ''
      """
        <li class="sa-review #{ if expandable then 'sa-expandable' else ''}" data-index='#{index}'>
          <div class="sa-review-header">
            <img class="sa-review-avatar" src="#{user.avatar}" alt="avatar of user #{user.username}"/>
            <div class="sa-review-info">
              #{stars(review.rating)}
              #{helpfulVoting(review.helpful_votes_count, review.votes_count)}
            </div>
            <div class="sa-authorship-info">
              <span class="sa-review-author">#{user.username}</span>
              <span class="sa-review-at">@@translations.partner_sku_reviews.at</span>
              <span class="sa-review-date">#{review.created_at}</span>
            </div>
          </div>
          <div class="sa-review-main">
            <p class="sa-review-text">#{review.review}</p>
            #{expand_button}
            #{reviewSentiments(review.sentiments)}
          </div>
        </li>
      """

    """
      <ul class="sa-reviews-list">
        #{review_elements.join('')}
      </ul>
    """

  constructor: (el, assigns) ->
    super(el, assigns)
    @showRatingBreakdown = false
    @application_base = assigns.application_base
    {@title, @reviewscore, @reviews_count,
      @rating_breakdown, @reviews_aggregation, @sales, @reviews, @sku_id} = assigns.product_information

  template: ->
    if @reviews_count == 0 # no content
      write_review_link = "#{@application_base}/account/products/#{@sku_id}/reviews/new?from=partner_sku_reviews"
      body = """
        <div class="sa-review-prompt">
          <h4 class="sa-review-prompt-head">@@translations.partner_sku_reviews.share_your_experience</h4>
          <p class="sa-review-prompt-motive">@@translations.partner_sku_reviews.write_review_for #{@title} @@translations.partner_sku_reviews.and_help</p>
          <a class="sa-review-prompt-button" rel="nofollow" target="_blank"
             href="#{write_review_link}">@@translations.partner_sku_reviews.review_this</a>
        </div>
      """
    else
      body = """
        <div class="sa-extended-reviews-body">
          <h3 class="sa-sku-title">#{@title}</h3>
          <div class="sa-sku-details">
            <div class="sa-rating-full">
              #{starRating(@reviewscore, @reviews_count)}
              <div class="sa-rating-breakdown-wrap">
                <div class="sa-rating-arrow"></div>
                #{ratingBreakdown(@rating_breakdown)}
              </div>
            </div>
            #{reviewsAggregation(@reviews_aggregation)}
            #{skuSales(@sales)}
          </div>
          <div class="sa-reviews">
            #{userReviews(@reviews)}
            <div class="sa-show-review-modal">@@translations.partner_sku_reviews.read_more</div>
          </div>
        </div>
      """

    """
      <div class="sa-extended-reviews-header">
        <span class="sa-extended-reviews-title">
          @@translations.partner_sku_reviews.user_reviews
        </span>
        #{brandIndicator()}
      </div>
      #{body}
    """

  classes: -> ['sa-'+@assigns.configuration.extended_widget_theme,
               'sa-reviews-extended-root']

  toggleReviewBreakdown: ->
    @showRatingBreakdown = !@showRatingBreakdown
    breakdown_el = @el.querySelector('.sa-rating-breakdown')
    breakdown_el.style.display = if @showRatingBreakdown then 'block' else 'none'

  expandReview: (e) ->
    review_index = e.target.getAttribute('data-index')
    review_el = @el.querySelector(".sa-review[data-index='#{review_index}']")
    review_el.className = review_el.className.replace(/\bsa-expandable\b/, '')

  interaction: -> [
    {
      event: 'click'
      selector: '.sa-show-review-modal'
      handler: @assigns.showModal
    }
    {
      event: 'click'
      selector: '.sa-reviews-count-compact, .sa-rating-arrow'
      handler: () => @toggleReviewBreakdown()
    }
    {
      event: 'click'
      selector: '.sa-review-expand'
      handler: (e) => @expandReview(e)
    }
  ]


class SkuReviewsModal extends BaseComponent
  constructor: (assigns) ->
    super(null, assigns)
    @iframe_src = @buildIframeSrc()

  template: -> """
    <div id="sa-reviews-modal-inner" class="sa-reviews-spinner">
      <span id="sa-reviews-modal-close-button"></span>
      <div id="sa-reviews-modal-iframe-container">
        <iframe id="sa-reviews-modal-iframe" src="#{@iframe_src}" width="100%" height="100%" frameborder="0"></iframe>
      </div>
    </div>
  """

  buildIframeSrc: ->
    "#{@assigns.application_base}/badge/sku_reviews?"\
    + "shop_code=#{@assigns.shop_code}"\
    + "&sku_id=#{@assigns.product_information.sku_id}"\
    + "&origin=#{encodeURIComponent(window.location.origin)}"\
    + "&pathname=#{encodeURIComponent(window.location.pathname)}"

  show: ->
    unless @el
      # Create modal element
      @el = @assigns.parent_doc.createElement('div')
      @el.id = 'sa-reviews-modal'
      @assigns.parent_doc.getElementsByTagName('body')[0].appendChild(@el)

    @render()
    @el.style.display = 'block'

  hide: ->
    return unless @el?

    # destroy modal, see badge.coffee on why this is necessary
    @el.parentNode.removeChild(@el)
    @el = null

  interaction: -> [
    event: 'click'
    handler: () => @hide()
  ]

## Main class

class PartnerSkuReviews
  DOMREADY_TIMEOUT = 2000 # 2 seconds
  COLORS = ['white', 'grey', 'black', 'orange']
  SIZES = ['small', 'medium']

  settings = window.sa_plugins.settings
  context = -> window.sa_plugins.partner_sku_reviews

  asset_url = (source) -> "#{settings.url.base}/assets/#{source}"

  constructor: ->
    @parent_doc = window.parent.document
    @onDOMReady =>
      @head = @parent_doc.getElementsByTagName('head')[0]
      @_renderAll()

  _renderAll: ->
    inline_el = @parent_doc.getElementById('@@flavor-product-reviews-inline')
    if inline_el
      @product_id = inline_el.getAttribute('data-product-id')

    extended_el = @parent_doc.getElementById('@@flavor-product-reviews-extended')
    if extended_el
      @product_id ||= extended_el.getAttribute('data-product-id') # TODO handle case of different product ids

    return unless @product_id

    @_fetchProductInformation !!extended_el, (product_information) =>
      return unless product_information.reviewable

      review_count_to_show = context().configuration.extended_widget_reviews_count
      if product_information.reviews && review_count_to_show
        product_information.reviews = product_information.reviews.slice(0, review_count_to_show)

      configuration = context().configuration
      assigns =
        parent_doc: @parent_doc
        product_information: product_information
        configuration: configuration
        application_base: settings.url.application_base
        shop_code: context().shop_code
        showModal: () => @modal.show()
        hideModal: () => @modal.hide()

      @modal = new SkuReviewsModal(assigns)
      if inline_el && configuration.inline_widget_enabled && product_information.reviews_count > 0
        @_beforeWidgetDisplayed()
        new InlineSkuReviews(inline_el, assigns).render()
      if extended_el && configuration.extended_widget_enabled
        @_beforeWidgetDisplayed()
        new ExtendedSkuReviews(extended_el, assigns).render()

  _beforeWidgetDisplayed: =>
    return if @widget_displayed

    @_addStyle()
    attachEvent(@parent_doc, 'keyup', @_onKeyUp)

    @widget_displayed = true

  _onKeyUp: (event) =>
    @modal.hide() if (event.keyCode || event.which) == 27 # ESC

  _fetchProductInformation: (extended, callback) ->
    shop_code = context().shop_code
    server_address = settings.url.application_base
    url = "#{server_address}/badge/api/sku_reviews?shop_code=#{shop_code}&product_id=#{encodeURIComponent(@product_id)}"
    if extended
      url += '&include[]=rating_breakdown&include[]=reviews_aggregation&include[]=reviews&include[]=sales'

    @_jsonpFetch url, callback

  _jsonpFetch: (url, callback) ->
    url += '&callback=sa_jsonp_sku_reviews_fetch'

    script = document.createElement('script')
    script.id = 'sa_jsonp_sku_reviews_fetch'
    script.type = 'text/javascript'
    script.src = url
    script.charset = 'utf-8'
    script.async = true

    window.parent['sa_jsonp_sku_reviews_fetch'] = (response) =>
      callback(response)
      # cleanup
      script.parentNode.removeChild(script)
      delete window.parent['sa_jsonp_sku_reviews_fetch']

    @head.appendChild(script)

  _addStyle: ->
    style = document.createElement('style')
    style.id = 'sa-partner-sku-reviews-style'
    style.type = 'text/css'

    # IE compatibility
    if style.styleSheet
      style.styleSheet.cssText = STYLE()
    else
      style.appendChild(document.createTextNode(STYLE()))

    @head.appendChild(style)

  ###
  Detect DOM ready
  @todo DRY this method as it is being used in other plugins too.
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

  # CSS helpers, only for inline
  coloredSelector = (color, selector = '') ->
    SIZES.map((size) -> "#@@flavor-product-reviews-inline.sa-#{size}-#{color} #{selector}").join(', ')

  sizedSelector = (size, selector = '') ->
    COLORS.map((color) -> "#@@flavor-product-reviews-inline.sa-#{size}-#{color} #{selector}").join(', ')

  STYLE = ->
    flavor = '@@flavor'

    """
    /* COMMON */

    ##{flavor}-product-reviews-inline *, ##{flavor}-product-reviews-extended * {
      all: unset;
      font-family: Verdana, Arial, sans-serif !important;
    }

    ##{flavor}-product-reviews-inline .sa-star-rating-wrapper,
    ##{flavor}-product-reviews-extended .sa-star-rating-wrapper {
      display: inline-block;
      background-size: contain;
      background-image: url("data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+PHN2ZyB3aWR0aD0iMTRweCIgaGVpZ2h0PSIxNHB4IiB2aWV3Qm94PSIwIDAgMTQgMTQiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+ICAgICAgICA8dGl0bGU+RGVza3RvcCAvIEljb24gLyBTdGFyIC8gU3RhciBhY3RpdmUgNiBDb3B5PC90aXRsZT4gICAgPGRlc2M+Q3JlYXRlZCB3aXRoIFNrZXRjaC48L2Rlc2M+ICAgIDxkZWZzPjwvZGVmcz4gICAgPGcgaWQ9IlNrdS1Qcm9kdWN0LUluZm8iIHN0cm9rZT0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIxIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPiAgICAgICAgPGcgaWQ9IjE1MDBweC0vLVNrdS0vLUxheW91dC0vLc6azrnOvc63z4TOsS3OpM63zrvOtc+Gz4nOvc6xLUNvcHktMyIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoLTUxNi4wMDAwMDAsIC0yMTkuMDAwMDAwKSIgZmlsbD0iI0RERERERCI+ICAgICAgICAgICAgPGcgaWQ9IlByb2R1Y3QtSW5mby1Db3B5LTUiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDQxMi41MDAwMDAsIDE3NC4wMDAwMDApIj4gICAgICAgICAgICAgICAgPGcgaWQ9IkxpbmtzIiB0cmFuc2Zvcm09InRyYW5zbGF0ZSgwLjUwMDAwMCwgMzguNTAwMDAwKSI+ICAgICAgICAgICAgICAgICAgICA8ZyBpZD0iUmF0aW5nLUNvcHkiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDAuNTAwMDAwLCAxLjUwMDAwMCkiPiAgICAgICAgICAgICAgICAgICAgICAgIDxnIGlkPSJSYXRpbmctYmlnLUNvcHkiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDQwLjAwMDAwMCwgNS4wMDAwMDApIj4gICAgICAgICAgICAgICAgICAgICAgICAgICAgPHBhdGggZD0iTTY5LjQzNjI0MTksMCBMNjcuMTEwMDg4MSw0LjYxNTM4NDYyIEw2Mi40OTQ3MDM1LDQuOTIxMTUzODUgTDY1Ljk1MTYyNjYsOC44MjgwNzY5MiBMNjQuODU2NjI2NiwxMy44NDYxNTM4IEw2OS40MDczOTU4LDExLjA3NTc2OTIgTDc0LjAzMzE2NSwxMy44NDYxNTM4IEw3Mi44NjMxNjUsOC44MjgwNzY5MiBMNzYuMzQwODU3Myw0Ljg0OTYxNTM4IEw3MS43MjY2MjY2LDQuNjE1Mzg0NjIgTDY5LjQzNjI0MTksMCIgaWQ9IkRlc2t0b3AtLy1JY29uLS8tU3Rhci0vLVN0YXItYWN0aXZlLTYtQ29weSI+PC9wYXRoPiAgICAgICAgICAgICAgICAgICAgICAgIDwvZz4gICAgICAgICAgICAgICAgICAgIDwvZz4gICAgICAgICAgICAgICAgPC9nPiAgICAgICAgICAgIDwvZz4gICAgICAgIDwvZz4gICAgPC9nPjwvc3ZnPg==");
      background-repeat: repeat-x;
    }

    ##{flavor}-product-reviews-inline .sa-actual-star-rating,
    ##{flavor}-product-reviews-extended .sa-actual-star-rating {
      display: block;
      background-image: url("data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+Cjxzdmcgd2lkdGg9IjEzcHgiIGhlaWdodD0iMTNweCIgdmlld0JveD0iMCAwIDEzIDEzIiB2ZXJzaW9uPSIxLjEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHhtbG5zOnNrZXRjaD0iaHR0cDovL3d3dy5ib2hlbWlhbmNvZGluZy5jb20vc2tldGNoL25zIj4KICAgIDwhLS0gR2VuZXJhdG9yOiBTa2V0Y2ggMy4zICgxMTk3MCkgLSBodHRwOi8vd3d3LmJvaGVtaWFuY29kaW5nLmNvbS9za2V0Y2ggLS0+CiAgICA8dGl0bGU+U2hhcGU8L3RpdGxlPgogICAgPGRlc2M+Q3JlYXRlZCB3aXRoIFNrZXRjaC48L2Rlc2M+CiAgICA8ZGVmcz48L2RlZnM+CiAgICA8ZyBpZD0iUGFnZS0xIiBzdHJva2U9Im5vbmUiIHN0cm9rZS13aWR0aD0iMSIgZmlsbD0ibm9uZSIgZmlsbC1ydWxlPSJldmVub2RkIiBza2V0Y2g6dHlwZT0iTVNQYWdlIj4KICAgICAgICA8ZyBpZD0ib3JhbmdlLXN0YXIiIHNrZXRjaDp0eXBlPSJNU0xheWVyR3JvdXAiIGZpbGw9IiNGNjhCMjQiPgogICAgICAgICAgICA8ZyBpZD0iUGFnZS0xIiBza2V0Y2g6dHlwZT0iTVNTaGFwZUdyb3VwIj4KICAgICAgICAgICAgICAgIDxnIGlkPSJzdGFyX2JpZyI+CiAgICAgICAgICAgICAgICAgICAgPHBhdGggZD0iTTYuNSwwLjQgTDguNSw0LjQgTDEyLjUsNC42IEw5LjUsOCBMMTAuNSwxMi4zIEw2LjUsOS45IEwyLjYsMTIuMyBMMy41LDggTDAuNSw0LjYgTDQuNSw0LjMgTDYuNSwwLjQiIGlkPSJTaGFwZSI+PC9wYXRoPgogICAgICAgICAgICAgICAgPC9nPgogICAgICAgICAgICA8L2c+CiAgICAgICAgPC9nPgogICAgPC9nPgo8L3N2Zz4=");
      background-size: inherit;
      background-repeat: inherit;
      height: 100%;
    }

    ##{flavor}-product-reviews-inline .sa-brand-powered-by,
    ##{flavor}-product-reviews-extended .sa-brand-powered-by {
      color: #707070;
      -webkit-text-fill-color: currentColor;
    }

    ##{flavor}-product-reviews-inline .sa-brand-logo,
    ##{flavor}-product-reviews-extended .sa-brand-logo {
      display: inline-block;
      background-image: url('#{asset_url("logo_#{flavor}.png")}');
      background-position: center;
      background-repeat: no-repeat;
      background-size: contain;
    }

    ##{flavor}-product-reviews-inline .sa-reviews-count-compact,
    ##{flavor}-product-reviews-extended .sa-reviews-count-compact {
      letter-spacing: 1px;
    }

    ##{flavor}-product-reviews-inline .sa-reviews-count-compact::before,
    ##{flavor}-product-reviews-extended .sa-reviews-count-compact::before {
      content: "(";
    }

    ##{flavor}-product-reviews-inline .sa-reviews-count-compact::after,
    ##{flavor}-product-reviews-extended .sa-reviews-count-compact::after {
      content: ")";
    }

    /* INLINE */

    ##{flavor}-product-reviews-inline.sa-reviews-inline-root {
      all: initial;
      display: inline-flex;
      display: -ms-inline-flexbox;
      flex-direction: column;
      -ms-flex-direction: column;
      width: 150px;
      height: 70px;
      box-sizing: content-box;
      background: #fff;
      border: 1px solid #dcdcdc;
      border-radius: 3px;
      cursor: pointer;
    }

    ##{flavor}-product-reviews-inline .sa-rating-with-count {
      display: flex;
      display: -ms-flexbox;
      height: 41px;
      padding-left: 8px;
      box-sizing: border-box;
      align-items: center;
      -ms-flex-align: center;
    }

    ##{flavor}-product-reviews-inline .sa-rating {
      display: flex;
      display: -ms-flexbox;
      align-items: baseline;
      -ms-flex-align: baseline;
    }

    ##{flavor}-product-reviews-inline .sa-star-rating {
      margin-right: 3px;
    }

    ##{flavor}-product-reviews-inline .sa-star-rating-wrapper {
      width: 65px;
      height: 13px;
      background-size: contain;
    }

    ##{flavor}-product-reviews-inline .sa-reviews-count-texty {
      display: none
    }

    ##{flavor}-product-reviews-inline .sa-rating-value {
      font-size: 15px;
      font-weight: bold;
      margin-right: 3px;
    }

    ##{flavor}-product-reviews-inline .sa-reviews-count-compact {
      font-size: 11px;
      color: #909090;
      -webkit-text-fill-color: currentColor;
      letter-spacing: 1px;
    }

    ##{flavor}-product-reviews-inline .sa-rating-with-count::after {
      content: "›";
      flex: 1 1 auto;
      -ms-flex: 1 1 auto;
      text-align: center;
      font-size: 18px;
      font-weight: bold;
      color: #d5d4d4;
      -webkit-text-fill-color: currentColor;
    }

    ##{flavor}-product-reviews-inline .sa-inline-separator {
      height: 1px;
      background: #797979;
      opacity: 0.3;
    }

    ##{flavor}-product-reviews-inline .sa-brand {
      display: flex;
      display: -ms-flexbox;
      height: 29px;
      padding-left: 8px;
      align-items: center;
      -ms-flex-align: center;
    }

    ##{flavor}-product-reviews-inline .sa-brand-powered-by {
      font-size: 12px;
      vertical-align: middle;
      text-transform: lowercase;
    }

    ##{flavor}-product-reviews-inline .sa-brand-logo {
      width: 54.5px;
      height: 15px;
    }

    #{coloredSelector 'grey'} {
      background: #f8f8f8;
    }

    #{coloredSelector 'orange'} {
      background: #f68b24;
      border-color: transparent;
    }

    #{coloredSelector 'orange', '.sa-rating-with-count'} {
      border-bottom: 1px solid #e87b13;
    }

    #{coloredSelector 'orange', '.sa-rating-value'},
    #{coloredSelector 'orange', '.sa-reviews-count-compact'},
    #{coloredSelector 'orange', '.sa-reviews-count-texty'},
    #{coloredSelector 'orange', '.sa-brand-powered-by'},
    #{coloredSelector 'orange', '.sa-rating-with-count::after'} {
      color: #fff;
      -webkit-text-fill-color: currentColor;
    }

    #{coloredSelector 'orange', '.sa-star-rating-wrapper'} {
      background-image: url("data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+PHN2ZyB3aWR0aD0iMTRweCIgaGVpZ2h0PSIxNHB4IiB2aWV3Qm94PSIwIDAgMTQgMTQiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+ICAgICAgICA8dGl0bGU+RGVza3RvcCAvIEljb24gLyBTdGFyIC8gU3RhciBhY3RpdmUgNiBDb3B5PC90aXRsZT4gICAgPGRlc2M+Q3JlYXRlZCB3aXRoIFNrZXRjaC48L2Rlc2M+ICAgIDxkZWZzPjwvZGVmcz4gICAgPGcgaWQ9IlNrdS1Qcm9kdWN0LUluZm8iIHN0cm9rZT0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIxIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPiAgICAgICAgPGcgaWQ9IjE1MDBweC0vLVNrdS0vLUxheW91dC0vLc6azrnOvc63z4TOsS3OpM63zrvOtc+Gz4nOvc6xLUNvcHktMyIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoLTUxNi4wMDAwMDAsIC0yMTkuMDAwMDAwKSIgZmlsbD0iI2FjNjExOSI+ICAgICAgICAgICAgPGcgaWQ9IlByb2R1Y3QtSW5mby1Db3B5LTUiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDQxMi41MDAwMDAsIDE3NC4wMDAwMDApIj4gICAgICAgICAgICAgICAgPGcgaWQ9IkxpbmtzIiB0cmFuc2Zvcm09InRyYW5zbGF0ZSgwLjUwMDAwMCwgMzguNTAwMDAwKSI+ICAgICAgICAgICAgICAgICAgICA8ZyBpZD0iUmF0aW5nLUNvcHkiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDAuNTAwMDAwLCAxLjUwMDAwMCkiPiAgICAgICAgICAgICAgICAgICAgICAgIDxnIGlkPSJSYXRpbmctYmlnLUNvcHkiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDQwLjAwMDAwMCwgNS4wMDAwMDApIj4gICAgICAgICAgICAgICAgICAgICAgICAgICAgPHBhdGggZD0iTTY5LjQzNjI0MTksMCBMNjcuMTEwMDg4MSw0LjYxNTM4NDYyIEw2Mi40OTQ3MDM1LDQuOTIxMTUzODUgTDY1Ljk1MTYyNjYsOC44MjgwNzY5MiBMNjQuODU2NjI2NiwxMy44NDYxNTM4IEw2OS40MDczOTU4LDExLjA3NTc2OTIgTDc0LjAzMzE2NSwxMy44NDYxNTM4IEw3Mi44NjMxNjUsOC44MjgwNzY5MiBMNzYuMzQwODU3Myw0Ljg0OTYxNTM4IEw3MS43MjY2MjY2LDQuNjE1Mzg0NjIgTDY5LjQzNjI0MTksMCIgaWQ9IkRlc2t0b3AtLy1JY29uLS8tU3Rhci0vLVN0YXItYWN0aXZlLTYtQ29weSI+PC9wYXRoPiAgICAgICAgICAgICAgICAgICAgICAgIDwvZz4gICAgICAgICAgICAgICAgICAgIDwvZz4gICAgICAgICAgICAgICAgPC9nPiAgICAgICAgICAgIDwvZz4gICAgICAgIDwvZz4gICAgPC9nPjwvc3ZnPg==");
    }

    #{coloredSelector 'orange', '.sa-actual-star-rating'} {
      background-image: url("data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+Cjxzdmcgd2lkdGg9IjEzcHgiIGhlaWdodD0iMTNweCIgdmlld0JveD0iMCAwIDEzIDEzIiB2ZXJzaW9uPSIxLjEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHhtbG5zOnNrZXRjaD0iaHR0cDovL3d3dy5ib2hlbWlhbmNvZGluZy5jb20vc2tldGNoL25zIj4KICAgIDwhLS0gR2VuZXJhdG9yOiBTa2V0Y2ggMy4zICgxMTk3MCkgLSBodHRwOi8vd3d3LmJvaGVtaWFuY29kaW5nLmNvbS9za2V0Y2ggLS0+CiAgICA8dGl0bGU+U2hhcGU8L3RpdGxlPgogICAgPGRlc2M+Q3JlYXRlZCB3aXRoIFNrZXRjaC48L2Rlc2M+CiAgICA8ZGVmcz48L2RlZnM+CiAgICA8ZyBpZD0iUGFnZS0xIiBzdHJva2U9Im5vbmUiIHN0cm9rZS13aWR0aD0iMSIgZmlsbD0ibm9uZSIgZmlsbC1ydWxlPSJldmVub2RkIiBza2V0Y2g6dHlwZT0iTVNQYWdlIj4KICAgICAgICA8ZyBpZD0ib3JhbmdlLXN0YXIiIHNrZXRjaDp0eXBlPSJNU0xheWVyR3JvdXAiIGZpbGw9IiNGRkYiPgogICAgICAgICAgICA8ZyBpZD0iUGFnZS0xIiBza2V0Y2g6dHlwZT0iTVNTaGFwZUdyb3VwIj4KICAgICAgICAgICAgICAgIDxnIGlkPSJzdGFyX2JpZyI+CiAgICAgICAgICAgICAgICAgICAgPHBhdGggZD0iTTYuNSwwLjQgTDguNSw0LjQgTDEyLjUsNC42IEw5LjUsOCBMMTAuNSwxMi4zIEw2LjUsOS45IEwyLjYsMTIuMyBMMy41LDggTDAuNSw0LjYgTDQuNSw0LjMgTDYuNSwwLjQiIGlkPSJTaGFwZSI+PC9wYXRoPgogICAgICAgICAgICAgICAgPC9nPgogICAgICAgICAgICA8L2c+CiAgICAgICAgPC9nPgogICAgPC9nPgo8L3N2Zz4=");
    }

    #{coloredSelector 'black'} {
      background: #363636;
    }

    #{coloredSelector 'black', '.sa-rating-with-count'} {
      border-bottom: 1px solid #505050;
    }

    #{coloredSelector 'black', '.sa-rating-value'},
    #{coloredSelector 'black', '.sa-reviews-count-compact'},
    #{coloredSelector 'black', '.sa-reviews-count-texty'},
    #{coloredSelector 'black', '.sa-brand-powered-by'} {
      color: #fff;
      -webkit-text-fill-color: currentColor;
    }

    #{coloredSelector 'black', '.sa-rating-with-count::after'} {
      color: #797979;
      -webkit-text-fill-color: currentColor;
    }

    #{coloredSelector 'black', '.sa-star-rating-wrapper'} {
      background-image: url("data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+PHN2ZyB3aWR0aD0iMTRweCIgaGVpZ2h0PSIxNHB4IiB2aWV3Qm94PSIwIDAgMTQgMTQiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+ICAgICAgICA8dGl0bGU+RGVza3RvcCAvIEljb24gLyBTdGFyIC8gU3RhciBhY3RpdmUgNiBDb3B5PC90aXRsZT4gICAgPGRlc2M+Q3JlYXRlZCB3aXRoIFNrZXRjaC48L2Rlc2M+ICAgIDxkZWZzPjwvZGVmcz4gICAgPGcgaWQ9IlNrdS1Qcm9kdWN0LUluZm8iIHN0cm9rZT0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIxIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPiAgICAgICAgPGcgaWQ9IjE1MDBweC0vLVNrdS0vLUxheW91dC0vLc6azrnOvc63z4TOsS3OpM63zrvOtc+Gz4nOvc6xLUNvcHktMyIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoLTUxNi4wMDAwMDAsIC0yMTkuMDAwMDAwKSIgZmlsbD0iIzc3Nzc3NyI+ICAgICAgICAgICAgPGcgaWQ9IlByb2R1Y3QtSW5mby1Db3B5LTUiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDQxMi41MDAwMDAsIDE3NC4wMDAwMDApIj4gICAgICAgICAgICAgICAgPGcgaWQ9IkxpbmtzIiB0cmFuc2Zvcm09InRyYW5zbGF0ZSgwLjUwMDAwMCwgMzguNTAwMDAwKSI+ICAgICAgICAgICAgICAgICAgICA8ZyBpZD0iUmF0aW5nLUNvcHkiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDAuNTAwMDAwLCAxLjUwMDAwMCkiPiAgICAgICAgICAgICAgICAgICAgICAgIDxnIGlkPSJSYXRpbmctYmlnLUNvcHkiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDQwLjAwMDAwMCwgNS4wMDAwMDApIj4gICAgICAgICAgICAgICAgICAgICAgICAgICAgPHBhdGggZD0iTTY5LjQzNjI0MTksMCBMNjcuMTEwMDg4MSw0LjYxNTM4NDYyIEw2Mi40OTQ3MDM1LDQuOTIxMTUzODUgTDY1Ljk1MTYyNjYsOC44MjgwNzY5MiBMNjQuODU2NjI2NiwxMy44NDYxNTM4IEw2OS40MDczOTU4LDExLjA3NTc2OTIgTDc0LjAzMzE2NSwxMy44NDYxNTM4IEw3Mi44NjMxNjUsOC44MjgwNzY5MiBMNzYuMzQwODU3Myw0Ljg0OTYxNTM4IEw3MS43MjY2MjY2LDQuNjE1Mzg0NjIgTDY5LjQzNjI0MTksMCIgaWQ9IkRlc2t0b3AtLy1JY29uLS8tU3Rhci0vLVN0YXItYWN0aXZlLTYtQ29weSI+PC9wYXRoPiAgICAgICAgICAgICAgICAgICAgICAgIDwvZz4gICAgICAgICAgICAgICAgICAgIDwvZz4gICAgICAgICAgICAgICAgPC9nPiAgICAgICAgICAgIDwvZz4gICAgICAgIDwvZz4gICAgPC9nPjwvc3ZnPg==");
    }

    #{coloredSelector 'black', '.sa-brand-logo'},
    #{coloredSelector 'orange', '.sa-brand-logo'} {
      background-image: url('#{asset_url("logo_#{flavor}_white.png")}');
    }

    #{sizedSelector 'medium'} {
      flex-direction: row;
      -ms-flex-direction: row;
      width: 260px;
      align-items: center;
      -ms-flex-align: center;
    }

    #{sizedSelector 'medium', '.sa-rating-value'} {
      font-size: 17px;
    }

    #{sizedSelector 'medium', '.sa-reviews-count-compact'} {
      display: none;
    }

    #{sizedSelector 'medium', '.sa-reviews-count-texty'} {
      display: inline-block;
    }

    #{sizedSelector 'medium', '.sa-rating-with-count::after'} {
      content: "";
      display: none;
    }

    #{sizedSelector 'medium', '.sa-rating-with-count'} {
      width: 70px;
      height: 100%;
      flex-direction: column;
      -ms-flex-direction: column;
      align-items: center;
      -ms-flex-align: center;
      justify-content: center;
      -ms-flex-pack: center;
      padding-left: 0;
    }

    #{sizedSelector 'medium', '.sa-star-rating-wrapper'} {
      width: 55px;
      height: 11px;
    }

    #{sizedSelector 'medium', '.sa-star-rating'} {
      margin-right: 0;
    }

    #{sizedSelector 'medium', '.sa-rating-value'} {
      margin-right: 0;
    }

    #{sizedSelector 'medium', '.sa-inline-separator'} {
      width: 2px;
      height: 80%;
    }

    #{sizedSelector 'medium', '.sa-inline-secondary-indicators'} {
      display: flex;
      display: -ms-flexbox;
      flex-direction: column;
      -ms-flex-direction: column;
      flex: 1 1 auto;
      -ms-flex: 1 1 auto;
      height: 100%;
      justify-content: center;
      -ms-flex-pack: center;
      align-items: center;
      -ms-flex-align: center;
    }

    #{sizedSelector 'medium', '.sa-reviews-count-texty'} {
      font-size: 13px;
      margin-bottom: 5px;
      text-decoration: underline;
      text-decoration-style: dotted;
    }

    #{sizedSelector 'medium', '.sa-brand'} {
      height: auto;
    }

    /* EXTENDED */

    ##{flavor}-product-reviews-extended.sa-reviews-extended-root {
      all: initial;
      display: block;
      border: 1px solid #e8e8e8;
      border-radius: 2px;
      background: #f1f1f1;
    }

    ##{flavor}-product-reviews-extended .sa-extended-reviews-header {
      display: flex;
      display: -ms-flexbox;
      justify-content: space-between;
      -ms-flex-pack: justify;
      align-items: center;
      -ms-flex-align: center;
      padding: 15px;
      border-bottom: 1px solid #e3e3e3;
    }

    ##{flavor}-product-reviews-extended .sa-extended-reviews-title {
      display: inline-block;
      font-size: 17px;
    }

    ##{flavor}-product-reviews-extended .sa-extended-reviews-title::first-letter {
      text-transform: uppercase;
    }

    ##{flavor}-product-reviews-extended .sa-brand-logo {
      height: 22px;
      width: 80px;
    }

    ##{flavor}-product-reviews-extended .sa-brand-powered-by {
      display: inline-block;
      font-size: 15px;
    }

    ##{flavor}-product-reviews-extended .sa-extended-reviews-body {
      display: block;
      padding: 0 15px 20px;
     }

    ##{flavor}-product-reviews-extended .sa-sku-title {
      display: block;
      font-size: 16px;
      margin: 1.2em 0;
    }

    ##{flavor}-product-reviews-extended .sa-sku-details {
      display: block;
      margin-bottom: 25px;
    }

    ##{flavor}-product-reviews-extended .sa-sku-details > * {
      display: inline-block;
      vertical-align: middle;
    }

    ##{flavor}-product-reviews-extended .sa-rating-full {
      margin: 0 30px 20px 10px;
      font-size: 0;
    }

    ##{flavor}-product-reviews-extended .sa-star-rating {
      display: inline-block;
      vertical-align: middle;
      margin-right: 7px;
    }

    ##{flavor}-product-reviews-extended .sa-star-rating-wrapper {
      width: 100px;
      height: 20px;
    }

    ##{flavor}-product-reviews-extended .sa-rating-value {
      display: block;
      text-align: center;
      font-size: 25px;
      font-weight: bold;
      margin-bottom: 0.2em;
    }

    ##{flavor}-product-reviews-extended .sa-reviews-count-compact {
      display: inline-block;
      vertical-align: middle;
      font-size: 14px;
      cursor: pointer;
    }

    ##{flavor}-product-reviews-extended .sa-rating-breakdown-wrap {
      display: inline-block;
      vertical-align: middle;
      position: relative;
    }

    ##{flavor}-product-reviews-extended .sa-rating-arrow {
      padding-left: 4px;
      display: inline-block;
      cursor: pointer;
    }

    ##{flavor}-product-reviews-extended .sa-rating-arrow::after {
      content: "∟";
      transform: translateY(-20%) rotate(-45deg);
      display: inline-block;
      vertical-align: super;
      font-size: 14px;
    }

    ##{flavor}-product-reviews-extended .sa-rating-breakdown {
      display: none;
      position: absolute;
      width: 250px;
      padding: 20px 0 20px 30px;
      top: 30px;
      left: 0;
      margin-left: -20px;
      background: #fff;
      box-shadow: 0 0 10px rgba(0, 0, 0, 0.2);
      border-radius: 2px;
      z-index: 110;
      transform: translateX(-50%);
      font-size: 12px;
      color: #707070;
      -webkit-text-fill-color: currentColor;
      box-sizing: border-box;
    }

    ##{flavor}-product-reviews-extended .sa-rating-breakdown:before { /* Used to create an arrow for the breakdown popup */
      content: "";
      position: absolute;
      border: 10px solid transparent;
      left: 50%;
      top: -20px;
      border-bottom-color: #dcdcdc;
      z-index: -1;
      margin-left: 10px;
    }

    ##{flavor}-product-reviews-extended .sa-rating-breakdown:after { /* Used to create an arrow for the breakdown popup */
      content: "";
      position: absolute;
      border: 10px solid transparent;
      left: 50%;
      top: -19px;
      border-bottom-color: #fff;
      margin-left: 10px;
    }

    ##{flavor}-product-reviews-extended .sa-rating-breakdown-class {
      display: list-item;
      list-style-type: none;
      margin: 0 0 4px 0;
    }

    ##{flavor}-product-reviews-extended .sa-num-stars {
      display: inline-block;
      width: 55px;
      margin: 0 10px 0 0;
      font-size: 12px;
      vertical-align: middle;
      white-space: nowrap;
    }

    ##{flavor}-product-reviews-extended .sa-rating-bar-wrap {
      display: inline-block;
      height: 4px;
      width: 100px;
      vertical-align: middle;
      overflow: hidden;
      margin: 0;
      border-radius: 1px;
      background: #dcdcdc;
      cursor: default;
      pointer-events: none;
     }

    ##{flavor}-product-reviews-extended .sa-rating-bar {
      display: block;
      height: 100%;
      background: #f68b24;
    }

    ##{flavor}-product-reviews-extended .sa-rating-count {
      display: inline-block;
      width: 30px;
      vertical-align: baseline;
      margin-left: 4px;
      font-size: 12px;
    }

    ##{flavor}-product-reviews-extended .sa-reviews-aggregation-feature {
      display: list-item;
      list-style-type: none;
    }

    ##{flavor}-product-reviews-extended .sa-reviews-aggregation-feature {
      display: flex;
      display: -ms-flexbox;
      justify-content: space-between;
      -ms-flex-pack: justify;
      align-items: center;
      -ms-flex-align: center;
      margin-bottom: 6px;
    }

    ##{flavor}-product-reviews-extended .sa-reviews-aggregation-feature {
      width: 255px;
      display: flex;
      display: -ms-flexbox;
      justify-content: space-between;
      -ms-flex-pack: justify;
      align-items: center;
      -ms-flex-align: center;
      margin-bottom: 6px;
    }

    ##{flavor}-product-reviews-extended .sa-reviews-aggregation-label {
      max-width: 200px;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
      display: inline-block;
      height: 14px;
      padding-right: 2px;
      font-size: 12px;
      color: #707070;
      -webkit-text-fill-color: currentColor;
    }

    ##{flavor}-product-reviews-extended .sa-reviews-aggregation-bar-wrap {
      position: relative;
      width: 100px;
      height: 4px;
      background: #dcdcdc;
      flex-shrink: 0;
    }

    ##{flavor}-product-reviews-extended .sa-reviews-aggregation-bar-wrap:before {
      content: "";
      display: block;
      position: absolute;
      top: 0;
      left: 0;
      width: 101px;
      height: 4px;
      z-index: 2;
      background-color: rgba(#fff, .1);
      background-image: repeating-linear-gradient(to right, rgba(255,255,255,0) 0%, rgba(255,255,255,0) 18%, #fff 18%, #f1f1f1 20%, rgba(241,241,241,0) 20%);
    }

    ##{flavor}-product-reviews-extended .sa-reviews-aggregation-bar {
      position: absolute;
      left: 0;
      top: 0;
      height: 100%;
    }

    ##{flavor}-product-reviews-extended .sa-reviews-aggregation-bar.sa-good {
      background: #32992c;
    }

    ##{flavor}-product-reviews-extended .sa-reviews-aggregation-bar.sa-so-so {
      background: #f68b24;
    }

    ##{flavor}-product-reviews-extended .sa-reviews-aggregation-bar.sa-bad {
      background: #dd422d;
    }

    ##{flavor}-product-reviews-extended .sa-sales-wrap {
      width: 100%;
      font-size: 12px;
      color: #3b3b3b;
      -webkit-text-fill-color: currentColor;
      margin-top: 25px;
    }

    ##{flavor}-product-reviews-extended .sa-sales-wrap:before {
      content: "";
      display: inline-block;
      vertical-align: middle;
      margin-bottom: 2px;
      width: 1.2em;
      height: 1.2em;
      background-image: url("data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA4MCA4MCI+PHBhdGggZD0iTTY0IDIyLjRoLTUuOXYtM0M1OC4xIDEyIDUxLjggNiA0NCA2Yy0xLjcgMC0zLjMuMy00LjguOC0xLjUtLjUtMy4yLS44LTQuOC0uOC03LjggMC0xNC4yIDYtMTQuMiAxMy40djNoLTUuN2MtMy4zIDAtNS45IDIuNy01LjkgNS45djQxLjNjMCAzLjMgMi43IDUuOSA1LjkgNS45SDY0YzMuMyAwIDUuOS0yLjcgNS45LTUuOVYyOC4zYy4xLTMuMi0yLjYtNS45LTUuOS01Ljl6bS0xMC43LTN2M2gtNC44di0zYzAtMy4yLTEuMi02LjItMy4yLTguNSA0LjUuNiA4IDQuMiA4IDguNXptLTE4LjcgMGMwLTMuMSAxLjgtNS45IDQuNi03LjQgMi43IDEuNSA0LjYgNC4yIDQuNiA3LjR2M2gtOS4xbC0uMS0zem0tOS42IDBjMC00LjMgMy41LTcuOSA4LTguNS0yIDIuMy0zLjIgNS4zLTMuMiA4LjV2M0gyNXYtM3pNMTMuMyA2OS42VjI4LjNjMC0uNi41LTEuMSAxLjEtMS4xaDYuM3YyLjljMCAxIC44IDEuOCAxLjggMS44czEuOC0uOCAxLjgtMS44di0yLjlINDR2Mi45YzAgMSAuOCAxLjggMS44IDEuOHMxLjgtLjggMS44LTEuOHYtMi45SDU2djQzLjVIMTQuNWMtLjcgMC0xLjItLjUtMS4yLTEuMXptNTEuOSAwYzAgLjYtLjUgMS4xLTEuMSAxLjFoLTQuMlYyNy4ySDY0Yy42IDAgMS4xLjUgMS4xIDEuMWwuMSA0MS4zeiIvPjwvc3ZnPg==");
    }

    ##{flavor}-product-reviews-extended .sa-sales-text {
      display: inline;
      vertical-align: middle;
    }

    ##{flavor}-product-reviews-extended .sa-reviews-list {
      list-style: none;
      padding-left: 0;
    }

    ##{flavor}-product-reviews-extended .sa-review {
      display: block;
      background: #fff;
      border: 1px solid #e8e8e8;
      border-radius: 2px;
      margin: 0 0 10px;
      padding: 15px;
    }

    ##{flavor}-product-reviews-extended .sa-review-avatar {
      float: left;
      overflow: hidden;
      width: 40px;
      height: 40px;
      margin: 0 10px 0 0;
      border: 1px solid #e8e8e8;
      border-radius: 50%;
    }

    ##{flavor}-product-reviews-extended .sa-review-info {
      display: block;
      margin: 2px 0;
    }

    ##{flavor}-product-reviews-extended .sa-review-info > *,
    ##{flavor}-product-reviews-extended .sa-authorship-info > * {
      display: inline;
      vertical-align: middle;
    }

    ##{flavor}-product-reviews-extended .sa-review .sa-star-rating-wrapper {
      width: 70px;
      height: 14px;
    }

    ##{flavor}-product-reviews-extended .sa-review-usefull-voting {
      margin: 3px 0 6px;
      font-size: 11px;
      color: #707070;
      -webkit-text-fill-color: currentColor;
    }

    ##{flavor}-product-reviews-extended .sa-authorship-info {
      display: block;
      font-size: 11px;
      color: #707070;
      -webkit-text-fill-color: currentColor;
    }

    ##{flavor}-product-reviews-extended .sa-review-author {
      max-width: 60%;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
      font-size: 12px;
      height: 14px;
      color: #363636;
      -webkit-text-fill-color: currentColor;
    }

    ##{flavor}-product-reviews-extended .sa-review-text {
      display: block;
      max-width: 60em;
      margin: 20px 0 10px;
      word-wrap: break-all;
      word-wrap: break-word;
      white-space: pre-wrap;
      font-size: 12px;
      text-align: justify;
      line-height: 1.6;
      color: #000;
      -webkit-text-fill-color: currentColor;
    }

    ##{flavor}-product-reviews-extended .sa-expandable .sa-review-text {
      position: relative;
      overflow: hidden;
      max-height: 100px;
      margin-bottom: 0;
    }

    ##{flavor}-product-reviews-extended .sa-expandable .sa-review-text:after {
       content: " ";
       position: absolute;
       right: 0;
       bottom: 0;
       left: 0;
       height: 50px;
       background: -webkit-gradient(linear, left top, left bottom, from(rgba(255,255,255,0)), color-stop(50%, rgba(255,255,255,0.4)), color-stop(90%, #fff));
       background: -webkit-linear-gradient(top, rgba(255,255,255,0) 0%, rgba(255,255,255,0.4) 50%, #fff 90%);
       background: linear-gradient(to bottom, rgba(255,255,255,0) 0%, rgba(255,255,255,0.4) 50%, #fff 90%);
       background-repeat: repeat;
       background-position-x: 0%;
       background-position-y: 0%;
       background-position: 0 100%;
       background-repeat: repeat-x;
     }

    ##{flavor}-product-reviews-extended .sa-review-expand {
      display: none;
    }

    ##{flavor}-product-reviews-extended .sa-expandable .sa-review-expand {
      display: inline-block;
      padding: 10px 0 5px;
      font-size: 12px;
      text-align: center;
      color: #1c7ece;
      -webkit-text-fill-color: currentColor;
      cursor: pointer;
    }

    ##{flavor}-product-reviews-extended .sa-review-sentiments {
      display: block;
      margin: 10px 0 0;
    }

    ##{flavor}-product-reviews-extended .sa-review-sentiment {
      display: block;
      position: relative;
      padding: 0 0 1px;
    }

    ##{flavor}-product-reviews-extended .sa-review-sentiment:before {
      content: "";
      display: inline-block;
      width: 21px;
      height: 21px;
      margin-right: 4.2px;
      vertical-align: middle;
    }

    ##{flavor}-product-reviews-extended .sa-review-sentiment.sa-positive:before {
      background-image: url("data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA4MCA4MCI+PGcgZmlsbD0iIzMyOTkyYyI+PGVsbGlwc2UgY3g9IjI2LjQiIGN5PSIzNC43IiByeD0iNCIgcnk9IjQiLz48ZWxsaXBzZSBjeD0iNTQuMyIgY3k9IjM0LjciIHJ4PSI0IiByeT0iNCIvPjxwYXRoIGQ9Ik00MC4xIDUuOWMtMTguNyAwLTM0IDE1LjItMzQgMzQgMCAxOC43IDE1LjIgMzQgMzQgMzRzMzQtMTUuMiAzNC0zNC0xNS4zLTM0LTM0LTM0em0wIDYxLjVjLTE1LjIgMC0yNy41LTEyLjMtMjcuNS0yNy41czEyLjMtMjcuNSAyNy41LTI3LjUgMjcuNSAxMi4zIDI3LjUgMjcuNWMwIDE1LjEtMTIuNCAyNy41LTI3LjUgMjcuNXoiLz48cGF0aCBkPSJNNDguOCA0NC41Yy03LjYgNi4zLTE1LjIgMS4xLTE1LjYuOS0xLjEtLjgtMi42LS41LTMuNC42LS44IDEuMS0uNSAyLjYuNiAzLjQgMi4xIDEuNSA1LjggMy4xIDEwLjIgMy4xIDMuNiAwIDcuNS0xLjEgMTEuMy00LjIgMS0uOSAxLjItMi40LjMtMy40LS45LTEuMi0yLjQtMS4zLTMuNC0uNHoiLz48L2c+PC9zdmc+");
    }

    ##{flavor}-product-reviews-extended .sa-review-sentiment.sa-mediocre:before {
      background-image: url("data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA4MCA4MCI+PGcgZmlsbD0iI2VmYTcwNiI+PGNpcmNsZSBjeD0iMjYuNCIgY3k9IjM0LjciIHI9IjQiLz48Y2lyY2xlIGN4PSI1NC4zIiBjeT0iMzQuNyIgcj0iNCIvPjxwYXRoIGQ9Ik00MC4xIDUuOWMtMTguNyAwLTM0IDE1LjItMzQgMzQgMCAxOC43IDE1LjIgMzQgMzQgMzRzMzQtMTUuMiAzNC0zNC0xNS4zLTM0LTM0LTM0em0wIDYxLjVjLTE1LjIgMC0yNy41LTEyLjMtMjcuNS0yNy41czEyLjMtMjcuNSAyNy41LTI3LjUgMjcuNSAxMi4zIDI3LjUgMjcuNWMwIDE1LjEtMTIuNCAyNy41LTI3LjUgMjcuNXoiLz48cGF0aCBkPSJNNDUuNCA0Ni40SDM1LjJjLTMuMiAwLTMuMiA1IDAgNWgxMC4yYzMuMiAwIDMuMi01IDAtNXoiLz48L2c+PC9zdmc+");
    }

    ##{flavor}-product-reviews-extended .sa-review-sentiment.sa-negative:before {
      background-image: url("data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA4MCA4MCI+PGcgZmlsbD0iI2U1M2MzYyI+PGNpcmNsZSBjeD0iMjYuNCIgY3k9IjM0LjciIHI9IjQiLz48Y2lyY2xlIGN4PSI1NC4zIiBjeT0iMzQuNyIgcj0iNCIvPjxwYXRoIGQ9Ik00MC4xIDUuOWMtMTguNyAwLTM0IDE1LjItMzQgMzQgMCAxOC43IDE1LjIgMzQgMzQgMzRzMzQtMTUuMiAzNC0zNC0xNS4zLTM0LTM0LTM0em0wIDYxLjVjLTE1LjIgMC0yNy41LTEyLjMtMjcuNS0yNy41czEyLjMtMjcuNSAyNy41LTI3LjUgMjcuNSAxMi4zIDI3LjUgMjcuNWMwIDE1LjEtMTIuNCAyNy41LTI3LjUgMjcuNXoiLz48cGF0aCBkPSJNNDUuNCA0Ni40SDM1LjJjLTMuMiAwLTMuMiA1IDAgNWgxMC4yYzMuMiAwIDMuMi01IDAtNXoiLz48L2c+PC9zdmc+");
    }

    ##{flavor}-product-reviews-extended .sa-review-feature-sentiment {
      display: inline-block;
      vertical-align: middle;
      font-size: 12px;
      line-height: 20px;
      color: #000;
      -webkit-text-fill-color: currentColor;
    }

    ##{flavor}-product-reviews-extended .sa-review-feature-sentiment:after {
      content: ", ";
      display: inline-block;
      margin-right: 3px;
    }

    ##{flavor}-product-reviews-extended .sa-review-feature-sentiment:last-of-type:after {
      display: none;
    }

    ##{flavor}-product-reviews-extended .sa-show-review-modal {
      background: #FFF;
      display: block;
      color: #707070;
      -webkit-text-fill-color: currentColor;
      border: 1px solid #e8e8e8;
      padding: 12px;
      text-align: center;
      font-size: 12px;
      transition: background 0.2s linear;
      cursor: pointer;
    }

    ##{flavor}-product-reviews-extended .sa-show-review-modal:hover {
      background: #e8e8e8;
      transition: background 0.2s linear;
    }

    ##{flavor}-product-reviews-extended .sa-show-review-modal:first-letter {
      text-transform: uppercase;
    }

    ##{flavor}-product-reviews-extended.sa-white.sa-reviews-extended-root {
      background: #fff;
    }

    ##{flavor}-product-reviews-extended.sa-white .sa-show-review-modal {
      background: #f8f8f8;
    }

    ##{flavor}-product-reviews-extended.sa-white .sa-show-review-modal:hover {
      background: #e8e8e8;
    }

    /* EXTENDED - NO CONTENT */

    ##{flavor}-product-reviews-extended .sa-review-prompt {
      padding: 30px;
      display: block;
    }

    ##{flavor}-product-reviews-extended .sa-review-prompt-head {
      display: block;
      margin: 0 0 10px;
      font-weight: bold;
      font-size: 16px;
      color: #000;
      -webkit-text-fill-color: currentColor;
      line-height: 1.25;
    }

    ##{flavor}-product-reviews-extended .sa-review-prompt-motive {
      margin: 0 0 20px;
      font-size: 12px;
      color: #000;
      -webkit-text-fill-color: currentColor;
      line-height: 1.5;
      display: block;
    }

    ##{flavor}-product-reviews-extended .sa-review-prompt-button {
      display: inline-block;
      padding: 10px 25px 12px;
      outline: none;
      border: 0;
      border-radius: 3px;
      font-size: 12px;
      text-align: center;
      -webkit-tap-highlight-color: transparent;
      background: #f68b24;
      color: #fff;
      -webkit-text-fill-color: currentColor;
      cursor: pointer;
    }

    ##{flavor}-product-reviews-extended .sa-review-prompt-button:hover {
      background: #e8760a;
    }

    /* MODAL */

    #sa-reviews-modal {
      position: fixed;
      top: 0;
      right: 0;
      bottom: 0;
      left: 0;
      z-index: 2147483647;
      padding: 50px 0;
      background: rgba(0, 0, 0, .5);
    }

    #sa-reviews-modal #sa-reviews-modal-inner {
      position: relative;
      width: 85%;
      height: 100%;
      max-width: 950px;
      margin: 0 auto;
      background-color: #f1f1f1;
    }

    #sa-reviews-modal #sa-reviews-modal-iframe-container {
      position: relative;
      padding: 0;
      width: 100%;
      height: 100%;
      z-index: 2;
      -webkit-overflow-scrolling: touch;
      overflow-x: hidden;
      overflow-y: auto;
    }

    @keyframes sa-reviews-spin {
      from { transform:rotate(0deg); }
      to   { transform:rotate(360deg); }
    }

    #sa-reviews-modal #sa-reviews-modal-inner.sa-reviews-spinner::before {
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
      animation: sa-reviews-spin 1s linear infinite;
      -webkit-animation: sa-reviews-spin 1s linear infinite;
      z-index: 1;
    }

    #sa-reviews-modal #sa-reviews-modal-iframe {
      position: relative;
      z-index: 3;

      display: block;
      visibility: visible;

      width: 100%;
      height: 100%;
      margin: 0;

      opacity: 1;
    }

    #sa-reviews-modal #sa-reviews-modal-close-button {
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
      #sa-reviews-modal #sa-reviews-modal-inner {
        width: 90%;
      }

      #sa-reviews-modal #sa-reviews-modal-inner #sa-reviews-modal-close-button {
        right: 0px;
      }
    }

    @media only screen and (-webkit-min-device-pixel-ratio: 2),
         only screen and (min--moz-device-pixel-ratio: 2),
         only screen and (  -o-min-device-pixel-ratio: 2/1),
         only screen and (     min-device-pixel-ratio: 2),
         only screen and (     min-resolution: 192dpi),
         only screen and (     min-resolution: 2dppx) {
      #sa-reviews-modal #sa-reviews-modal-close-button {
        background-image: url('#{asset_url("badge/close@2x.png")}');
      }
    }
  """

new PartnerSkuReviews
