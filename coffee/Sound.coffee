
class Sound
  constructor: (options) ->
    @soundName_ = options.soundName
    @context_ = options.context
    @gainNode_ = @context_.createGain()
    @compressorNode_ = @context_.createDynamicsCompressor()

  play: (gain)->
    buffer = SoundLoader.getBuffer(@soundName_)
    return if not buffer

    @source_.stop(0) if @source_

    gain = Math.max(Math.min(gain * gain ? 1, 1), 0)
    @gainNode_.gain.value = gain / 10

    @source_ = SoundLoader.createBufferSource()
    @source_.buffer = buffer
    @source_.connect(@gainNode_)

    # Actually hook up the sound to the destination.
    SoundLoader.connectToDestination(@gainNode_)

    @source_.start(0)

window.Sound = Sound