
SoundManager =
  initialize: ->
    this.patchWindow_();

    @isSupported = Modernizr.webaudio

    @context_ = new AudioContext()
    @masterGainNode_ = @context_.createGain()
    @masterGainNode_.gain.value = 1
    @compressorNode_ = @context_.createDynamicsCompressor()
    @convolverNode_ = @context_.createConvolver()
    @buffers_ = {}
    @loadingProgress_ = 0

  load: () ->
    audioType = if Modernizr.audio.ogg then "ogg" else (
      if Modernizr.audio.mp3 then "mp3" else "wav")

    sounds =
      "convolver": "dining-living-true-stereo.#{audioType}"

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

    @buffers_ = {}
    @buffersToLoad_ = Object.keys(sounds)
    for soundName in @buffersToLoad_
      @loadSound_(soundName, 'sounds/' + sounds[soundName])

  # Simple getter for the AudioContext object.
  getContext: ->
    @context_

  mute: (doit) ->
    @masterGainNode_.gain.value = if doit then 0 else 1

  getLoadedProgress: ->
    return if @isSupported then @loadingProgress_ else 1

  createBufferSource: ->
    source = @context_.createBufferSource()
    source.playbackRate.value = Utilities.range(Config.MIN_AUDIO_PLAYBACK_RATE,
      Config.MAX_AUDIO_PLAYBACK_RATE, Config.SIMULATION_RATE)
    source

  connectToDestination: (node) ->
    if @convolverNode_.buffer
      node.connect(@convolverNode_)
      node = @convolverNode_
    else
      # If we can't load the convolver then everything sounds terrible. Might
      # as well leave the user in silence.
      return

    node.connect(@masterGainNode_)
    @masterGainNode_.connect(@compressorNode_)
    @compressorNode_.connect(@context_.destination)

  getBuffer: (soundName) ->
    @buffers_[soundName]

  # Patch inconsistencies between the old webkit api and the new standard api.
  #
  # THANKS OBAMA!
  patchWindow_: ->
    # Treat all context's equally.
    window.AudioContext = (window.AudioContext or window.webkitAudioContext)

    # An object that contains mappings from the old webkit API over to the new
    # standard API for certain objects.
    patches =
      "AudioContext":
        "createGain": "createGainNode"
      "AudioBufferSourceNode":
        "start": "noteOn"
        "off": "noteOff"

    for objectName in Object.keys(patches)
      objPatches = patches[objectName]
      for standardMethod in Object.keys(objPatches)
        oldMethod = objPatches[standardMethod]
        if not window[objectName][standardMethod]
          window[objectName][standardMethod] = window[objectName][oldMethod]

  loadSound_: (name, file) ->
    request = new XMLHttpRequest()
    request.open('GET', file, true)
    request.responseType = 'arraybuffer'

    request.onload = =>
      @context_.decodeAudioData(request.response, (buffer) =>
        @saveBuffer_(name, buffer)
      )

    request.send();

  saveBuffer_: (name, buffer) ->
    @buffers_[name] = buffer

    if name == "convolver"
      @convolverNode_.buffer = buffer

    @loadingProgress_ = Object.keys(@buffers_).length / @buffersToLoad_.length

# export the class.
window.SoundManager = SoundManager