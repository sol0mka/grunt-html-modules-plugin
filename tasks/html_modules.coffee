#
# * html-modules
# * https://github.com/legomushroom/grunt-plugin
# *
# * Copyright (c) 2013 LegoMushroom
# * Licensed under the MIT license.
# 
"use strict"

module.exports = (grunt) ->
    # Please see the Grunt documentation for more information regarding task
    # creation: http://gruntjs.com/creating-tasks

    grunt.registerMultiTask "html_modules", "allows to include small html parts in other html", ->
        
        settings =  grunt.config.data.html_modules.settings
        fs      = require 'fs'
        $       = require 'jquery'
        html    = require 'html'

        class Files
            constructor:(o)->
                @o = o
                @fs = fs
                @dir = settings.particles
                @files = {}

            readFiles:->
                @dfr = new $.Deferred

                @fs.readdir @dir, (err, files)=>
                    if err then throw err;
                    files = @getValidFiles files
                    files.forEach (file, i)=>
                        fileName = file.split('.html')[0]
                        fs.readFile @dir+file, 'utf-8', (err, html)=>
                            err and (throw err)
                            @files[fileName] = html
                            if i is files.length-1 then @dfr.resolve @files

                @dfr.promise()

            getValidFiles:(files)->
                files.filter (file)->
                    file.match /.html$/gi
        
        filesStorage = new Files

        class FilesChanged 
            constructor:(o)->
                @o = o
                @jsonTags = []
                
                filesStorage.readFiles().then (files)=>
                    @getFiles()

            getFiles:->
                # Iterate over all specified file groups.
                @o.files.forEach (f) =>
                    @f = f
                    # check file source.
                    src = f.src.filter((filepath) ->
                        filepath = filepath
                        unless grunt.file.exists(filepath)
                            grunt.log.warn "Source file \"" + filepath + "\" not found."
                            false
                        else return true
                    # Read file source.
                    ).map (filepath) -> grunt.file.read filepath

                    for file, z in src
                        newFile = @renderFile
                            file: file
                            fileSrc: f

                        grunt.file.write "#{settings.monolits}/#{f.src[z]}", html.prettyPrint(newFile)
                        grunt.log.ok "#{settings.monolits}/#{f.src[z]} was created"


            renderFile:(o)->
                $destFile   =   @wrapFile o.file
                $tags       =   @getTagsInFile $destFile

                @compileTags 
                        $tags: $tags

                if @getTagsInFile($destFile).length > 0
                    return @renderFile 
                        file: $destFile.html()
                        fileSrc: o.fileSrc
                        trail: @trail

                $destFile.html()

            compileTags:(o)->
                @jsonTags   =   @getJSONTags 
                                        tags: o.$tags

                # loop thrue json tags
                for jsonTag, tagNum in @jsonTags
                    compiledTag = @compileTag 
                            tagNum:     tagNum
                            fileSrc:    o.fileSrc
                            $tag:       o.$tags[tagNum]

                @jsonTags


            compileTag:(o)->
                tag = filesStorage.files[@jsonTags[o.tagNum].key]
                # replace variables
                for name, value of @jsonTags[o.tagNum]
                    patt = new RegExp "\\$#{name}", 'gi'
                    tag = tag?.replace patt, value

                $(o.$tag).replaceWith tag

                tag
            
            getJSONTags:(o)->
                jsonTags = []
                for tagNum in [0...o.tags.length]
                    #add new tags json record
                    jsonTags[tagNum] = {}
                    for attr, i in o.tags[tagNum].attributes
                        jsonTags[tagNum][attr.nodeName] = attr.nodeValue

                jsonTags


            wrapFile:(file)->
                $(file).wrap('<div>').parent()

            getTagsInFile:($file)->
                $file.find('layout')

        filesChanged = new  FilesChanged 
                                files: @files

