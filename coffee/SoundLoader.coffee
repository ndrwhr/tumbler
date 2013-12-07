
SoundLoader =
  buffers_: {}
  load: (options) ->
    AudioContext = (window.AudioContext or window.webkitAudioContext)
    @context_ = new AudioContext()

    for soundName in Object.keys(options.sounds)
      @loadSound_(soundName, '/sounds/' + options.sounds[soundName])

  createSound: (soundName) ->
    new Sound(
      context: @context_
      soundName: soundName)

  getBuffer: (soundName) ->
    @buffers_[soundName]

  loadSound_: (name, file) ->
    request = new XMLHttpRequest()
    request.open('GET', file, true)
    request.responseType = 'arraybuffer'

    request.onload = =>
      @context_.decodeAudioData(request.response, (buffer) =>
          @buffers_[name] = buffer
          console.log('loaded', file)
      , ->
          console.error('Unable to load ' + file);
      );
    request.send();

# export the class.
window.SoundLoader = SoundLoader