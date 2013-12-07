
# Pull out some commonly used objects.
b2Vec2 = Box2D.Common.Math.b2Vec2
b2AABB = Box2D.Collision.b2AABB

SCALE = 40

MIN_BALL_RADIUS = 0.1
MAX_BALL_RADIUS = 0.4

MIN_BOX_DIMENSION = 0.1
MAX_BOX_DIMENSION = 0.4

MAX_VELOCITY = 10.0;

rand = (min, max) ->
  (Math.random() * (max - min)) + min

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
    # Explode is probably to dramatic of a word.
    t = Math.random() * Math.PI * 2
    u = Math.random() + Math.random()
    r = 3 * (if u > 1 then 2 - u else u)
    @bodyDef_.position.x = 5 + r * Math.cos(t)
    @bodyDef_.position.y = 5 + r * Math.sin(t)

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

class Box extends Shape
  constructor: (options) ->
    super(options)

    @width_ = rand(MIN_BOX_DIMENSION, MAX_BOX_DIMENSION)
    @height_ = rand(MIN_BOX_DIMENSION, MAX_BOX_DIMENSION)
    @area_ = @width_ * @height_

    @svgShape_ = document.createElementNS("http://www.w3.org/2000/svg", "rect")
    @svgShape_.setAttribute("width", @width_ * SCALE * 2)
    @svgShape_.setAttribute("height", @height_ * SCALE * 2)
    @svgShape_.setAttribute("x", -@width_ * SCALE)
    @svgShape_.setAttribute("y", -@height_ * SCALE)
    @svgShape_.style.fill = @color_

    options.svg.appendChild(@svgShape_)

    @fixtureDef_.shape = new Box2D.Collision.Shapes.b2PolygonShape()
    @fixtureDef_.shape.SetAsBox(@width_, @height_)

    @bindPhysics_()

  draw: () ->
    position = @body_.GetPosition()
    x = position.x * SCALE
    y = position.y * SCALE
    r = @body_.GetAngle() * 180 / Math.PI

    w = @width_ * SCALE
    h = @height_ * SCALE

    @svgShape_.setAttribute("transform", "translate(#{x}, #{y}) rotate(#{r})")

class Ball extends Shape
  constructor: (options) ->
    super(options)

    @radius_ = rand(MIN_BALL_RADIUS, MAX_BALL_RADIUS)

    @svgShape_ = document.createElementNS("http://www.w3.org/2000/svg",
      "circle")
    @svgShape_.setAttribute("r", @radius_ * SCALE)
    @svgShape_.style.fill = @color_

    options.svg.appendChild(@svgShape_)

    @fixtureDef_.shape = new Box2D.Collision.Shapes.b2CircleShape(@radius_)

    @bindPhysics_()

  draw: () ->
    position = @body_.GetPosition()
    x = position.x * SCALE
    y = position.y * SCALE

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
    maxFramerate = 1/60

    framerate = (parseFloat(window.input.value) * (maxFramerate - minFramerate)) + minFramerate

    @world_.Step(framerate, 5, 5)

    for item in @items_
      item.draw()

    @world_.ClearForces()

window.WashingMachine = WashingMachine
