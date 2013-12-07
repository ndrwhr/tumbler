
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
  SoundLoader.load(
    sounds:
      'a': '58687__arioke__kalimba-lam07-g3-nail-soft.wav'
      'b': '58691__arioke__kalimba-lam09-bb3-nail-soft.wav'
      'c': '58692__arioke__kalimba-lam10-c4-nail-med.wav'
      'd': '58695__arioke__kalimba-lam11-d4-nail-soft.wav'
      'e': '58712__arioke__kalimba-lam09-bb3-tip-med.wav'
      'f': '58715__arioke__kalimba-lam10-c4-tip-soft.wav'
      'g': '58716__arioke__kalimba-lam11-d4-tip-med.wav'
      'h': '58717__arioke__kalimba-lam11-d4-tip-soft.wav'
      'i': '58737__arioke__kalimba-lam10-c4-wipe-soft.wav'
      'j': '58739__arioke__kalimba-lam11-d4-wipe-soft.wav'
  )

  window.input = document.querySelector('input')
  window.washingMachine = new WashingMachine()
)