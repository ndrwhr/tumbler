# This global object should contain any hard coded constants used throughout
# the simulation.
window.Config =
  # The scale to be used when converting Box2d co-ordinates to pixels.
  "SCALE": 40

  # The amount of each shape that should be created.
  "NUM_EACH_SHAPE": 30

  # How big the world should be.
  "WORLD_WIDTH": 10
  "WORLD_HALF_WIDTH": 5

  # The speed at which the main drum should rotate.
  "DRUM_ANGULAR_VELOCITY": Math.PI / 3

  # The number of fixtures that should be used to create the drum.
  "NUM_DRUM_SECTIONS": 32

  # The min and max dimensions for the different shapes.
  "MIN_BALL_RADIUS": 0.1
  "MAX_BALL_RADIUS": 0.4
  "MIN_BOX_DIMENSION": 0.1
  "MAX_BOX_DIMENSION": 0.4

  # The min and max step size (in ms) to be used for calculating the physics.
  # The entire simulation will always be run as close as possible to 60fps.
  "MIN_STEP_SIZE": 1/2400
  "MAX_STEP_SIZE": 1/100

  "MIN_AUDIO_PLAYBACK_RATE": 0.15
  "MAX_AUDIO_PLAYBACK_RATE": 0.75

  # The rate at which the simulation should currently be running. This value
  # will be updated whenever the #rate input changes.
  "SIMULATION_RATE": 1

# Calculate the minimum and maximum areas of the different shapes. This will
# be used to choose which sound to play.
Config.MIN_CIRCLE_AREA = Math.min(
  Config.MIN_BALL_RADIUS * Config.MIN_BALL_RADIUS * Math.PI)
Config.MAX_CIRCLE_AREA = Math.max(
  Config.MAX_BALL_RADIUS * Config.MAX_BALL_RADIUS * Math.PI)

Config.MIN_BOX_AREA = Math.min(
  Config.MIN_BOX_DIMENSION * Config.MIN_BOX_DIMENSION)
Config.MAX_BOX_AREA = Math.max(
  Config.MAX_BOX_DIMENSION * Config.MAX_BOX_DIMENSION)

Config.MIN_SHAPE_AREA = Math.min(Config.MIN_CIRCLE_AREA, Config.MIN_BOX_AREA)
Config.MAX_SHAPE_AREA = Math.max(Config.MAX_CIRCLE_AREA, Config.MAX_BOX_AREA)