path = require "path"

LIVERELOAD_PORT = 35729

module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"
    connect:
      use_defaults: {}
    watch:
      options:
        livereload: true
      haxe:
        files: [
          "src/**/*.hx"
        ]
        tasks: [
          "haxe:build"
        ]
      stylus:
        files: [
          "styl/*.styl"
        ]
        tasks: [
          "stylus:build"
        ]
      js:
        files: [
          "js/main.js"
        ]
        options:
          livereload: true
      livereload:
        options:
          livereload: LIVERELOAD_PORT
        files: [
          "js/main.js"
          "css/main.css"
          "index.html"
        ]
    haxe:
      build:
        main: "Main"
        libs: [
          "createjs"
          "jQueryExtern"
        ]
        classpath: ["src"]
        output: "js/main.js"
    stylus:
      build:
        files:
          "css/main.css": ["styl/*.styl"]


  grunt.loadNpmTasks "grunt-haxe"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-stylus"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.registerTask "default", ["haxe:build", "stylus:build", "connect","watch"]




