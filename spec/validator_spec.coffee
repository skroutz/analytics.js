describe 'Validator', ->
  before (done) ->
    require ['validator'], (Validator) =>
      @Validator = Validator
      done()

  describe '.constructor', ->
    it 'creates new Validator for Object', ->
      expect(=> new @Validator({ key: 'value', key2: 45 }))
        .to.not.throw()

    it 'creates new Validator for stringified Object', ->
      expect(=> new @Validator(JSON.stringify { key: 'value', key2: 45 }))
        .to.not.throw()

    it 'throws ValidationError for invalid JSON string', ->
      expect(=> new @Validator("invalid json"))
        .to.throw().that.has.property('name').that.eq('ValidationError')

    it 'throws ValidationError for non-object data', ->
      expect(=> new @Validator(15))
        .to.throw().that.has.property('name').that.eq('ValidationError')

  describe '#present', ->
    beforeEach ->
      @validator = new @Validator({ key: 'value', key2: 45 })

    it 'throws ValidationError for non-present key', ->
      expect(=> @validator.present('non-present-key'))
        .to.throw().that.has.property('name').that.eq('ValidationError')

    it 'does not throw exception for present key', ->
      expect(=> @validator.present('key'))
        .to.not.throw()

    it 'can test multiple present keys at once', ->
      expect(=> @validator.present('key', 'key2'))
        .to.not.throw()

    it 'can test multiple non-present keys at once and throw ValidationError', ->
      expect(=> @validator.present('key', 'non-present-key', 'key2'))
        .to.throw().that.has.property('name').that.eq('ValidationError')

    it 'can be chained', ->
      expect(=> @validator.present('key').present('key2'))
        .to.not.throw()

    context 'when the value is blank', ->
      beforeEach ->
        @validation = (value) =>
          new @Validator({ key: value }).present('key')

      it 'throws ValidationError for empty string value', ->
        expect(=> @validation(''))
          .to.throw().that.has.property('name').that.eq('ValidationError')

      it 'throws ValidationError for null value', ->
        expect(=> @validation(null))
          .to.throw().that.has.property('name').that.eq('ValidationError')

      it 'throws ValidationError for undefined value', ->
        expect(=> @validation(undefined))
          .to.throw().that.has.property('name').that.eq('ValidationError')
