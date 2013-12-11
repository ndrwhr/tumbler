
SoundManager =
  initialize: ->
    AudioContext = (window.AudioContext or window.webkitAudioContext)
    @context_ = new AudioContext()
    @masterGainNode_ = @context_.createGainNode()
    @masterGainNode_.gain.value = 1
    @compressorNode_ = @context_.createDynamicsCompressor()
    @convolverNode_ = @context_.createConvolver()
    @buffers_ = {}

  load: (options) ->
    @onProgressCallback_ = options.onProgress
    @buffers_ = {}
    @buffersToLoad_ = Object.keys(options.sounds)
    for soundName in @buffersToLoad_
      @loadSound_(soundName, '/sounds/' + options.sounds[soundName])

  # Simple getter for the AudioContext object.
  getContext: ->
    @context_

  mute: (doit) ->
    @masterGainNode_.gain.value = if doit then 0 else 1

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

  loadSound_: (name, file) ->
    request = new XMLHttpRequest()
    request.open('GET', file, true)
    request.responseType = 'arraybuffer'

    request.onload = =>
      @context_.decodeAudioData(request.response, (buffer) =>
        console.log('loaded', file)
        @buffers_[name] = buffer

        if name == "convolver"
          @convolverNode_.buffer = buffer

        @onProgressCallback_(Object.keys(@buffers_).length / @buffersToLoad_.length)
      )
    request.send();

SoundManager.initialize()

# export the class.
window.SoundManager = SoundManager