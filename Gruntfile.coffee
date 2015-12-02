path = require "path"

LIVERELOAD_PORT = 35729
LIVERELOAD_TEST_PORT = 35730

module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"
    watch:
      options:
        livereload: true
      haxe:
        files: [
          "app/src/**/*.hx"
          "app/lib/**/*.hx"
        ]
        tasks: [
          "haxe:build"
        ]
      haxeTest:
        files: [
          "app/tests/**/*.hx"
        ]
        tasks: [
          "haxe:test"
        ]
      stylus:
        files: [
          "public/styl/*.styl"
        ]
        tasks: [
          "stylus:build"
        ]
      js:
        files: [
          "public/js/main.js"
        ]
      livereload:
        options:
          livereload: LIVERELOAD_PORT
        files: [
          "public/js/main.js"
          "public/css/main.css"
          "public/index.html"
        ]
      livereloadTest:
        options:
          livereload: LIVERELOAD_TEST_PORT
        files: [
          "app/tests/test.js"
        ]
    haxe:
      build:
        main: "Main"
        libs: [
          "createjs"
          "jQueryExtern"
        ]
        classpath: ["app/lib","app/src"]
        misc: ["-debug"]
        output: "public/js/main.js"
      test:
        main: "TestMain"
        libs: [
          "createjs"
          "jQueryExtern"
        ]
        classpath: ["app/lib","app/src","app/tests"]
        output: "app/tests/test.js"
    stylus:
      build:
        files:
          "public/css/main.css": ["public/styl/*.styl"]
    bower_concat:
      dist:
        dest: "public/js/bower.js"
        cssDest: "public/css/bower.css"
    cssmin:
      target:
        files:
          "public/css/bower.css": ["public/css/bower.css"]
    uglify:
      options:
        compress:
          dead_code: true
      dist:
        files: [
          "public/js/bower.js": [
            "public/js/bower.js"
          ]
        ]
    copy:
      font:
        expand: true
        cwd: "bower_components/materialize/"
        src: "font/**"
        dest: "public/"
        fileter: "isFile"

  grunt.loadNpmTasks "grunt-haxe"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-stylus"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-cssmin"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-bower-concat"
  grunt.registerTask "build", ["bower_concat", "stylus", "copy"]
  grunt.registerTask "dest", ["build", "uglify", "cssmin"]
  grunt.registerTask "default", ["haxe", "build", "watch"]
