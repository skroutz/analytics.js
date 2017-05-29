describe 'Badge', ->
  event_listener_args = []
  orginalAddEventListener = window.parent.document.addEventListener

  removeListeners = ->
    while event_listener_args.length > 0
      args = event_listener_args.pop()
      window.parent.document.removeEventListener args.event, args.func


  cleanupDom = ->
    removeListeners()

    # Cleanup rendered plugins and stylesheets
    selector = '#sa-badge-floating-plugin, #sa-badge-style, #sa-badge-modal'
    [].forEach.call window.parent.document.querySelectorAll(selector), (e) ->
      e.parentNode.removeChild e

    # Cleanup innerHTML of embedded badge
    window.parent.document.getElementById('sa-badge-embedded-plugin')?.innerHTML = ''

  renderPlugin = (done, cb) ->
    cleanupDom()

    requirejs.undef 'plugins/badge'
    require ['plugins/badge'], ->
      cb() if cb
      done()

  setSaPlugins = (defaults, { shop_code, display, theme, position, rating }) ->
    window.sa_plugins =
      badge:
        shop_code: shop_code || defaults.shop_code
        configuration:
          display: display || defaults.display
          theme: theme || defaults.theme
          position: position  || defaults.position
        data:
          rating: rating || defaults.rating

    window.sa_plugins.settings =
      url:
        base: defaults.base
        application_base: defaults.application_base
      plugins:
        badge:
          url: 'url'

  before ->
    window.parent.document.addEventListener = ->
      event_listener_args.push({ event: arguments[0], func: arguments[1] })

      orginalAddEventListener.apply this, arguments

  beforeEach ->
    @default_settings =
      shop_code: 'SA-XXXX-XXXX'
      display: 'floating'
      theme: 'black'
      position: 'bottom-right'
      rating: 0.0
      base: 'http://localhost:9000'
      application_base: 'http://test.skroutz.gr'

  after -> window.parent.document.addEventListener = orginalAddEventListener

  afterEach ->
    cleanupDom()

    delete window.sa_plugins

  describe 'floating', ->
    beforeEach (done) ->
      @default_settings.display = 'floating'

      setSaPlugins(@default_settings, {})
      renderPlugin done, =>
        @subject = window.parent.document.getElementById('sa-badge-floating-plugin')

    describe '.constructor', ->
      it 'adds the plugin style to the head', ->
        expect(window.parent.document.getElementById('sa-badge-style')).to.exist

      it 'adds the plugin markup to the body', ->
        expect(window.parent.document.getElementById('sa-badge-floating-plugin')).to.exist

      context 'when rating is 0', ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 0)

          renderPlugin done, =>
            @subject = window.parent.document.getElementById('sa-badge-floating-plugin')

        it 'adds no stars class to container', ->
          expect(@subject.className).to.include('sa-badge-no-stars')

    describe 'click on badge', ->
      beforeEach -> click_element @subject

      it 'displays the badge modal', ->
        expect(window.parent.document.getElementById('sa-badge-modal')).to.exist

      it 'displays the iframe', ->
        expect(window.parent.document.getElementById('sa-badge-modal-iframe')).to.exist

      it 'displays the iframe with proper src', ->
        expect(window.parent.document.getElementById('sa-badge-modal-iframe').src)
          .to.eq(["#{@default_settings.application_base}",
                  "/badge/shop_reviews?shop_code=#{@default_settings.shop_code}",
                  "&origin=#{encodeURIComponent(window.location.origin)}",
                  "&pathname=#{encodeURIComponent(window.location.pathname)}"].join(''))

      context 'when click outside of iframe', ->
        beforeEach ->
          click_element window.parent.document.getElementById('sa-badge-modal')

        it 'destroys the modal', ->
          expect(window.parent.document.getElementById('sa-badge-modal')).to.not.exist

      context 'when click modal close button', ->
        beforeEach ->
          click_element window.parent.document.getElementById('sa-badge-modal-close-button')

        it 'destroys the modal', ->
          expect(window.parent.document.getElementById('sa-badge-modal')).to.not.exist

      context 'when press ESC key', ->
        it 'destroys the modal', ->
          trigger_keyboard_event(27, window.parent.document)

          expect(window.parent.document.getElementById('sa-badge-modal')).to.not.exist

    describe 'rating', ->
      context 'when rating is 0', ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 0)

          renderPlugin done, =>
            @subject = window.parent.document.getElementById('sa-badge-floating-stars-container')

        it 'does not show stars', ->
          expect(@subject).to.not.exist

      context 'when rating is 5', ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 5)

          renderPlugin done, =>
            @subject = window.parent.document.getElementsByClassName('sa-badge-full-star')

        it 'shows 5 full stars', ->
          expect(@subject.length).to.eql(5)

      context "when the rating's fractional part is 0", ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 4)

          renderPlugin done, =>
            @subject =
              full_stars: window.parent.document.getElementsByClassName('sa-badge-full-star').length
              half_stars: window.parent.document.getElementsByClassName('sa-badge-half-star').length
              empty_stars: window.parent.document.getElementsByClassName('sa-badge-empty-star').length

        it 'shows full stars equal to the integer part, followed by empty stars up to a maximum of 5 stars', ->
          expect(@subject).to.eql(full_stars: 4, half_stars: 0, empty_stars: 1)

      context "when the rating's fractional part is 5", ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 3.5)

          renderPlugin done, =>
            @subject =
              full_stars: window.parent.document.getElementsByClassName('sa-badge-full-star').length
              half_stars: window.parent.document.getElementsByClassName('sa-badge-half-star').length
              empty_stars: window.parent.document.getElementsByClassName('sa-badge-empty-star').length

        it 'shows full stars equal to the integer part, followed by a half star, followed by empty stars up to a maximum of 5 stars', ->
          expect(@subject).to.eql(full_stars: 3, half_stars: 1, empty_stars: 1)

      context "when the rating's fractional part differs from 5 by more than 2", ->
        context "and fractional part is closer to 9", ->
          beforeEach (done) ->
            setSaPlugins(@default_settings, rating: 2.8)

            renderPlugin done, =>
              @subject =
                full_stars: window.parent.document.getElementsByClassName('sa-badge-full-star').length
                half_stars: window.parent.document.getElementsByClassName('sa-badge-half-star').length
                empty_stars: window.parent.document.getElementsByClassName('sa-badge-empty-star').length

          it 'shows full stars equal to the integer part plus 1, followed by empty stars up to a maximum of 5 stars', ->
            expect(@subject).to.eql(full_stars: 3, half_stars: 0, empty_stars: 2)

        context "and fractional part is closer to 0", ->
          beforeEach (done) ->
            setSaPlugins(@default_settings, rating: 4.1)

            renderPlugin done, =>
              @subject =
                full_stars: window.parent.document.getElementsByClassName('sa-badge-full-star').length
                half_stars: window.parent.document.getElementsByClassName('sa-badge-half-star').length
                empty_stars: window.parent.document.getElementsByClassName('sa-badge-empty-star').length

          it 'shows full stars equal to the integer part, followed by empty stars up to a maximum of 5 stars', ->
            expect(@subject).to.eql(full_stars: 4, half_stars: 0, empty_stars: 1)

      context "when the rating's fractional part differs from 5 up to 2", ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 3.7)

          renderPlugin done, =>
            @subject =
              full_stars: window.parent.document.getElementsByClassName('sa-badge-full-star').length
              half_stars: window.parent.document.getElementsByClassName('sa-badge-half-star').length
              empty_stars: window.parent.document.getElementsByClassName('sa-badge-empty-star').length

        it 'shows full stars equal to the integer part, followed by a half star, followed by empty stars up to a maximum of 5 stars', ->
          expect(@subject).to.eql(full_stars: 3, half_stars: 1, empty_stars: 1)

  describe 'embedded', ->
    beforeEach (done) ->
      @default_settings.display = 'embedded'

      setSaPlugins(@default_settings, {})

      @embedded_badge = window.parent.document.createElement('div')
      @embedded_badge.id = 'sa-badge-embedded-plugin'
      window.parent.document.body.appendChild(@embedded_badge)

      renderPlugin done, =>
        @subject = window.parent.document.getElementById('sa-badge-embedded-plugin')

    afterEach ->
      try
        @embedded_badge.parentNode.removeChild(@embedded_badge)
      catch
        # Already removed

    describe '.constructor', ->
      it 'adds the plugin style to the head', ->
        expect(window.parent.document.getElementById('sa-badge-style')).to.exist

      it 'adds the plugin markup to the embedded badge container', ->
        expect(window.parent.document.getElementById('sa-badge-embedded-plugin').innerHTML).to.not.be.empty

      context 'when embedded badge container is missing', ->
        beforeEach (done) ->
          @embedded_badge.parentNode.removeChild(@embedded_badge)

          renderPlugin done, =>
            @subject = window.parent.document.getElementById('sa-badge-embedded-plugin')

        it 'does not add the plugin markup to the embedded badge container', ->
          expect(window.parent.document.getElementById('sa-badge-embedded-plugin')).to.not.exist

      context 'when rating is 0', ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 0)

          renderPlugin done, =>
            @subject = window.parent.document.getElementById('sa-badge-embedded-plugin')

        it 'adds no stars class to container', ->
          expect(@subject.className).to.include('sa-badge-no-stars')

    describe 'click on badge', ->
      beforeEach -> click_element @subject

      it 'displays the badge modal', ->
        expect(window.parent.document.getElementById('sa-badge-modal')).to.exist

      it 'displays the iframe', ->
        expect(window.parent.document.getElementById('sa-badge-modal-iframe')).to.exist

      it 'displays the iframe with proper src', ->
        expect(window.parent.document.getElementById('sa-badge-modal-iframe').src)
          .to.eq(["#{@default_settings.application_base}",
                  "/badge/shop_reviews?shop_code=#{@default_settings.shop_code}",
                  "&origin=#{encodeURIComponent(window.location.origin)}",
                  "&pathname=#{encodeURIComponent(window.location.pathname)}"].join(''))

      context 'when click outside of iframe', ->
        beforeEach ->
          click_element window.parent.document.getElementById('sa-badge-modal')

        it 'destroys the modal', ->
          expect(window.parent.document.getElementById('sa-badge-modal')).to.not.exist

      context 'when click modal close button', ->
        beforeEach ->
          click_element window.parent.document.getElementById('sa-badge-modal-close-button')

        it 'destroys the modal', ->
          expect(window.parent.document.getElementById('sa-badge-modal')).to.not.exist

      context 'when press ESC key', ->
        it 'destroys the modal', ->
          trigger_keyboard_event(27, window.parent.document)

          expect(window.parent.document.getElementById('sa-badge-modal')).to.not.exist

    describe 'rating', ->
      describe 'number', ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 4)

          renderPlugin done, =>
            @subject =
              window.parent
                    .document
                    .querySelectorAll('#sa-badge-embedded-rating-container .sa-badge-embedded-rating-number span')[0]
                    .textContent

        it 'displays the rating', ->
          expect(@subject).to.eql('4.0')

      context 'when rating is 0', ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 0)

          renderPlugin done, =>
            @subject = window.parent.document.getElementById('sa-badge-embedded-rating-container')

        it 'does not show either stars or rating number', ->
          expect(@subject).to.not.exist

      context 'when rating is 5', ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 5)

          renderPlugin done, =>
            @subject = window.parent.document.getElementsByClassName('sa-badge-full-star')

        it 'shows 5 full stars', ->
          expect(@subject.length).to.eql(5)

      context "when the rating's fractional part is 0", ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 4)

          renderPlugin done, =>
            @subject =
              full_stars: window.parent.document.getElementsByClassName('sa-badge-full-star').length
              half_stars: window.parent.document.getElementsByClassName('sa-badge-half-star').length
              empty_stars: window.parent.document.getElementsByClassName('sa-badge-empty-star').length

        it 'shows full stars equal to the integer part, followed by empty stars up to a maximum of 5 stars', ->
          expect(@subject).to.eql(full_stars: 4, half_stars: 0, empty_stars: 1)

      context "when the rating's fractional part is 5", ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 3.5)

          renderPlugin done, =>
            @subject =
              full_stars: window.parent.document.getElementsByClassName('sa-badge-full-star').length
              half_stars: window.parent.document.getElementsByClassName('sa-badge-half-star').length
              empty_stars: window.parent.document.getElementsByClassName('sa-badge-empty-star').length

        it 'shows full stars equal to the integer part, followed by a half star, followed by empty stars up to a maximum of 5 stars', ->
          expect(@subject).to.eql(full_stars: 3, half_stars: 1, empty_stars: 1)

      context "when the rating's fractional part differs from 5 by more than 2", ->
        context "and fractional part is closer to 9", ->
          beforeEach (done) ->
            setSaPlugins(@default_settings, rating: 2.8)

            renderPlugin done, =>
              @subject =
                full_stars: window.parent.document.getElementsByClassName('sa-badge-full-star').length
                half_stars: window.parent.document.getElementsByClassName('sa-badge-half-star').length
                empty_stars: window.parent.document.getElementsByClassName('sa-badge-empty-star').length

          it 'shows full stars equal to the integer part plus 1, followed by empty stars up to a maximum of 5 stars', ->
            expect(@subject).to.eql(full_stars: 3, half_stars: 0, empty_stars: 2)

        context "and fractional part is closer to 0", ->
          beforeEach (done) ->
            setSaPlugins(@default_settings, rating: 4.1)

            renderPlugin done, =>
              @subject =
                full_stars: window.parent.document.getElementsByClassName('sa-badge-full-star').length
                half_stars: window.parent.document.getElementsByClassName('sa-badge-half-star').length
                empty_stars: window.parent.document.getElementsByClassName('sa-badge-empty-star').length

          it 'shows full stars equal to the integer part, followed by empty stars up to a maximum of 5 stars', ->
            expect(@subject).to.eql(full_stars: 4, half_stars: 0, empty_stars: 1)

      context "when the rating's fractional part differs from 5 up to 2", ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 3.7)

          renderPlugin done, =>
            @subject =
              full_stars: window.parent.document.getElementsByClassName('sa-badge-full-star').length
              half_stars: window.parent.document.getElementsByClassName('sa-badge-half-star').length
              empty_stars: window.parent.document.getElementsByClassName('sa-badge-empty-star').length

        it 'shows full stars equal to the integer part, followed by a half star, followed by empty stars up to a maximum of 5 stars', ->
          expect(@subject).to.eql(full_stars: 3, half_stars: 1, empty_stars: 1)
