
SoundManager =
  buffers_: {}
  load: (options) ->
    AudioContext = (window.AudioContext or window.webkitAudioContext)
    @context_ = new AudioContext()
    @masterGainNode_ = @context_.createGainNode()
    @masterGainNode_.gain.value = 1
    @compressorNode_ = @context_.createDynamicsCompressor()
    @convolverNode_ = @context_.createConvolver()

    for soundName in Object.keys(options.sounds)
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
        if name == "convolver"
          @convolverNode_.buffer = buffer
        else
          @buffers_[name] = buffer
      , ->
          console.error('Unable to load ' + file);
      );
    request.send();

# export the class.
window.SoundManager = SoundManager