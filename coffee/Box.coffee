
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

    SoundManager.createSound("glock-#{scale}")

window.Box = Box