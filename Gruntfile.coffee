module.exports = (grunt) ->
  
  grunt.task.loadTasks 'gruntcomponents/tasks'
  grunt.task.loadNpmTasks 'grunt-contrib-coffee'
  grunt.task.loadNpmTasks 'grunt-contrib-watch'
  grunt.task.loadNpmTasks 'grunt-contrib-concat'
  grunt.task.loadNpmTasks 'grunt-contrib-uglify'

  grunt.initConfig

    pkg: grunt.file.readJSON('package.json')
    banner: """
      /*! <%= pkg.name %> (<%= pkg.repository.url %>)
       * lastupdate: <%= grunt.template.today("yyyy-mm-dd") %>
       * version: <%= pkg.version %>
       * author: <%= pkg.author %>
       * License: MIT */
      
      """

    growl:

      ok:
        title: 'COMPLETE!!'
        msg: '＼(^o^)／'

    coffee:

      libself:
        src: [ 'jquery.imgenterloader.coffee' ]
        dest: 'jquery.imgenterloader.js'

    concat:

      banner:
        options:
          banner: '<%= banner %>'
        src: [ '<%= coffee.libself.dest %>' ]
        dest: '<%= coffee.libself.dest %>'
        
    uglify:

      options:
        banner: '<%= banner %>'
      libself:
        src: '<%= concat.banner.dest %>'
        dest: 'jquery.imgenterloader.min.js'

    watch:

      libself:
        files: '<%= coffee.libself.src %>'
        tasks: [
          'default'
        ]

  grunt.registerTask 'default', [
    'coffee'
    'concat'
    'uglify'
    'growl:ok'
  ]

