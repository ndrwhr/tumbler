module.exports = (grunt) ->
  grunt.initConfig(
    pkg: grunt.file.readJSON('package.json')
    coffee:
      index:
        options:
          # Join first before wrapping.
          join: false
        files:
          'js/index.js': [
            # Load the Shape module first as it gets extended.
            'coffee/Shape.coffee'

            # Then load everything else.
            'coffee/*.coffee'

            # Load the content.coffee file last as it boots the Application.
            'coffee/index.coffee'
          ]

    autoprefixer:
      options:
        someth: true
        browsers: ["> 1%", "last 2 versions", "ff 24", "opera 12.1"]
        # browsers: ['last 1 version', 'ff 24', 'opera 12.1']
      main:
        src: 'css/main.css'
        dest: 'css/main-processed.css'

    watch:
      options:
        atBegin: true

      coffee:
        files: ['coffee/**/*.coffee']
        tasks: ['coffee']
      css:
        files: ['css/main.css']
        tasks: ['autoprefixer']
  )

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-autoprefixer')

  grunt.registerTask('default', [
    'watch'
  ])