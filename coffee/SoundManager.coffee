
SoundManager =
  buffers_: {}
  load: (options) ->
    AudioContext = (window.AudioContext or window.webkitAudioContext)
    @context_ = new AudioContext()
    @masterGainNode_ = @context_.createGainNode()
    @masterGainNode_.gain.value = 1
    console.log(@masterGainNode_.gain.value)
    @compressorNode_ = @context_.createDynamicsCompressor()
    @convolverNode_ = @context_.createConvolver()

    for soundName in Object.keys(options.sounds)
      @loadSound_(soundName, '/sounds/' + options.sounds[soundName])

  createSound: (soundName) ->
    new Sound(
      context: @context_
      soundName: soundName)

  createBufferSource: ->
    minRate = 0.25
    maxRate = 0.75
    source = @context_.createBufferSource()
    source.playbackRate.value =(parseFloat(window.input.value) * (maxRate - minRate)) + minRate
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