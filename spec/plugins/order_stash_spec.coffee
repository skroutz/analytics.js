describe 'OrderStash', ->
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

    requirejs.undef 'plugins/order_stash'
    require ['plugins/order_stash'], =>
      @subject = window.parent.document.getElementById('sa-order-stash-plugin')
      done()

  afterEach ->
    try
      @subject.parentNode.removeChild(@subject)
    catch
      # Already removed

  describe '.constructor', ->
    it 'adds the plugin style to the head', ->
      expect(window.parent.document.getElementById('sa-order-stash-style')).to.be

    it 'adds the plugin markup to the body', ->
      expect(window.parent.document.getElementById('sa-order-stash-plugin')).to.be

  describe 'click dismiss button', ->
    beforeEach -> click_element @subject.querySelectorAll('#sa-order-stash-dismiss')[0]

    context 'when the browser supports transitions', ->
      beforeEach ->
        @original_transition = @subject.style.transition
        @subject.style.transition = ""
        console.log @subject.style.transition
        click_element @subject.querySelectorAll('#sa-order-stash-dismiss')[0]

      afterEach -> @subject.style.transition = @original_transition

      it 'adds the sa-order-stash-slide-out class to the plugin element', ->
        expect(@subject.className).to.eql('sa-order-stash-slide-out')

    context 'when the browser does not support transitions', ->
      beforeEach ->
        click_element @subject.querySelectorAll('#sa-order-stash-dismiss')[0]
        @subject.style.transition = null

      it 'removes the element', ->
        expect(window.parent.document.getElementById('sa-order-stash-plugin')).
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

      expect(button.text).to.eq('Αποθήκευση της παραγγελίας')

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
