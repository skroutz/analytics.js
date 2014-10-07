describe 'Analytics', ->
  before (done) ->
    # mock ActionsManager
    requirejs.undef 'actions_manager'
    @actions_spy = sinon.spy()

    define 'actions_manager', [], =>
      return @actions_spy

    require ['analytics', 'actions_manager'], (Analytics, ActionsManager) =>
      @ActionsManager = ActionsManager
      @analytics = Analytics
      done()

  after ->
    requirejs.undef 'actions_manager'
    window.__requirejs__.clearRequireState()

  afterEach ->
    @actions_spy.reset()

  describe '.constructor', ->
    beforeEach -> @instance = new @analytics()

    it 'has own property manager', ->
      expect(@instance).to.have.ownProperty('manager')

    it 'creates an ActionsManager', ->
      expect(@instance.manager).to.be.an.instanceof @ActionsManager

    it 'creates an ActionsManager using new', ->
      expect(@ActionsManager).to.be.calledWithNew
