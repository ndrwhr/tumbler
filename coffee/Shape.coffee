
MAX_VELOCITY = 20.0;

class Shape
  constructor: (options) ->
    # Initialize all the physic components.
    @initializeDimensions_()

    fixtureDef = new Box2D.Dynamics.b2FixtureDef()
    fixtureDef.density = 1.0
    fixtureDef.friction = 0.9
    fixtureDef.restitution = 0.3
    @initializeFixture_(fixtureDef)

    bodyDef = new Box2D.Dynamics.b2BodyDef()
    bodyDef.type = Box2D.Dynamics.b2Body.b2_dynamicBody

    # Generate a random position inside the radius. This is needed so that
    # all the balls don't just pile up in the middle and explode outwards.
    # Explode is probably too dramatic of a word.
    t = Math.random() * Math.PI * 2
    u = Math.random() + Math.random()
    r = 3 * (if u > 1 then 2 - u else u)
    bodyDef.position.x = Config.WORLD_HALF_WIDTH + r * Math.cos(t)
    bodyDef.position.y = Config.WORLD_HALF_WIDTH + r * Math.sin(t)

    @body_ = options.world.CreateBody(bodyDef)
    @body_.CreateFixture(fixtureDef)
    @body_.SetUserData(@)

    # Initialize the the audio components.
    @initializeSoundName_()
    context = SoundManager.getContext()
    @gainNode_ = context.createGain()
    @pannerNode_ = context.createPanner()
    @pannerNode_.panningModel = "equalpower"
    @pannerNode_.setPosition(0, 0, 0)

    # Finally, initialize the SVG element that will represent this object.
    @initializeColor_()
    @initializeSVGElement_(options.svg)

  initializeColor_: ->
    allColors = ["#3498DB", "#2980B9", "#1abc9c", "#16a085", "#2ECC71",
      "#27AE60", "#9B59B6", "#8E44AD", "#8E44AD", "#2C3E50", "#F1C40F",
      "#F39C12", "#E67E22", "#D35400", "#E74C3C", "#C0392B", "#ECF0F1",
      "#BDC3C7", "#95A5A6", "#7F8C8D"]
    @color_ = allColors[Math.floor(Math.random() * allColors.length)]

  initializeDimensions_: ->
    throw "This method must be defined by subclasses!"

  initializeSVGElement_: ->
    throw "This method must be defined by subclasses!"

  initializeSoundName_: ->
    throw "This method must be defined by subclasses!"

  playSound: (relVelocity) ->
    buffer = SoundManager.getBuffer(@soundName_)
    return if not buffer

    @source_.stop(0) if @source_

    gain = relVelocity / MAX_VELOCITY
    gain = Math.max(Math.min(gain * gain, 1), 0)
    @gainNode_.gain.value = gain

    position = @body_.GetPosition()
    x = position.x - Config.WORLD_HALF_WIDTH / Config.WORLD_HALF_WIDTH
    @pannerNode_.setPosition(x, 0, 0)

    @source_ = SoundManager.createBufferSource()
    @source_.buffer = buffer
    @source_.connect(@pannerNode_)
    @pannerNode_.connect(@gainNode_)

    # Actually hook up the sound to the destination.
    SoundManager.connectToDestination(@gainNode_)

    @source_.start(0)

window.Shape = Shape