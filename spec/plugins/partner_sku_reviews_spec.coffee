describe 'PartnerSkuReviews', ->
  parent_doc = window.parent.document

  PRODUCT_REVIEWS = {
    'displayable_reviews_id': {
      "sku_id": 14920478,
      "title": "Product Name",
      "reviewscore": 4.7082,
      "reviews_count": 1220,
      "reviewable": true,
      "sales": "905 purchases in the last 3 months by Skroutz users",
      "rating_breakdown": [
        {
          "star": 5,
          "percentage": 80,
          "count": 976
        },
        {
          "star": 4,
          "percentage": 15,
          "count": 179
        },
        {
          "star": 3,
          "percentage": 3,
          "count": 37
        },
        {
          "star": 2,
          "percentage": 1,
          "count": 9
        },
        {
          "star": 1,
          "percentage": 2,
          "count": 19
        }
      ],
      "reviews_aggregation": [
        {
          "label": "Ποιότητα κλήσης",
          "score": 100,
          "style": "good"
        },
        {
          "label": "Ταχύτητα",
          "score": 100,
          "style": "good"
        },
        {
          "label": "Ποιότητα καφέ",
          "score": 50,
          "style": "so-so"
        },
        {
          "label": "Σφουγγάρισμα",
          "score": 20,
          "style": "bad"
        }
      ],
      "reviews": [
        {
          "review": "Κάτοχος του κινητού γύρω στον 1 μήνα , ",
          "merged_review_notice_html": '<div class="merged-review-info">Η αξιολόγηση αφορά <span>μνήμη:</span> 64 GB, <span>ram:</span> 4 GB</div>',
          "rating": 5,
          "created_at": "01/07/2018",
          "votes_count": 110,
          "helpful_votes_count": 108,
          "user": {
            "username": "username",
            "avatar": "http://localhost:9000/avatar.jpeg"
          },
          "sentiments": {
            "positive": [
              "Ποιότητα κλήσης",
              "Φωτογραφίες",
              "Καταγραφή Video"
            ],
            "mediocre": [
              "GPS"
            ],
            "negative": [
              "Ποιότητα καφέ"
            ]
          }
        },
        {
          "review": "Μετά από άλλες 20 ημέρες χρήσης να προσθέσω και τα παρακάτω:",
          "merged_review_notice_html": '',
          "rating": 5,
          "created_at": "21/05/2018",
          "votes_count": 202,
          "helpful_votes_count": 196,
          "user": {
            "username": "username",
            "avatar": "http://localhost:9000/avatar.jpeg"
          },
          "sentiments": {
            "positive": [
              "Ποιότητα κλήσης",
              "Φωτογραφίες",
              "Καταγραφή Video"
            ]
          }
        },
        {
          "review": "Καποιος μας κανει πλακα...α δεν ειναι ενας ειναι πολλοι.    Αν το φοβαστε σαν εταιρια δωστε 400-600 ευρω σε αλλη μαρκα να νοιωσετε \"σιγουρια\".  Το παιρνεις 160-170 ευρω ,βαζεις και το MUIU 10 που βγηκε και επισημα και εχεις ενα Αι-Phone των 500++ ευρω. Το συστηνεις ανετα,δεν εχει περιττα προγραμαμτα μεσα με το ετσι θελω ,δεν κολλαει ,4g γρηγορο wifi διπλες αποστασεις ,δεν το λυπασαι,δεν μασαει, τρεχει ,τρεχει, αναβαθμηζεται,ομορφο,ωραια ξεκουραστη και αταραχη οθονη,καμερα ανωτερη απο πολλα σε βραδυ .\r\nΤο μεγαλο μειονεκτημα του ειναι η τιμη , που οταν την αναφερεις θα κλαις τα χρηματα που εδωσες σε παλιοτερα κινητα.",
          "merged_review_notice_html": '',
          "rating": 5,
          "created_at": "08/08/2018",
          "votes_count": 91,
          "helpful_votes_count": 88,
          "user": {
            "username": "username",
            "avatar": "http://localhost:9000/avatar.jpeg"
          },
          "sentiments": {
            "positive": [
              "Ποιότητα κλήσης",
              "Φωτογραφίες",
              "Καταγραφή Video"
            ]
          }
        },
        {
          "review": "Πριν ξεκινήσω να καταγράψω",
          "merged_review_notice_html": '',
          "rating": 5,
          "created_at": "11/08/2018",
          "votes_count": 76,
          "helpful_votes_count": 74,
          "user": {
            "username": "username",
            "avatar": "http://localhost:9000/avatar.jpeg"
          },
          "sentiments": {
            "positive": [
              "Ποιότητα κλήσης",
              "Φωτογραφίες",
              "Καταγραφή Video"
            ]
          }
        },
        {
          "review": "Μετά από χρήση μίας εβδομάδας (4gb/64gb)",
          "merged_review_notice_html": '',
          "rating": 5,
          "created_at": "29/05/2018",
          "votes_count": 55,
          "helpful_votes_count": 53,
          "user": {
            "username": "username",
            "avatar": "http://localhost:9000/avatar.jpeg"
          },
          "sentiments": {}
        }
      ]
    },
    'no_ratings_id': {
      "sku_id": 14920479,
      "title": "Product Name",
      "reviewscore": 0,
      "reviews_count": 0,
      "reviewable": true,
      "sales": "905 purchases in the last 3 months by Skroutz users",
      "rating_breakdown": [
        {
          "star": 5,
          "percentage": 0,
          "count": 0
        },
        {
          "star": 4,
          "percentage": 0,
          "count": 0
        },
        {
          "star": 3,
          "percentage": 0,
          "count": 0
        },
        {
          "star": 2,
          "percentage": 0,
          "count": 0
        },
        {
          "star": 1,
          "percentage": 0,
          "count": 0
        }
      ],
      "reviews_aggregation": [],
      "reviews": []
    },
    'non_reviewable_id': {
      "reviewable": false,
    },
  }
  PRODUCT_REVIEWS['no_displayable_reviews_id'] = JSON.parse(JSON.stringify(PRODUCT_REVIEWS['displayable_reviews_id']))
  PRODUCT_REVIEWS['no_displayable_reviews_id'].reviews = []
  PRODUCT_REVIEWS['no_displayable_reviews_id'].reviews_aggregation = []
  PRODUCT_REVIEWS['no_aggregation_id'] = JSON.parse(JSON.stringify(PRODUCT_REVIEWS['displayable_reviews_id']))
  PRODUCT_REVIEWS['no_aggregation_id'].reviews_aggregation = []
  PRODUCT_REVIEWS['no_sales_id'] = JSON.parse(JSON.stringify(PRODUCT_REVIEWS['displayable_reviews_id']))
  PRODUCT_REVIEWS['no_sales_id'].sales = null

  event_listener_args = []
  orginalAddEventListener =parent_doc.addEventListener

  removeListeners = ->
    while event_listener_args.length > 0
      args = event_listener_args.pop()
      parent_doc.removeEventListener args.event, args.func

  performTheJSONP = ->
    jsonp_script = parent_doc.getElementById('sa_jsonp_sku_reviews_fetch')
    return unless jsonp_script

    url = jsonp_script.src
    product_id = /&product_id=(.*?)&/.exec(url)[1]
    product_information = JSON.parse(JSON.stringify(PRODUCT_REVIEWS[product_id] || {})) # clone
    callback = /&callback=(.*?)(&|$)/.exec(url)[1]

    # exec JSONP callback
    window.parent[callback](product_information)

  cleanupDom = ->
    removeListeners()

    # Cleanup rendered widgets and stylesheets
    selector = '#sa-partner-sku-reviews-style, #sa-reviews-modal, #\\@\\@flavor-product-reviews-inline, #\\@\\@flavor-product-reviews-extended'
    for e in parent_doc.querySelectorAll(selector)
      e.parentNode.removeChild e

  renderPlugin = (cb) ->
    requirejs.undef 'plugins/partner_sku_reviews'
    require ['plugins/partner_sku_reviews'], ->
      performTheJSONP()
      cb()

  getDefault = (value, defaultValue) ->
    if typeof value == 'undefined' then defaultValue else value

  setSaPlugins = (defaults, { shop_code, extended_widget_enabled, extended_widget_reviews_count,
                              extended_widget_theme, inline_widget_enabled, inline_widget_theme, sku_specs_visible }) ->
    window.sa_plugins =
      partner_sku_reviews:
        shop_code: shop_code || defaults.shop_code
        configuration:
          extended_widget_enabled: getDefault(extended_widget_enabled, defaults.extended_widget_enabled)
          extended_widget_reviews_count: getDefault(extended_widget_reviews_count, defaults.extended_widget_reviews_count)
          extended_widget_theme: getDefault(extended_widget_theme, defaults.extended_widget_theme)
          inline_widget_enabled: getDefault(inline_widget_enabled, defaults.inline_widget_enabled)
          inline_widget_theme: getDefault(inline_widget_theme, defaults.inline_widget_theme)
          sku_specs_visible: getDefault(sku_specs_visible, defaults.sku_specs_visible)
        data: {}

    window.sa_plugins.settings =
      url:
        base: defaults.base
        application_base: defaults.application_base
      plugins:
        partner_sku_reviews:
          url: 'url'

  addProductReviewsElement = (type, product_id) ->
    parent_doc = window.parent.document
    element = window.parent.document.createElement('div')
    element.id = "@@flavor-product-reviews-#{type}"
    element.setAttribute('data-product-id', product_id)
    parent_doc.body.appendChild(element)

  prepare = (widget_types..., product_id, settings, done) ->
    cleanupDom()

    for widget_type in widget_types
      addProductReviewsElement(widget_type, product_id)

    default_settings =
      shop_code: 'SA-XXXX-XXXX'
      extended_widget_enabled: true
      extended_widget_theme: "white"
      inline_widget_enabled: true
      inline_widget_theme: "small-white"
      sku_specs_visible: true
      base: 'http://localhost:9000'
      application_base: 'http://test.skroutz.gr'

    setSaPlugins(default_settings, settings || {})

    renderPlugin done

  before ->
    parent_doc.addEventListener = ->
      event_listener_args.push({ event: arguments[0], func: arguments[1] })

      orginalAddEventListener.apply this, arguments

  after -> window.parent.document.addEventListener = orginalAddEventListener

  afterEach ->
    cleanupDom()

    delete window.sa_plugins

  describe '.constructor', ->
    context 'when an inexistent product_id is detected', ->
      beforeEach (done) ->
        prepare 'inline', 'extended', 'inexistent', {}, done

      it 'does not render the inline widget', ->
        expect(parent_doc.getElementById('@@flavor-product-reviews-inline').innerHTML.trim()).to.be.empty

      it 'does not render the extended widget', ->
        expect(parent_doc.getElementById('@@flavor-product-reviews-extended').innerHTML.trim()).to.be.empty

    context 'when a non-reviewable product_id is detected', ->
      beforeEach (done) ->
        prepare 'inline', 'extended', 'non_reviewable_id', {}, done

      it 'does not render the inline widget', ->
        expect(parent_doc.getElementById('@@flavor-product-reviews-inline').innerHTML.trim()).to.be.empty

      it 'does not render the extended widget', ->
        expect(parent_doc.getElementById('@@flavor-product-reviews-extended').innerHTML.trim()).to.be.empty

    context 'when a reviewable product_id is detected', ->
      beforeEach (done) ->
        prepare 'extended', 'no_ratings_id', {}, done

      it 'adds the plugin style to the head', ->
        expect(parent_doc.getElementById('sa-partner-sku-reviews-style')).to.exist

      context 'and it has ratings', ->
        beforeEach (done) ->
          prepare 'inline', 'extended', 'displayable_reviews_id', {}, done

        context 'and it has displayable reviews', ->
          context 'and inline widget is disabled', ->
            beforeEach (done) ->
              prepare 'inline', 'extended', 'displayable_reviews_id', { inline_widget_enabled: false }, done

            it 'does not render the inline widget', ->
              expect(parent_doc.getElementById('@@flavor-product-reviews-inline').innerHTML.trim()).to.be.empty

          context 'and inline widget is enabled', ->
            it 'renders the inline widget', ->
              expect(parent_doc.getElementById('@@flavor-product-reviews-inline').innerHTML.trim()).to.not.be.empty

        context 'and it doesn\'t have displayable reviews', ->
          it 'renders the inline widget', ->
            expect(parent_doc.getElementById('@@flavor-product-reviews-inline').innerHTML.trim()).to.not.be.empty

        context 'and extended widget is disabled', ->
          beforeEach (done) ->
            prepare 'inline', 'extended', 'displayable_reviews_id', { extended_widget_enabled: false }, done

          it 'does not render the extended widget', ->
            expect(parent_doc.getElementById('@@flavor-product-reviews-extended').innerHTML.trim()).to.be.empty

        context 'and extended widget is enabled', ->
          it 'renders the extended widget', ->
            expect(parent_doc.getElementById('@@flavor-product-reviews-extended').innerHTML.trim()).to.not.be.empty

      context 'and it doesn\'t have ratings', ->
        beforeEach (done) ->
          prepare 'inline', 'extended', 'no_ratings_id', {}, done

        context 'and inline widget is enabled', ->
          it 'does not render the inline widget', ->
            expect(parent_doc.getElementById('@@flavor-product-reviews-inline').innerHTML.trim()).to.be.empty

        context 'and extended widget is disabled', ->
          beforeEach (done) ->
            prepare 'extended', 'no_ratings_id', { extended_widget_enabled: false }, done

          it 'does not render the extended widget', ->
            expect(parent_doc.getElementById('@@flavor-product-reviews-extended').innerHTML.trim()).to.be.empty

        context 'and extended widget is enabled', ->
          it 'renders the extended widget', ->
            expect(parent_doc.getElementById('@@flavor-product-reviews-extended').innerHTML.trim()).to.not.be.empty

  describe 'inline widget', ->
    beforeEach (done) ->
      prepare 'inline', 'no_displayable_reviews_id', { inline_widget_theme: 'small-white' }, =>
        @subject = parent_doc.getElementById('@@flavor-product-reviews-inline')
        done()

    it 'adds proper theme class', ->
      expect(@subject.classList.contains('sa-small-white')).to.eq.true

    it 'displays rating stars', ->
      expect(@subject.querySelector('.sa-star-rating').innerHTML.trim()).to.not.be.empty

    context 'when inline widget is clicked', ->
      beforeEach ->
        @subject.click()

      it 'opens the modal dialog', ->
        expect(parent_doc.getElementById('sa-reviews-modal').style.display).to.eq('block')

  describe 'extended widget', ->
    beforeEach (done) ->
      prepare 'extended', 'no_ratings_id', { extended_widget_theme: 'white' }, =>
        @subject = parent_doc.getElementById('@@flavor-product-reviews-extended')
        done()

    it 'adds proper theme class', ->
      expect(@subject.classList.contains('sa-white')).to.eq.true

    context 'when there are ratings', ->
      beforeEach (done) ->
        prepare 'extended', 'no_displayable_reviews_id', {}, =>
          @subject = parent_doc.getElementById('@@flavor-product-reviews-extended')
          done()

      it 'displays rating details', ->
        expect(@subject.querySelector('.sa-sku-details').innerHTML.trim()).to.not.be.empty

      it 'displays "read more button"', ->
        expect(@subject.querySelector('.sa-show-review-modal').innerHTML.trim()).to.not.be.empty

      context 'when "read more button" is clicked', ->
        beforeEach ->
          @subject.querySelector('.sa-show-review-modal').click()

        it 'opens the modal dialog', ->
          expect(parent_doc.getElementById('sa-reviews-modal').style.display).to.eq('block')

      describe 'reviews breakdown', ->
        beforeEach ->
          @subject = parent_doc.querySelector('.sa-rating-breakdown')

        context 'when reviews count is clicked', ->
          beforeEach ->
            parent_doc.querySelector('.sa-reviews-count-compact').click()

          it 'shows reviews breakdown', ->
            expect(@subject.style.display).to.eq('block')

        context 'when reviews count arrow is clicked', ->
          beforeEach ->
            parent_doc.querySelector('.sa-rating-arrow').click()

          it 'shows reviews breakdown', ->
            expect(@subject.style.display).to.eq('block')

        context 'when reviews breakdown is opened', ->
          context 'and reviews count is clicked', ->
            beforeEach ->
              parent_doc.querySelector('.sa-reviews-count-compact').click()
              parent_doc.querySelector('.sa-reviews-count-compact').click()

            it 'shows reviews breakdown', ->
              expect(@subject.style.display).to.eq('none')

          context 'and reviews count arrow is clicked', ->
            beforeEach ->
              parent_doc.querySelector('.sa-rating-arrow').click()
              parent_doc.querySelector('.sa-rating-arrow').click()

            it 'shows reviews breakdown', ->
              expect(@subject.style.display).to.eq('none')

      context 'and it has sales', ->
        beforeEach (done) ->
          prepare 'extended', 'no_displayable_reviews_id', {}, =>
            @subject = parent_doc.getElementById('@@flavor-product-reviews-extended')
            done()

        it 'displays sales text', ->
          expect(@subject.querySelector('.sa-sales-text').innerHTML.trim()).to.not.be.empty

      context 'but it doesn\'t have sales', ->
        beforeEach (done) ->
          prepare 'extended', 'no_sales_id', {}, =>
            @subject = parent_doc.getElementById('@@flavor-product-reviews-extended')
            done()

        it 'doesn\'t display sales text', ->
          expect(parent_doc.querySelector('#\\@\\@flavor-product-reviews-extended .sa-sales-text')).to.not.exist

      context 'and it has reviews', ->
        beforeEach (done) ->
          prepare 'extended', 'displayable_reviews_id', {}, =>
            @subject = parent_doc.getElementById('@@flavor-product-reviews-extended')
            done()

        it 'displays reviews list', ->
          expect(parent_doc.querySelector('#\\@\\@flavor-product-reviews-extended .sa-reviews-list').innerHTML.trim()).to.not.be.empty

        context 'and extended_widget_reviews_count is set', ->
          beforeEach (done) ->
            prepare 'extended', 'displayable_reviews_id', { extended_widget_reviews_count: 3 }, =>
              @subject = parent_doc.getElementById('@@flavor-product-reviews-extended')
              done()

          it 'limits displayed reviews count accordingly', ->
            expect(parent_doc.querySelectorAll('#\\@\\@flavor-product-reviews-extended .sa-reviews-list .sa-review').length).to.eq(3)

        context 'and it has reviews aggregation', ->
          it 'displays the aggregation', ->
            expect(parent_doc.querySelector('#\\@\\@flavor-product-reviews-extended .sa-reviews-aggregation-list').innerHTML.trim()).to.not.be.empty

        context 'but it doesn\'t have reviews aggregation', ->
          beforeEach (done) ->
            prepare 'extended', 'no_aggregation_id', {}, =>
              @subject = parent_doc.getElementById('@@flavor-product-reviews-extended')
              done()

          it 'doesn\'t display the aggregation', ->
            expect(parent_doc.querySelector('#\\@\\@flavor-product-reviews-extended .sa-reviews-aggregation-list')).to.not.exist

        describe 'review', ->
          beforeEach ->
            @subject = parent_doc.querySelector('#\\@\\@flavor-product-reviews-extended .sa-reviews-list .sa-review')

          it 'displays rating stars', ->
            expect(@subject.querySelector('.sa-star-rating').innerHTML.trim()).to.not.be.empty

          context 'when review belongs to another variation product', ->
            beforeEach ->
              @subject = parent_doc.querySelectorAll('#\\@\\@flavor-product-reviews-extended .sa-reviews-list .sa-review')[0]

            it 'displays the merged review notice as html', ->
              expect(@subject.querySelector('div.merged-review-info').innerHTML.trim()).to.not.be.empty

          context 'when review does not belong to another variation product', ->
            beforeEach ->
              @subject = parent_doc.querySelectorAll('#\\@\\@flavor-product-reviews-extended .sa-reviews-list .sa-review')[1]

            it 'does not display the merged review notice', ->
              expect(@subject.querySelector('div.merged-review-info')).to.not.exist

          context 'when review exceeds 500 characters', ->
            beforeEach ->
              @subject = parent_doc.querySelectorAll('#\\@\\@flavor-product-reviews-extended .sa-reviews-list .sa-review')[2]

            it 'adds extendable class to review', ->
              expect(@subject.classList.contains('sa-extendable')).to.eq.true

            it 'displays more button', ->
              expect(@subject.querySelector('.sa-review-expand').innerHTML.trim()).to.not.be.empty

            context 'when more button is clicked', ->
              beforeEach ->
                @subject.querySelector('.sa-review-expand').click()

              it 'removes extendable class from review', ->
                expect(@subject.classList.contains('sa-extendable')).to.eq.false

          context 'when review does not exceed 500 characters', ->
            beforeEach ->
              @subject = parent_doc.querySelectorAll('#\\@\\@flavor-product-reviews-extended .sa-reviews-list .sa-review')[0]

            it 'doesn\'t add extendable class to review', ->
              expect(@subject.classList.contains('sa-extendable')).to.eq.false

            it 'doesn\'t display more button', ->
              expect(@subject.querySelector('.sa-review-expand')).to.not.exist

          context 'when review has all sentiments', ->
            beforeEach ->
              @subject = parent_doc.querySelectorAll('#\\@\\@flavor-product-reviews-extended .sa-reviews-list .sa-review')[0]

            it 'displays all sentiments', ->
              expect(@subject.querySelectorAll('.sa-review-sentiment').length).to.eq(3)

          context 'when review has some sentiments', ->
            beforeEach ->
              @subject = parent_doc.querySelectorAll('#\\@\\@flavor-product-reviews-extended .sa-reviews-list .sa-review')[1]

            it 'displays given sentiments', ->
              expect(@subject.querySelectorAll('.sa-review-sentiment').length).to.eq(1)

          context 'when review has no sentiments', ->
            beforeEach (done) ->
              prepare 'extended', 'displayable_reviews_id', {}, =>
                @subject = parent_doc.querySelectorAll('#\\@\\@flavor-product-reviews-extended .sa-reviews-list .sa-review')[4]
                done()

            it 'doesn\'t display any sentiment', ->
              expect(@subject.querySelectorAll('.sa-review-sentiment').length).to.eq(0)

    context 'when there are no ratings', ->
      beforeEach (done) ->
        prepare 'extended', 'no_ratings_id', {}, =>
          @subject = parent_doc.getElementById('@@flavor-product-reviews-extended')
          done()

      it 'doesn\'t display rating details', ->
        expect(@subject.querySelector('.sa-sku-details')).to.not.exist

      it 'displays "add a review" button', ->
        expect(@subject.querySelector('.sa-review-prompt-button').innerHTML.trim()).to.not.be.empty

      describe '"add a review" button', ->
        beforeEach ->
          @subject = parent_doc.querySelector('.sa-review-prompt-button')

        it 'targets a blank browsing context', ->
          expect(@subject.getAttribute('target')).to.eq('_blank')

        it 'is nofollow', ->
          expect(@subject.getAttribute('rel')).to.eq('nofollow')

        it 'links to current SKU\'s "write a review" page', ->
          application_base = window.sa_plugins.settings.url.application_base
          sku_id = PRODUCT_REVIEWS['no_ratings_id'].sku_id

          expect(@subject.href).to.contain("#{application_base}/account/products/#{sku_id}/reviews/new")

        it 'sets "partner_sku_reviews" as "from" param', ->
          expect(@subject.href).to.contain("from=partner_sku_reviews")

  describe 'modal', ->
    beforeEach (done) ->
      prepare 'inline', 'extended', 'displayable_reviews_id', {}, done

    it 'starts closed', ->
      expect(parent_doc.getElementById('sa-reviews-modal')).to.not.exist


    context 'when user clicks modal close button', ->
      beforeEach ->
        parent_doc.querySelector('#\\@\\@flavor-product-reviews-extended .sa-show-review-modal').click()
        parent_doc.getElementById('sa-reviews-modal-close-button').click()

      it 'is closed', ->
        expect(parent_doc.getElementById('sa-reviews-modal')).to.not.exist

    context 'when user presses ESC key', ->
      beforeEach ->
        parent_doc.querySelector('#\\@\\@flavor-product-reviews-extended .sa-show-review-modal').click()
        trigger_keyboard_event(27, parent_doc)

      it 'is closed', ->
        expect(parent_doc.getElementById('sa-reviews-modal')).to.not.exist
