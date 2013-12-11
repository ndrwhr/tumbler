
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
  SoundManager.initialize()
  window.washingMachine = new WashingMachine()

  audioType = if Modernizr.audio.ogg then "ogg" else (
    if Modernizr.audio.mp3 then "mp3" else "wav")

  SoundManager.load(
    sounds:
      "convolver": "dining-living-true-stereo.mp3"

      "glock-0": "glockenspiel/#{audioType}/f7.#{audioType}"
      "glock-1": "glockenspiel/#{audioType}/e7.#{audioType}"
      "glock-2": "glockenspiel/#{audioType}/d7.#{audioType}"
      "glock-3": "glockenspiel/#{audioType}/c7.#{audioType}"
      "glock-4": "glockenspiel/#{audioType}/b6.#{audioType}"
      "glock-5": "glockenspiel/#{audioType}/a6.#{audioType}"
      "glock-6": "glockenspiel/#{audioType}/g6.#{audioType}"
      "glock-7": "glockenspiel/#{audioType}/f6.#{audioType}"
      "glock-8": "glockenspiel/#{audioType}/e6.#{audioType}"
      "glock-9": "glockenspiel/#{audioType}/d6.#{audioType}"
      "glock-10":"glockenspiel/#{audioType}/c6.#{audioType}"

    onProgress: (progress) ->
      console.log(progress)
  )

  document.querySelector('#rate').addEventListener('change', (evt) ->
    Config.SIMULATION_RATE = parseFloat(evt.target.value)
  )

  document.querySelector('#mute').addEventListener('change', (evt) ->
    SoundManager.mute(evt.target.checked)
  )
)