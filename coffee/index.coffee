
# A CoffeeScript version of Paul Irish's requestAnimationFrame polyfill.
do ->
  w = window
  for vendor in ['ms', 'moz', 'webkit', 'o']
    break if w.requestAnimationFrame
    w.requestAnimationFrame = w["#{vendor}RequestAnimationFrame"]
    w.cancelAnimationFrame = (w["#{vendor}CancelAnimationFrame"] or
                  w["#{vendor}CancelRequestAnimationFrame"])

  # deal with the case where rAF is built in but cAF is not.
  if w.requestAnimationFrame
    return if w.cancelAnimationFrame
    browserRaf = w.requestAnimationFrame
    canceled = {}
    w.requestAnimationFrame = (callback) ->
      id = browserRaf (time) ->
        if id of canceled then delete canceled[id]
        else callback time
    w.cancelAnimationFrame = (id) -> canceled[id] = true

  # handle legacy browsers which don’t implement rAF
  else
    targetTime = 0
    w.requestAnimationFrame = (callback) ->
      targetTime = Math.max targetTime + 16, currentTime = +new Date
      w.setTimeout (-> callback +new Date), targetTime - currentTime

    w.cancelAnimationFrame = (id) -> clearTimeout id

window.addEventListener('DOMContentLoaded', ->
  SoundManager.load(
    sounds:
      "convolver": "dining-living-true-stereo.mp3"

      "glock-0": "glockenspiel/mp3/f7.mp3"
      "glock-1": "glockenspiel/mp3/e7.mp3"
      "glock-2": "glockenspiel/mp3/d7.mp3"
      "glock-3": "glockenspiel/mp3/c7.mp3"
      "glock-4": "glockenspiel/mp3/b6.mp3"
      "glock-5": "glockenspiel/mp3/a6.mp3"
      "glock-6": "glockenspiel/mp3/g6.mp3"
      "glock-7": "glockenspiel/mp3/f6.mp3"
      "glock-8": "glockenspiel/mp3/e6.mp3"
      "glock-9": "glockenspiel/mp3/d6.mp3"
      "glock-10":"glockenspiel/mp3/c6.mp3"
  )

  window.input = document.querySelector('input')
  window.washingMachine = new WashingMachine()
)