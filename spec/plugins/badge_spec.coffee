describe 'Badge', ->
  event_listener_args = []
  originalWindow = window.parent
  pluginWindow = window.parent
  orginalAddEventListener = pluginWindow.document.addEventListener

  removeListeners = ->
    while event_listener_args.length > 0
      args = event_listener_args.pop()
      pluginWindow.document.removeEventListener args.event, args.func


  cleanupDom = ->
    removeListeners()

    # Cleanup rendered plugins and stylesheets
    selector = '#sa-badge-floating-plugin, #sa-badge-style, #sa-badge-modal'
    [].forEach.call pluginWindow.document.querySelectorAll(selector), (e) ->
      e.parentNode.removeChild e

    # Cleanup innerHTML of embedded badge
    pluginWindow.document.getElementById('sa-badge-embedded-plugin')?.innerHTML = ''

  renderPlugin = (done, cb) ->
    cleanupDom()

    requirejs.undef 'plugins/badge'
    require ['plugins/badge'], ->
      cb() if cb
      done()

  setSaPlugins = (defaults, { shop_code, display, theme, position, hide_onscroll, rating }) ->
    window.sa_plugins =
      badge:
        shop_code: shop_code || defaults.shop_code
        configuration:
          display: display || defaults.display
          theme: theme || defaults.theme
          position: position  || defaults.position
          hide_onscroll: hide_onscroll || defaults.hide_onscroll
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
    pluginWindow.document.addEventListener = ->
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
      hide_onscroll: false

  after -> pluginWindow.document.addEventListener = orginalAddEventListener

  afterEach ->
    cleanupDom()

    delete window.sa_plugins

  describe 'floating', ->
    beforeEach (done) ->
      @default_settings.display = 'floating'

      setSaPlugins(@default_settings, {})
      renderPlugin done, =>
        @subject = pluginWindow.document.getElementById('sa-badge-floating-plugin')

    describe '.constructor', ->
      it 'adds the plugin style to the head', ->
        expect(pluginWindow.document.getElementById('sa-badge-style')).to.exist

      it 'adds the plugin markup to the body', ->
        expect(pluginWindow.document.getElementById('sa-badge-floating-plugin')).to.exist

      context 'when window.parent.document is missing', ->
        beforeEach (done) ->
          window.parent = null

          setSaPlugins(@default_settings, rating: 0)

          renderPlugin done, =>
            @subject = window.top.document.getElementById('sa-badge-floating-plugin')

        afterEach ->
          window.parent = originalWindow

        it 'adds the plugin style to the head', ->
          expect(@subject).to.exist

      context 'when rating is 0', ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 0)

          renderPlugin done, =>
            @subject = pluginWindow.document.getElementById('sa-badge-floating-plugin')

        it 'adds no stars class to container', ->
          expect(@subject.className).to.include('sa-badge-no-stars')

    describe 'click on badge', ->
      beforeEach -> click_element @subject

      it 'displays the badge modal', ->
        expect(pluginWindow.document.getElementById('sa-badge-modal')).to.exist

      it 'displays the iframe', ->
        expect(pluginWindow.document.getElementById('sa-badge-modal-iframe')).to.exist

      it 'displays the iframe with proper src', ->
        expect(pluginWindow.document.getElementById('sa-badge-modal-iframe').src)
          .to.eq(["#{@default_settings.application_base}",
                  "/badge/shop_reviews?shop_code=#{@default_settings.shop_code}",
                  "&badge_display=#{@default_settings.display}",
                  "&hide_onscroll=#{@default_settings.hide_onscroll}"
                  "&origin=#{encodeURIComponent(window.location.origin)}",
                  "&pathname=#{encodeURIComponent(window.location.pathname)}"].join(''))

      context 'when click outside of iframe', ->
        beforeEach ->
          click_element pluginWindow.document.getElementById('sa-badge-modal')

        it 'destroys the modal', ->
          expect(pluginWindow.document.getElementById('sa-badge-modal')).to.not.exist

      context 'when click modal close button', ->
        beforeEach ->
          click_element pluginWindow.document.getElementById('sa-badge-modal-close-button')

        it 'destroys the modal', ->
          expect(pluginWindow.document.getElementById('sa-badge-modal')).to.not.exist

      context 'when press ESC key', ->
        it 'destroys the modal', ->
          trigger_keyboard_event(27, pluginWindow.document)

          expect(pluginWindow.document.getElementById('sa-badge-modal')).to.not.exist

    describe 'rating', ->
      context 'when rating is 0', ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 0)

          renderPlugin done, =>
            @subject = pluginWindow.document.getElementById('sa-badge-floating-stars-container')

        it 'does not show stars', ->
          expect(@subject).to.not.exist

      context 'when rating is 5', ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 5)

          renderPlugin done, =>
            @subject = pluginWindow.document.getElementsByClassName('sa-badge-full-star')

        it 'shows 5 full stars', ->
          expect(@subject.length).to.eql(5)

      context "when the rating's fractional part is 0", ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 4)

          renderPlugin done, =>
            @subject =
              full_stars: pluginWindow.document.getElementsByClassName('sa-badge-full-star').length
              half_stars: pluginWindow.document.getElementsByClassName('sa-badge-half-star').length
              empty_stars: pluginWindow.document.getElementsByClassName('sa-badge-empty-star').length

        it 'shows full stars equal to the integer part, followed by empty stars up to a maximum of 5 stars', ->
          expect(@subject).to.eql(full_stars: 4, half_stars: 0, empty_stars: 1)

      context "when the rating's fractional part is 5", ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 3.5)

          renderPlugin done, =>
            @subject =
              full_stars: pluginWindow.document.getElementsByClassName('sa-badge-full-star').length
              half_stars: pluginWindow.document.getElementsByClassName('sa-badge-half-star').length
              empty_stars: pluginWindow.document.getElementsByClassName('sa-badge-empty-star').length

        it 'shows full stars equal to the integer part, followed by a half star, followed by empty stars up to a maximum of 5 stars', ->
          expect(@subject).to.eql(full_stars: 3, half_stars: 1, empty_stars: 1)

      context "when the rating's fractional part differs from 5 by more than 2", ->
        context "and fractional part is closer to 9", ->
          beforeEach (done) ->
            setSaPlugins(@default_settings, rating: 2.8)

            renderPlugin done, =>
              @subject =
                full_stars: pluginWindow.document.getElementsByClassName('sa-badge-full-star').length
                half_stars: pluginWindow.document.getElementsByClassName('sa-badge-half-star').length
                empty_stars: pluginWindow.document.getElementsByClassName('sa-badge-empty-star').length

          it 'shows full stars equal to the integer part plus 1, followed by empty stars up to a maximum of 5 stars', ->
            expect(@subject).to.eql(full_stars: 3, half_stars: 0, empty_stars: 2)

        context "and fractional part is closer to 0", ->
          beforeEach (done) ->
            setSaPlugins(@default_settings, rating: 4.1)

            renderPlugin done, =>
              @subject =
                full_stars: pluginWindow.document.getElementsByClassName('sa-badge-full-star').length
                half_stars: pluginWindow.document.getElementsByClassName('sa-badge-half-star').length
                empty_stars: pluginWindow.document.getElementsByClassName('sa-badge-empty-star').length

          it 'shows full stars equal to the integer part, followed by empty stars up to a maximum of 5 stars', ->
            expect(@subject).to.eql(full_stars: 4, half_stars: 0, empty_stars: 1)

      context "when the rating's fractional part differs from 5 up to 2", ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 3.7)

          renderPlugin done, =>
            @subject =
              full_stars: pluginWindow.document.getElementsByClassName('sa-badge-full-star').length
              half_stars: pluginWindow.document.getElementsByClassName('sa-badge-half-star').length
              empty_stars: pluginWindow.document.getElementsByClassName('sa-badge-empty-star').length

        it 'shows full stars equal to the integer part, followed by a half star, followed by empty stars up to a maximum of 5 stars', ->
          expect(@subject).to.eql(full_stars: 3, half_stars: 1, empty_stars: 1)

    describe 'show/hide onscroll', ->
      beforeEach ->
        @original_body_height = pluginWindow.document.body.style.height
        @original_body_width = pluginWindow.document.body.style.width
        pluginWindow.document.body.style.height = '10000px'
        pluginWindow.document.body.style.width = '10000px'

      afterEach ->
        pluginWindow.document.body.style.height = @original_body_height
        pluginWindow.document.body.style.width = @original_body_width

      context 'when hide_onscroll set to true', ->
        beforeEach -> setSaPlugins(@default_settings, hide_onscroll: true)

        context 'on small screen', ->
          beforeEach (done) ->
            @original_viewport_width = pluginWindow.innerWidth
            pluginWindow.innerWidth = 768

            renderPlugin done, =>
              @subject = pluginWindow.document.getElementById('sa-badge-floating-plugin')

          afterEach ->
            pluginWindow.document.onscroll = null
            pluginWindow.innerWidth = @original_viewport_width

          it 'hides floating badge on scroll down', (done) ->
            pluginWindow.document.onscroll = =>
              expect(@subject.classList.contains('sa-badge-floating-hidden')).to.eq(true)
              expect(@subject.classList.contains('sa-badge-floating-visible')).to.eq(false)

              done()

            pluginWindow.scrollBy(0, 100)

          it 'shows floating badge on scroll up', (done) ->
            scroll_count = 0

            pluginWindow.document.onscroll = =>
              if scroll_count == 1
                expect(@subject.classList.contains('sa-badge-floating-hidden')).to.eq(false)
                expect(@subject.classList.contains('sa-badge-floating-visible')).to.eq(true)

                done()
              else
                scroll_count += 1

                pluginWindow.scroll(0, 0)

            pluginWindow.scrollBy(0, 100)

          context 'when scoll horizontally', ->
            it 'does not change badge visibility', (done) ->
              pluginWindow.document.onscroll = =>
                expect(@subject.classList.contains('sa-badge-floating-hidden')).to.eq(false)
                expect(@subject.classList.contains('sa-badge-floating-visible')).to.eq(true)

                done()

              pluginWindow.scrollBy(100, 0)

        context 'on big screen', ->
          beforeEach (done) ->
            @original_viewport_width = pluginWindow.innerWidth
            pluginWindow.innerWidth = 769

            renderPlugin done, =>
              @subject = pluginWindow.document.getElementById('sa-badge-floating-plugin')

          afterEach ->
            pluginWindow.document.onscroll = null
            pluginWindow.innerWidth = @original_viewport_width

          it 'does not change badge visibility', (done) ->
            pluginWindow.document.onscroll = =>
              expect(@subject.classList.contains('sa-badge-floating-hidden')).to.eq(false)
              expect(@subject.classList.contains('sa-badge-floating-visible')).to.eq(true)

              done()

            pluginWindow.scrollBy(0, 100)

      context 'when hide_onscroll set to false', ->
        beforeEach -> setSaPlugins(@default_settings, hide_onscroll: false)

        context 'on small screen', ->
          beforeEach (done) ->
            @original_viewport_width = pluginWindow.innerWidth
            pluginWindow.innerWidth = 768

            renderPlugin done, =>
              @subject = pluginWindow.document.getElementById('sa-badge-floating-plugin')

          afterEach ->
            pluginWindow.document.onscroll = null
            pluginWindow.innerWidth = @original_viewport_width

          it 'does not change badge visibility', (done) ->
            pluginWindow.document.onscroll = =>
              expect(@subject.classList.contains('sa-badge-floating-hidden')).to.eq(false)
              expect(@subject.classList.contains('sa-badge-floating-visible')).to.eq(true)

              done()

            pluginWindow.scrollBy(0, 100)

        context 'on big screen', ->
          beforeEach (done) ->
            @original_viewport_width = pluginWindow.innerWidth
            pluginWindow.innerWidth = 769

            renderPlugin done, =>
              @subject = pluginWindow.document.getElementById('sa-badge-floating-plugin')

          afterEach ->
            pluginWindow.document.onscroll = null
            pluginWindow.innerWidth = @original_viewport_width

          it 'does not change badge visibility', (done) ->
            pluginWindow.document.onscroll = =>
              expect(@subject.classList.contains('sa-badge-floating-hidden')).to.eq(false)
              expect(@subject.classList.contains('sa-badge-floating-visible')).to.eq(true)

              done()

            pluginWindow.scrollBy(0, 100)

  describe 'embedded', ->
    beforeEach (done) ->
      @default_settings.display = 'embedded'

      setSaPlugins(@default_settings, {})

      @embedded_badge = pluginWindow.document.createElement('div')
      @embedded_badge.id = 'sa-badge-embedded-plugin'
      pluginWindow.document.body.appendChild(@embedded_badge)

      renderPlugin done, =>
        @subject = pluginWindow.document.getElementById('sa-badge-embedded-plugin')

    afterEach ->
      try
        @embedded_badge.parentNode.removeChild(@embedded_badge)
      catch
        # Already removed

    describe '.constructor', ->
      it 'adds the plugin style to the head', ->
        expect(pluginWindow.document.getElementById('sa-badge-style')).to.exist

      it 'adds the plugin markup to the embedded badge container', ->
        expect(pluginWindow.document.getElementById('sa-badge-embedded-plugin').innerHTML).to.not.be.empty

      context 'when embedded badge container is missing', ->
        beforeEach (done) ->
          @embedded_badge.parentNode.removeChild(@embedded_badge)

          renderPlugin done, =>
            @subject = pluginWindow.document.getElementById('sa-badge-embedded-plugin')

        it 'does not add the plugin markup to the embedded badge container', ->
          expect(pluginWindow.document.getElementById('sa-badge-embedded-plugin')).to.not.exist

      context 'when rating is 0', ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 0)

          renderPlugin done, =>
            @subject = pluginWindow.document.getElementById('sa-badge-embedded-plugin')

        it 'adds no stars class to container', ->
          expect(@subject.className).to.include('sa-badge-no-stars')

    describe 'click on badge', ->
      beforeEach -> click_element @subject

      it 'displays the badge modal', ->
        expect(pluginWindow.document.getElementById('sa-badge-modal')).to.exist

      it 'displays the iframe', ->
        expect(pluginWindow.document.getElementById('sa-badge-modal-iframe')).to.exist

      it 'displays the iframe with proper src', ->
        expect(pluginWindow.document.getElementById('sa-badge-modal-iframe').src)
          .to.eq(["#{@default_settings.application_base}",
                  "/badge/shop_reviews?shop_code=#{@default_settings.shop_code}",
                  "&badge_display=#{@default_settings.display}",
                  "&hide_onscroll=#{@default_settings.hide_onscroll}"
                  "&origin=#{encodeURIComponent(window.location.origin)}",
                  "&pathname=#{encodeURIComponent(window.location.pathname)}"].join(''))

      context 'when click outside of iframe', ->
        beforeEach ->
          click_element pluginWindow.document.getElementById('sa-badge-modal')

        it 'destroys the modal', ->
          expect(pluginWindow.document.getElementById('sa-badge-modal')).to.not.exist

      context 'when click modal close button', ->
        beforeEach ->
          click_element pluginWindow.document.getElementById('sa-badge-modal-close-button')

        it 'destroys the modal', ->
          expect(pluginWindow.document.getElementById('sa-badge-modal')).to.not.exist

      context 'when press ESC key', ->
        it 'destroys the modal', ->
          trigger_keyboard_event(27, pluginWindow.document)

          expect(pluginWindow.document.getElementById('sa-badge-modal')).to.not.exist

    describe 'rating', ->
      describe 'number', ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 4)

          renderPlugin done, =>
            @subject =
              pluginWindow
                    .document
                    .querySelectorAll('#sa-badge-embedded-rating-container .sa-badge-embedded-rating-number span')[0]
                    .textContent

        it 'displays the rating', ->
          expect(@subject).to.eql('4.0')

      context 'when rating is 0', ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 0)

          renderPlugin done, =>
            @subject = pluginWindow.document.getElementById('sa-badge-embedded-rating-container')

        it 'does not show either stars or rating number', ->
          expect(@subject).to.not.exist

      context 'when rating is 5', ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 5)

          renderPlugin done, =>
            @subject = pluginWindow.document.getElementsByClassName('sa-badge-full-star')

        it 'shows 5 full stars', ->
          expect(@subject.length).to.eql(5)

      context "when the rating's fractional part is 0", ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 4)

          renderPlugin done, =>
            @subject =
              full_stars: pluginWindow.document.getElementsByClassName('sa-badge-full-star').length
              half_stars: pluginWindow.document.getElementsByClassName('sa-badge-half-star').length
              empty_stars: pluginWindow.document.getElementsByClassName('sa-badge-empty-star').length

        it 'shows full stars equal to the integer part, followed by empty stars up to a maximum of 5 stars', ->
          expect(@subject).to.eql(full_stars: 4, half_stars: 0, empty_stars: 1)

      context "when the rating's fractional part is 5", ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 3.5)

          renderPlugin done, =>
            @subject =
              full_stars: pluginWindow.document.getElementsByClassName('sa-badge-full-star').length
              half_stars: pluginWindow.document.getElementsByClassName('sa-badge-half-star').length
              empty_stars: pluginWindow.document.getElementsByClassName('sa-badge-empty-star').length

        it 'shows full stars equal to the integer part, followed by a half star, followed by empty stars up to a maximum of 5 stars', ->
          expect(@subject).to.eql(full_stars: 3, half_stars: 1, empty_stars: 1)

      context "when the rating's fractional part differs from 5 by more than 2", ->
        context "and fractional part is closer to 9", ->
          beforeEach (done) ->
            setSaPlugins(@default_settings, rating: 2.8)

            renderPlugin done, =>
              @subject =
                full_stars: pluginWindow.document.getElementsByClassName('sa-badge-full-star').length
                half_stars: pluginWindow.document.getElementsByClassName('sa-badge-half-star').length
                empty_stars: pluginWindow.document.getElementsByClassName('sa-badge-empty-star').length

          it 'shows full stars equal to the integer part plus 1, followed by empty stars up to a maximum of 5 stars', ->
            expect(@subject).to.eql(full_stars: 3, half_stars: 0, empty_stars: 2)

        context "and fractional part is closer to 0", ->
          beforeEach (done) ->
            setSaPlugins(@default_settings, rating: 4.1)

            renderPlugin done, =>
              @subject =
                full_stars: pluginWindow.document.getElementsByClassName('sa-badge-full-star').length
                half_stars: pluginWindow.document.getElementsByClassName('sa-badge-half-star').length
                empty_stars: pluginWindow.document.getElementsByClassName('sa-badge-empty-star').length

          it 'shows full stars equal to the integer part, followed by empty stars up to a maximum of 5 stars', ->
            expect(@subject).to.eql(full_stars: 4, half_stars: 0, empty_stars: 1)

      context "when the rating's fractional part differs from 5 up to 2", ->
        beforeEach (done) ->
          setSaPlugins(@default_settings, rating: 3.7)

          renderPlugin done, =>
            @subject =
              full_stars: pluginWindow.document.getElementsByClassName('sa-badge-full-star').length
              half_stars: pluginWindow.document.getElementsByClassName('sa-badge-half-star').length
              empty_stars: pluginWindow.document.getElementsByClassName('sa-badge-empty-star').length

        it 'shows full stars equal to the integer part, followed by a half star, followed by empty stars up to a maximum of 5 stars', ->
          expect(@subject).to.eql(full_stars: 3, half_stars: 1, empty_stars: 1)
