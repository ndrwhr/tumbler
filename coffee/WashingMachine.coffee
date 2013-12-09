
# Pull out some commonly used objects.
b2Vec2 = Box2D.Common.Math.b2Vec2
b2AABB = Box2D.Collision.b2AABB

class Box extends Shape
  constructor: (options) ->
    @width_ = Utilities.rand(Config.MIN_BOX_DIMENSION,
      Config.MAX_BOX_DIMENSION)
    @height_ = Utilities.rand(Config.MIN_BOX_DIMENSION,
      Config.MAX_BOX_DIMENSION)
    @area_ = @width_ * @height_

    super(options)

    @svgShape_ = document.createElementNS("http://www.w3.org/2000/svg", "rect")
    @svgShape_.setAttribute("width", @width_ * Config.SCALE * 2)
    @svgShape_.setAttribute("height", @height_ * Config.SCALE * 2)
    @svgShape_.setAttribute("x", -@width_ * Config.SCALE)
    @svgShape_.setAttribute("y", -@height_ * Config.SCALE)
    @svgShape_.style.fill = @color_

    options.svg.appendChild(@svgShape_)

    @fixtureDef_.shape = new Box2D.Collision.Shapes.b2PolygonShape()
    @fixtureDef_.shape.SetAsBox(@width_, @height_)

    @bindPhysics_()

  draw: () ->
    position = @body_.GetPosition()
    x = position.x * Config.SCALE
    y = position.y * Config.SCALE
    r = @body_.GetAngle() * 180 / Math.PI

    w = @width_ * Config.SCALE
    h = @height_ * Config.SCALE

    @svgShape_.setAttribute("transform", "translate(#{x}, #{y}) rotate(#{r})")

  generateRandomSound_: ->
    scale = (@area_ - Config.MIN_BOX_AREA) /
      (Config.MAX_BOX_AREA - Config.MIN_BOX_AREA)
    scale = Math.round(scale * 11).toString()

    SoundLoader.createSound("glock-#{scale}")

class Ball extends Shape
  constructor: (options) ->
    @radius_ = Utilities.rand(Config.MIN_BALL_RADIUS, Config.MAX_BALL_RADIUS)
    @area_ = @radius_ * @radius_ * Math.PI

    super(options)

    @svgShape_ = document.createElementNS("http://www.w3.org/2000/svg",
      "circle")
    @svgShape_.setAttribute("r", @radius_ * Config.SCALE)
    @svgShape_.style.fill = @color_

    options.svg.appendChild(@svgShape_)

    @fixtureDef_.shape = new Box2D.Collision.Shapes.b2CircleShape(@radius_)

    @bindPhysics_()

  draw: () ->
    position = @body_.GetPosition()
    x = position.x * Config.SCALE
    y = position.y * Config.SCALE

    @svgShape_.setAttribute("transform", "translate(#{x}, #{y})")

  generateRandomSound_: ->
    scale = (@area_ - Config.MIN_CIRCLE_AREA) /
      (Config.MAX_CIRCLE_AREA - Config.MIN_CIRCLE_AREA)
    scale = Math.round(scale * 11).toString()

    SoundLoader.createSound("glock-#{scale}")


class WashingMachine
  constructor: (options) ->
    @svg_ = document.querySelector("#main-canvas")

    @initializeWorld_()
    @createDrumContainer_()
    @createShapes_()

    frame = =>
      @update_()
      requestAnimationFrame(frame)
    frame()

  initializeWorld_: ->
    gravity = new b2Vec2(0, 9)
    @world_ = new Box2D.Dynamics.b2World(gravity, true)

    @contactListener_ = new Box2D.Dynamics.b2ContactListener()
    @contactListener_.BeginContact = @onContactStart_
    @contactListener_.EndContact = @onContactEnd_

    @world_.SetContactListener(@contactListener_)

  createDrumContainer_: ->
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
      initialPosition = new b2Vec2(
        Config.WORLD_HALF_WIDTH * Math.cos(currentAngle),
        Config.WORLD_HALF_WIDTH * Math.sin(currentAngle))

      fixtureDef.shape.SetAsOrientedBox(0.1, sectionWidth / 2, initialPosition,
        currentAngle)

      drumBody.CreateFixture(fixtureDef)

      currentAngle += angleStep

  createShapes_: =>
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
    return if not contact.IsTouching()

    worldManifold = new Box2D.Collision.b2WorldManifold()
    contact.GetWorldManifold(worldManifold)

    bodyA = contact.GetFixtureA().GetBody()
    userDataA = bodyA.GetUserData()
    bodyB = contact.GetFixtureB().GetBody()
    userDataB = bodyB.GetUserData()

    if userDataA and userDataB
      aVel = bodyA.GetLinearVelocityFromWorldPoint(worldManifold.m_points[0])
      bVel = bodyB.GetLinearVelocityFromWorldPoint(worldManifold.m_points[0])
      aVel.Subtract(bVel)
      relVelocity = aVel.Length()
      userDataA.startContact(userDataB.id, relVelocity)
      userDataB.startContact(userDataA.id, relVelocity)

  onContactEnd_: (contact) =>
    return if not contact.IsTouching()

    userDataA = contact.GetFixtureA().GetBody().GetUserData()
    userDataB = contact.GetFixtureB().GetBody().GetUserData()

    if userDataA and userDataB
      userDataA.endContact(userDataB.id)
      userDataB.endContact(userDataA.id)

  update_: =>
    stepSize = Utilities.range(Config.MIN_STEP_SIZE, Config.MAX_STEP_SIZE,
      parseFloat(window.input.value))

    @world_.Step(stepSize, 5, 5)

    for shape in @shapes_
      shape.draw()

    @world_.ClearForces()

window.WashingMachine = WashingMachine
