# Just some helpful utility functions.
window.Utilities =
  # Returns a scaled number between min and max.
  range: (min, max, scale) ->
    (scale * (max - min)) + min

  # Returns a random number in the range of [min, max).
  rand: (min, max) ->
    (Math.random() * (max - min)) + min