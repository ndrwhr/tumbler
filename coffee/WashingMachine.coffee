
# Pull out some commonly used objects.
b2Vec2 = Box2D.Common.Math.b2Vec2
b2AABB = Box2D.Collision.b2AABB

rand = (min, max) ->
  (Math.random() * (max - min)) + min

class Box extends Shape
  constructor: (options) ->
    super(options)

    @width_ = rand(Config.MIN_BOX_DIMENSION, Config.MAX_BOX_DIMENSION)
    @height_ = rand(Config.MIN_BOX_DIMENSION, Config.MAX_BOX_DIMENSION)
    @area_ = @width_ * @height_

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

class Ball extends Shape
  constructor: (options) ->
    super(options)

    @radius_ = rand(Config.MIN_BALL_RADIUS, Config.MAX_BALL_RADIUS)

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


class WashingMachine
  constructor: (options) ->
    @world_ = new Box2D.Dynamics.b2World(new b2Vec2(0, 9), true)

    @contactListener_ = new Box2D.Dynamics.b2ContactListener()
    @contactListener_.BeginContact = @onContactStart_
    @contactListener_.EndContact = @onContactEnd_

    @world_.SetContactListener(@contactListener_);

    @svg_ = document.querySelector("#main-canvas")

    @populateItems_()

    fixtureDef = new Box2D.Dynamics.b2FixtureDef()
    fixtureDef.density = 1.0
    fixtureDef.friction = 1.0
    fixtureDef.restitution = 0.1
    fixtureDef.shape = new Box2D.Collision.Shapes.b2PolygonShape()

    bodyDef = new Box2D.Dynamics.b2BodyDef()
    bodyDef.type = Box2D.Dynamics.b2Body.b2_kinematicBody
    bodyDef.position.x = 5;
    bodyDef.position.y = 5;

    body = @world_.CreateBody(bodyDef)
    body.SetAngularVelocity(Math.PI / 3)

    RADIUS = 5
    ANGLE = (Math.PI * 2) / 32
    WIDTH = RADIUS * Math.sin(ANGLE)
    angle = 0

    while angle < (Math.PI * 2)
      fixtureDef.shape.SetAsOrientedBox(0.1, WIDTH / 2, new b2Vec2(RADIUS * Math.cos(angle), RADIUS * Math.sin(angle)), angle)
      body.CreateFixture(fixtureDef)
      angle += ANGLE

    frame = =>
      @update_()
      requestAnimationFrame(frame)
    frame()

  populateItems_: =>
    @items_ = []
    for i in [1..30]
      @items_.push(new Ball(
          world: @world_
          svg: @svg_
        ))
      @items_.push(new Box(
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
    minFramerate = 1/2400
    maxFramerate = 1/100

    framerate = (parseFloat(window.input.value) * (maxFramerate - minFramerate)) + minFramerate

    @world_.Step(framerate, 5, 5)

    for item in @items_
      item.draw()

    @world_.ClearForces()

window.WashingMachine = WashingMachine
