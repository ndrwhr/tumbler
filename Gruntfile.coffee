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
            'coffee/*.coffee',

            # Load the content.coffee file last as it boots the Application.
            'coffee/index.coffee'
          ]

    watch:
      options:
        atBegin: true
      files: ['coffee/**/*.coffee']
      tasks: ['coffee']
  )

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
