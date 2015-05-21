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
    haxe:
      build:
        main: "Main"
        classpath: ["src"]
        output: "js/main.js"
        flags: [
          "createjs"
        ]
  grunt.loadNpmTasks "grunt-haxe"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.registerTask "default", ["haxe:build", "watch"]




