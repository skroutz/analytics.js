describe 'OrderStash', ->
  originalWindow = window.parent
  pluginWindow = window.parent

  cleanupDom = ->
    # Cleanup rendered plugins and stylesheets
    [].forEach.call pluginWindow.document.querySelectorAll('#sa-order-stash-plugin, #sa-order-stash-style'), (e) ->
      e.parentNode.removeChild e

  renderPlugin = (done, cb) ->
    cleanupDom()

    requirejs.undef 'plugins/order_stash'
    require ['plugins/order_stash'], ->
      cb() if cb
      done()

  beforeEach (done) ->
    @shop_code = 'SA-XXXX-XXXX'
    @analytics_session = 'analytics_session'
    @order_id = 'orders/42/skroutz'

    @position = window.__position || 'bottom-left'
    window.sa_plugins =
      order_stash:
        shop_code: @shop_code
        analytics_session: @analytics_session
        order_id: @order_id
        configuration:
          position: @position

    @application_base = 'http://test.skroutz.gr'
    window.sa_plugins.settings =
      url:
        base: 'http://localhost:9000'
        application_base: @application_base
      plugins:
        order_stash:
          elements_to_hide: []

    renderPlugin done, =>
      @subject = pluginWindow.document.getElementById('sa-order-stash-plugin')

  afterEach -> cleanupDom()

  describe '.constructor', ->
    it 'adds the plugin style to the head', ->
      expect(pluginWindow.document.getElementById('sa-order-stash-style')).to.exist

    it 'adds the plugin markup to the body', ->
      expect(pluginWindow.document.getElementById('sa-order-stash-plugin')).to.exist

    context 'when window.parent.document is missing', ->
      beforeEach (done) ->
        window.parent = null

        renderPlugin done, =>
          @subject = window.top.document.getElementById('sa-order-stash-plugin')

      afterEach ->
        window.parent = originalWindow

      it 'adds the plugin style to the head', ->
        expect(@subject).to.exist

    context 'when order_id is "null" string', ->
      beforeEach (done) ->
        window.sa_plugins.order_stash.order_id = 'null'

        @subject.parentNode.removeChild(@subject)

        renderPlugin done, =>
          @subject = pluginWindow.document.getElementById('sa-order-stash-plugin')

      it 'does not add the plugin markup to the body', ->
        expect(pluginWindow.document.getElementById('sa-order-stash-plugin')).to.not.exist

    context 'when order_id is empty string', ->
      beforeEach (done) ->
        window.sa_plugins.order_stash.order_id = ''

        @subject.parentNode.removeChild(@subject)

        renderPlugin done, =>
          @subject = pluginWindow.document.getElementById('sa-order-stash-plugin')

      it 'does not add the plugin markup to the body', ->
        expect(pluginWindow.document.getElementById('sa-order-stash-plugin')).to.not.exist

    context 'when order_id is undefined', ->
      beforeEach (done) ->
        window.sa_plugins.order_stash.order_id = undefined

        @subject.parentNode.removeChild(@subject)

        renderPlugin done, =>
          @subject = pluginWindow.document.getElementById('sa-order-stash-plugin')

      it 'does not add the plugin markup to the body', ->
        expect(pluginWindow.document.getElementById('sa-order-stash-plugin')).to.not.exist

  describe 'click dismiss button', ->
    beforeEach -> click_element @subject.querySelectorAll('#sa-order-stash-dismiss')[0]

    context 'when the browser supports animations', ->
      beforeEach ->
        @original_animation = @subject.style.animation
        @subject.style.animation = ""
        click_element @subject.querySelectorAll('#sa-order-stash-dismiss')[0]

      afterEach -> @subject.style.animation = @original_animation

      it 'adds the sa-order-stash-slide-out class to the plugin element', ->
        expect(@subject.className).to.eql('sa-order-stash-slide-out')

    context 'when the browser does not support animations', ->
      beforeEach ->
        click_element @subject.querySelectorAll('#sa-order-stash-dismiss')[0]
        @subject.style.animation = null

      it 'removes the element', ->
        expect(pluginWindow.document.getElementById('sa-order-stash-plugin')).
          to.be.null

  describe 'click why button', ->
    beforeEach ->
      click_element @subject.querySelectorAll('#sa-order-stash-why')[0]

    it 'hides the prompt text', ->
      prompt = @subject.querySelectorAll('#sa-order-stash-prompt')[0]

      expect(prompt.style.display).to.eql('none')

    it 'hides the why button', ->
      why = @subject.querySelectorAll('#sa-order-stash-why')[0]

      expect(why.style.display).to.eql('none')

    it 'hides the logo', ->
      header = @subject.querySelectorAll('#sa-order-stash-header')[0]

      expect(header.className).to.eql('sa-order-stash-no-logo')

    it 'displays the rationale text', ->
      rationale = @subject.querySelectorAll('#sa-order-stash-rationale')[0]

      expect(rationale.style.display).to.eql('block')

    it 'sets the heigh of the plugin to "auto"', ->
      expect(@subject.style.height).to.eql('auto')

    it 'changes the text of the call to action button', ->
      button = @subject.querySelectorAll('#sa-order-stash-button')[0]

      expect(button.text).to.be.a('string')

    it 'adds the sa-order-stash-read-more class to the call to action button', ->
      button = @subject.querySelectorAll('#sa-order-stash-button')[0]

      expect(button.className).to.eql('sa-order-stash-read-more')

  describe 'stash button', ->
    before -> @$stash_button = @subject.querySelectorAll('#sa-order-stash-button')[0]

    it 'points to the correct application url', ->
      expect(@$stash_button.href)
        .to.eq(["#{@application_base}",
                "/account/analytics/orders/#{encodeURIComponent(@order_id)}/save",
                "?shop_code=#{@shop_code}&analytics_session=#{@analytics_session}"].join(''))

  describe 'hide elements', ->
    context 'when there are elements to hide', ->
      beforeEach (done) ->
        window.sa_plugins.settings.plugins.order_stash.elements_to_hide = ['#sa-another-plugin']

        @plugin = pluginWindow.document.createElement('div')
        @plugin.id = 'sa-another-plugin'

        pluginWindow.document.body.appendChild(@plugin)

        renderPlugin(done)

      afterEach ->
        window.sa_plugins.settings.plugins.order_stash.elements_to_hide = []
        pluginWindow.document.body.removeChild(@plugin)

      it 'hides specified element', ->
        expect(pluginWindow.getComputedStyle(@plugin).display).to.eql('none')

    context 'when there are no elements to hide', ->
      beforeEach (done) ->
        window.sa_plugins.settings.plugins.order_stash.elements_to_hide = []

        @plugin = pluginWindow.document.createElement('div')
        @plugin.id = 'sa-another-plugin'

        pluginWindow.document.body.appendChild(@plugin)

        renderPlugin(done)

      afterEach ->
        window.sa_plugins.settings.plugins.order_stash.elements_to_hide = []
        pluginWindow.document.body.removeChild(@plugin)

      it 'does not hide any element', ->
        expect(pluginWindow.getComputedStyle(@plugin).display).to.not.eql('none')

    context 'when there is no config for elements_to_hide', ->
      beforeEach (done) ->
        window.sa_plugins.settings.plugins.order_stash.elements_to_hide = null

        @plugin = pluginWindow.document.createElement('div')
        @plugin.id = 'sa-another-plugin'

        pluginWindow.document.body.appendChild(@plugin)

        renderPlugin(done)

      afterEach ->
        window.sa_plugins.settings.plugins.order_stash.elements_to_hide = []
        pluginWindow.document.body.removeChild(@plugin)

      it 'does not hide any element', ->
        expect(pluginWindow.getComputedStyle(@plugin).display).to.not.eql('none')
