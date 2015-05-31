path = require "path"

LIVERELOAD_PORT = 35729

module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"
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
    haxe:
      build:
        main: "Main"
        libs: [
          "createjs"
          "jQueryExtern"
        ]
        classpath: ["src"]
        output: "public/js/main.js"
    stylus:
      build:
        files:
          "public/css/main.css": ["public/styl/*.styl"]


  grunt.loadNpmTasks "grunt-haxe"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-stylus"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.registerTask "default", ["haxe:build", "stylus:build", "watch"]




