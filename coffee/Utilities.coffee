# Just some helpful utility functions.
window.Utilities =
  # Returns a scaled number between min and max.
  range: (min, max, scale) ->
    (scale * (max - min)) + min

  # Returns a random number in the range of [min, max).
  rand: (min, max) ->
    (Math.random() * (max - min)) + min

  # Returns a random color.
  randomColor: ->
    allColors = ["#3498DB", "#2980B9", "#1abc9c", "#16a085", "#2ECC71",
      "#27AE60", "#9B59B6", "#8E44AD", "#8E44AD", "#2C3E50", "#F1C40F",
      "#F39C12", "#E67E22", "#D35400", "#E74C3C", "#C0392B", "#ECF0F1",
      "#BDC3C7", "#95A5A6", "#7F8C8D"]
    allColors[Math.floor(Math.random() * allColors.length)]