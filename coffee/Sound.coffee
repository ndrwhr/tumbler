
class Sound
  constructor: (options) ->
    @context_ = options.context
    @soundName_ = options.soundName


    @source_ = @context_.createBufferSource()


  play: (gain)->
    buffer = SoundLoader.getBuffer(@soundName_)
    return if not buffer

    gain = Math.max(Math.min(gain * gain ? 1, 1), 0)
    @gainNode_ = @context_.createGain()
    @gainNode_.gain.value = gain

    source = @context_.createBufferSource()
    source.buffer = buffer
    source.connect(@gainNode_)
    @gainNode_.connect(@context_.destination)

    minRate = 0.5
    maxRate = 1

    source.playbackRate.value =(parseFloat(window.input.value) * (maxRate - minRate)) + minRate

    source.start(0)

window.Sound = Sound