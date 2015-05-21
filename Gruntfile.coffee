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
        libs: [ "createjs"]
        classpath: ["src"]
        output: "js/main.js"

  grunt.loadNpmTasks "grunt-haxe"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.registerTask "default", ["haxe:build", "watch"]




