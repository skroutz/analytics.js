describe 'Runnable', ->
  before (done) ->
    require ['settings', 'runnable'], (Settings, Runnable) =>
      @settings = Settings
      @klass = class TestClass
        TestClass::[key] = method for key, method of Runnable
      @subject = new @klass

      done()

  describe '#run', ->
    beforeEach ->
      @command_data = { order_id: 42 }
      sa('ecommerce', 'addItem', @command_data)

    afterEach -> @settings.window.sa.q = []

    it 'responds to #run', ->
      expect(@subject).to.respondTo('run')

    context 'when a command is recognized', ->
      before -> @subject._commands = ecommerce: { addItem: sinon.spy() }

      it 'runs the command with the provided arguments', ->
        @subject.run()
        expect(@subject._commands.ecommerce.addItem).to.be.calledWith(@command_data)

      it 'discards the command from the queue', ->
        @subject.run()
        expect(@settings.window.sa.q).to.be.empty

    context 'when a command is not recognized', ->
      before -> @subject._commands = site: { sendPageView: sinon.spy() }

      it 'does not run the command', ->
        @subject.run()
        expect(@subject._commands.site.sendPageView).to.not.be.called

      it 'does not discard the command from the queue', ->
        @subject.run()
        expect(@settings.window.sa.q).to.not.be.empty

    context 'when the commands array is undefined', ->
      before ->
        @subject._commands = ecommerce: { addItem: sinon.spy() }

      it 'does not run the command', ->
        @settings.window.sa.q = undefined
        @subject.run()
        expect(@subject._commands.ecommerce.addItem).to.not.be.called
