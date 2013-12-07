
MAX_VELOCITY = 10.0;

class Shape
  constructor: (options) ->
    @world_ = options.world

    @fixtureDef_ = new Box2D.Dynamics.b2FixtureDef()
    @fixtureDef_.density = 1.0
    @fixtureDef_.friction = 0.9
    @fixtureDef_.restitution = 0.3

    @bodyDef_ = new Box2D.Dynamics.b2BodyDef()
    @bodyDef_.type = Box2D.Dynamics.b2Body.b2_dynamicBody

    # Generate a random position inside the radius. This is needed so that
    # all the balls don't just pile up in the middle and explode outwards.
    # Explode is probably too dramatic of a word.
    t = Math.random() * Math.PI * 2
    u = Math.random() + Math.random()
    r = 3 * (if u > 1 then 2 - u else u)
    @bodyDef_.position.x = Config.WORLD_HALF_WIDTH + r * Math.cos(t)
    @bodyDef_.position.y = Config.WORLD_HALF_WIDTH + r * Math.sin(t)

    @contacts_ = ''
    @color_ = @generateRandomColor_()
    @id = @generateId_()
    @sound_ = @generateRandomSound_()

  startContact: (otherContactId, relVelocity) ->
    if @contacts_.indexOf isnt -1
      @contacts_ += otherContactId

      if MAX_VELOCITY and relVelocity
        @sound_.play(relVelocity / MAX_VELOCITY)

  endContact: (otherContactId) ->
    @contacts_.replace(otherContactId, '')

  bindPhysics_: ->
    @body_ = @world_.CreateBody(@bodyDef_)
    @body_.SetUserData(@)
    @fixture_ = @body_.CreateFixture(@fixtureDef_)

  generateRandomColor_: ->
    allColors = ["#3498DB", "#2980B9", "#1abc9c", "#16a085", "#2ECC71",
      "#27AE60", "#9B59B6", "#8E44AD", "#8E44AD", "#2C3E50", "#F1C40F",
      "#F39C12", "#E67E22", "#D35400", "#E74C3C", "#C0392B", "#ECF0F1",
      "#BDC3C7", "#95A5A6", "#7F8C8D"]

    allColors[Math.floor(Math.random() * allColors.length)]

  generateRandomSound_: ->
    sounds = 'abcdefghij'
    SoundLoader.createSound(sounds.charAt(Math.floor(sounds.length * Math.random())))

  generateId_: ->
    Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)

window.Shape = Shape