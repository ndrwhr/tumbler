
class Loader
  constructor: ->
    @canvas_ = document.querySelector("#loading-canvas")

    closeLink = document.querySelector(".loading-splash a")
    closeLink.addEventListener("click", @closeLoader_)

    @initializeShapes_()
    @initalizeSounds_()

  closeLoader_: (evt) =>
    evt.preventDefault()
    document.body.classList.remove("loading")
    setTimeout((->
      splash = document.querySelector(".loading-splash")
      splash.parentNode.removeChild(splash)

      new WashingMachine()
    ), 500)

  initializeShapes_: ->
    numSections = 36
    currentAngle = angleStep = ((Math.PI * 2) / numSections)

    @group_ = document.createElementNS("http://www.w3.org/2000/svg", "g")

    while currentAngle < (Math.PI * 2)
      d = 45
      x = 50 + (d * Math.cos(currentAngle))
      y = 50 + (d * Math.sin(currentAngle))

      shape = @generateRandomShape_(x, y)
      @group_.appendChild(shape)

      currentAngle += angleStep

    animation = document.createElementNS("http://www.w3.org/2000/svg",
      "animateTransform")
    animation.setAttribute("attributeName", "transform")
    animation.setAttribute("type", "rotate")
    animation.setAttribute("from", "0 #{50} #{50}")
    animation.setAttribute("to", "360 #{50} #{50}")
    animation.setAttribute("dur", "300s")
    animation.setAttribute("repeatCount", "indefinite")
    @group_.appendChild(animation)
    @canvas_.appendChild(@group_)

  generateRandomShape_: (x, y) ->
    type = if Math.round(Math.random()) then "circle" else "rect"
    shape = document.createElementNS("http://www.w3.org/2000/svg", type)

    if type is "circle"
      r = Utilities.rand(1, 2)
      shape.setAttribute("r", r)
      shape.setAttribute("cx", x + (-r / 2))
      shape.setAttribute("cy", y + (-r / 2))
    else if type is "rect"
      w = Utilities.rand(1, 3)
      h = Utilities.rand(1, 3)
      shape.setAttribute("width", w)
      shape.setAttribute("height", h)
      shape.setAttribute("x", x + (-w / 2))
      shape.setAttribute("y", y + (-h / 2))

      from = if Math.round(Math.random()) then 360 else 0
      to = 360 - from

      animation = document.createElementNS("http://www.w3.org/2000/svg",
        "animateTransform")
      animation.setAttribute("attributeName", "transform")
      animation.setAttribute("type", "rotate")
      animation.setAttribute("from", "#{from} #{x} #{y}")
      animation.setAttribute("to", "#{to} #{x} #{y}")
      animation.setAttribute("dur", "#{Utilities.rand(15,30)}s")
      animation.setAttribute("repeatCount", "indefinite")
      shape.appendChild(animation)


    r = Utilities.rand(0, 360)
    shape.style.fill = Utilities.randomColor()
    shape.classList.add("hidden")
    shape

  initalizeSounds_: ->
    SoundManager.initialize()
    SoundManager.load() if SoundManager.isSupported
    @showProgress_()

  showProgress_: =>
    if SoundManager.isSupported
      progress = SoundManager.getLoadedProgress()
    else
      progress = 1

    allShapes = @group_.querySelectorAll("rect, circle")
    loadedShapes = @group_.querySelectorAll("rect:not(.hidden),
      circle:not(.hidden)")
    shownProgress = loadedShapes.length / allShapes.length

    if shownProgress < progress
      el = @group_.querySelector("rect.hidden, circle.hidden")
      el.classList.remove("hidden")

    if shownProgress < 1
      setTimeout(@showProgress_, 30)
    else
      @finishedLoading_()

  finishedLoading_: ->
    ul = document.body.querySelector(".loading-splash ol")
    ul.classList.remove("hidden")

window.Loader = Loader