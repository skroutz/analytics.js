describe 'UUID', ->
  before (done) ->
    require ['helpers/uuid_helper'], (UUID) =>
      @subject = UUID
      done()

  describe 'API', ->
    it 'responds to generate', ->
      expect(@subject).to.respondTo('generate')

  describe '.generate', ->
    it 'generates a prefixed UUIDv4-like string', ->
      expect(@subject.generate()).to.match(/^ke-[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i)

    it 'generates a different string every time', ->
      expect(@subject.generate()).to.not.eq(@subject.generate())
