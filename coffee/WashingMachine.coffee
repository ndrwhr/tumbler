
class WashingMachine
  constructor: (options) ->
    @svg_ = document.querySelector("#main-canvas")

    @initializeWorld_()
    @initializeDrum_()
    @initializeShapes_()

    @requestFrame_()

  initializeWorld_: ->
    gravity = new Box2D.Common.Math.b2Vec2(0, 9)
    @world_ = new Box2D.Dynamics.b2World(gravity, true)

    # Only initialize contact listeners if the users browser supports the
    # web audio api.
    if SoundManager.isSupported
      contactListener = new Box2D.Dynamics.b2ContactListener()
      contactListener.BeginContact = @onContactStart_
      @world_.SetContactListener(contactListener)

  initializeDrum_: ->
    drumBodyDef = new Box2D.Dynamics.b2BodyDef()
    drumBodyDef.type = Box2D.Dynamics.b2Body.b2_kinematicBody
    drumBodyDef.position.x = Config.WORLD_HALF_WIDTH
    drumBodyDef.position.y = Config.WORLD_HALF_WIDTH
    drumBody = @world_.CreateBody(drumBodyDef)
    drumBody.SetAngularVelocity(Config.DRUM_ANGULAR_VELOCITY)

    # Define the common fixture to be used by all of the sections.
    fixtureDef = new Box2D.Dynamics.b2FixtureDef()
    fixtureDef.density = 1.0
    fixtureDef.friction = 1.0
    fixtureDef.restitution = 0.1
    fixtureDef.shape = new Box2D.Collision.Shapes.b2PolygonShape()

    currentAngle = 0
    angleStep = (Math.PI * 2) / Config.NUM_DRUM_SECTIONS
    sectionWidth = Config.WORLD_HALF_WIDTH * Math.sin(angleStep)

    while currentAngle < (Math.PI * 2)
      initialPosition = new Box2D.Common.Math.b2Vec2(
        Config.WORLD_HALF_WIDTH * Math.cos(currentAngle),
        Config.WORLD_HALF_WIDTH * Math.sin(currentAngle))

      fixtureDef.shape.SetAsOrientedBox(0.1, sectionWidth / 2, initialPosition,
        currentAngle)

      drumBody.CreateFixture(fixtureDef)

      currentAngle += angleStep

  initializeShapes_: ->
    @shapes_ = []
    for i in [1..Config.NUM_EACH_SHAPE]
      @shapes_.push(new Ball(
          world: @world_
          svg: @svg_
        ))
      @shapes_.push(new Box(
          world: @world_
          svg: @svg_
        ))

  onContactStart_: (contact) =>
    # Don't do anything if the contacts aren't actually touching.
    return if not contact.IsTouching()

    worldManifold = new Box2D.Collision.b2WorldManifold()
    contact.GetWorldManifold(worldManifold)

    bodyA = contact.GetFixtureA().GetBody()
    userDataA = bodyA.GetUserData()
    bodyB = contact.GetFixtureB().GetBody()
    userDataB = bodyB.GetUserData()

    aVel = bodyA.GetLinearVelocityFromWorldPoint(worldManifold.m_points[0])
    bVel = bodyB.GetLinearVelocityFromWorldPoint(worldManifold.m_points[0])
    aVel.Subtract(bVel)
    relVelocity = aVel.Length()

    userDataA.playSound(relVelocity) if userDataA
    userDataB.playSound(relVelocity) if userDataB

  requestFrame_: =>
    stepSize = Utilities.range(Config.MIN_STEP_SIZE, Config.MAX_STEP_SIZE,
      Config.SIMULATION_RATE)

    @world_.Step(stepSize, 5, 5)

    for shape in @shapes_
      shape.draw()

    @world_.ClearForces()
    requestAnimationFrame(@requestFrame_)

window.WashingMachine = WashingMachine
