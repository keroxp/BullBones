module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"
    watch:
      haxe:
        files: [
          "src/*.hx"
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
  grunt.registerTask "default", ["haxe:build", "stylus:build", "watch"]




