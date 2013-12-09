
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
      "convolver": "dining-living-true-stereo.wav"

      'kalimba-0': '58687__arioke__kalimba-lam07-g3-nail-soft.wav'
      'kalimba-1': '58691__arioke__kalimba-lam09-bb3-nail-soft.wav'
      'kalimba-2': '58692__arioke__kalimba-lam10-c4-nail-med.wav'
      'kalimba-3': '58695__arioke__kalimba-lam11-d4-nail-soft.wav'
      'kalimba-4': '58712__arioke__kalimba-lam09-bb3-tip-med.wav'
      'kalimba-5': '58715__arioke__kalimba-lam10-c4-tip-soft.wav'
      'kalimba-6': '58716__arioke__kalimba-lam11-d4-tip-med.wav'
      'kalimba-7': '58717__arioke__kalimba-lam11-d4-tip-soft.wav'
      'kalimba-8': '58737__arioke__kalimba-lam10-c4-wipe-soft.wav'
      'kalimba-10': '58739__arioke__kalimba-lam11-d4-wipe-soft.wav'


      "glock-0": "glockenspiel/166367__pmedig__glockenspiel-f7.wav"
      "glock-1": "glockenspiel/166363__pmedig__glockenspiel-e7.wav"
      "glock-2": "glockenspiel/166365__pmedig__glockenspiel-d7.wav"
      "glock-3": "glockenspiel/166359__pmedig__glockenspiel-c7.wav"
      "glock-4": "glockenspiel/166361__pmedig__glockenspiel-b6.wav"
      "glock-5": "glockenspiel/166362__pmedig__glockenspiel-a6.wav"
      "glock-6": "glockenspiel/166369__pmedig__glockenspiel-g6.wav"
      "glock-7": "glockenspiel/166368__pmedig__glockenspiel-f6.wav"
      "glock-8": "glockenspiel/166364__pmedig__glockenspiel-e6.wav"
      "glock-9": "glockenspiel/166366__pmedig__glockenspiel-d6.wav"
      "glock-10": "glockenspiel/166360__pmedig__glockenspiel-c6.wav"


      "marimba-0": "bamboo-marimba/130526__stomachache__f-hi-1.wav"
      "marimba-1": "bamboo-marimba/130532__stomachache__d-1.wav"
      "marimba-2": "bamboo-marimba/130528__stomachache__c-1.wav"
      "marimba-3": "bamboo-marimba/130530__stomachache__a1.wav"
      "marimba-4": "bamboo-marimba/130534__stomachache__g1.wav"
      "marimba-5": "bamboo-marimba/130524__stomachache__f-low-1.wav"
  )

  window.input = document.querySelector('input')
  window.washingMachine = new WashingMachine()
)