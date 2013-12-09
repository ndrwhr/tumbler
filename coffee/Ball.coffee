class Ball extends Shape
  draw: () ->
    position = @body_.GetPosition()
    x = position.x * Config.SCALE
    y = position.y * Config.SCALE

    @svgShape_.setAttribute("transform", "translate(#{x}, #{y})")

  initializeDimensions_: ->
    @radius_ = Utilities.rand(Config.MIN_BALL_RADIUS, Config.MAX_BALL_RADIUS)
    @area_ = @radius_ * @radius_ * Math.PI

  initializeSVGElement_: (svgParent) ->
    @svgShape_ = document.createElementNS("http://www.w3.org/2000/svg",
      "circle")
    @svgShape_.setAttribute("r", @radius_ * Config.SCALE)
    @svgShape_.style.fill = @color_
    svgParent.appendChild(@svgShape_)

  initializeSoundName_: ->
    scale = (@area_ - Config.MIN_CIRCLE_AREA) /
      (Config.MAX_CIRCLE_AREA - Config.MIN_CIRCLE_AREA)
    scale = Math.round(scale * 11).toString()

    @soundName_ = "glock-#{scale}"

  initializeFixture_: (fixtureDef) ->
    fixtureDef.shape = new Box2D.Collision.Shapes.b2CircleShape(@radius_)

window.Ball = Ball