
class Box extends Shape
  draw: () ->
    position = @body_.GetPosition()
    x = position.x * Config.SCALE
    y = position.y * Config.SCALE
    r = @body_.GetAngle() * 180 / Math.PI

    @svgShape_.setAttribute("transform", "translate(#{x}, #{y}) rotate(#{r})")

  initializeDimensions_: ->
    @width_ = Utilities.rand(Config.MIN_BOX_DIMENSION,
      Config.MAX_BOX_DIMENSION)
    @height_ = Utilities.rand(Config.MIN_BOX_DIMENSION,
      Config.MAX_BOX_DIMENSION)
    @area_ = @width_ * @height_

  initializeSVGElement_: (svgParent) ->
    @svgShape_ = document.createElementNS("http://www.w3.org/2000/svg", "rect")
    @svgShape_.setAttribute("width", @width_ * Config.SCALE * 2)
    @svgShape_.setAttribute("height", @height_ * Config.SCALE * 2)
    @svgShape_.setAttribute("x", -@width_ * Config.SCALE)
    @svgShape_.setAttribute("y", -@height_ * Config.SCALE)
    @svgShape_.style.fill = @color_
    svgParent.appendChild(@svgShape_)

  initializeFixture_: (fixtureDef) ->
    fixtureDef.shape = new Box2D.Collision.Shapes.b2PolygonShape()
    fixtureDef.shape.SetAsBox(@width_, @height_)

window.Box = Box