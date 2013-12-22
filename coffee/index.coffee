
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
  new Loader()

  document.querySelector('#rate').addEventListener('change', (evt) ->
    Config.SIMULATION_RATE = parseFloat(evt.target.value)
  )

  muteButton = document.querySelector('#mute')
  if SoundManager.isSupported
    muteButton.addEventListener('change', (evt) ->
      SoundManager.mute(evt.target.checked)
    )
  else
    muteButton.checked = muteButton.disabled = true
    document.querySelector('#mute + label').title =
      "Audio requires the Web Audio API which your browser does not support."
)