// Generated by CoffeeScript 1.6.2
(function() {
  "use strict";  module.exports = function(grunt) {
    var $, Files, cheerio, data, filesStorage, fs,
      _this = this;

    fs = require('fs');
    $ = require('jquery');
    cheerio = require('cheerio');
    data = {};
    Files = (function() {
      function Files(o) {
        this.o = o;
        this.fs = fs;
        this.dir = 'tasks/src/';
        this.files = [];
      }

      Files.prototype.readFiles = function() {
        var _this = this;

        this.dfr = new $.Deferred;
        this.fs.readdir(this.dir, function(err, files) {
          if (err) {
            throw err;
          }
          files = _this.getValidFiles(files);
          return files.forEach(function(file, i) {
            return fs.readFile(_this.dir + file, 'utf-8', function(err, html) {
              err && ((function() {
                throw err;
              })());
              _this.files[i] = {};
              _this.files[i][file.split('.')[0]] = html;
              if (i === files.length - 1) {
                return _this.dfr.resolve();
              }
            });
          });
        });
        return this.dfr.promise();
      };

      Files.prototype.getValidFiles = function(files) {
        return files.filter(function(file) {
          return file.match(/.html$/gi);
        });
      };

      return Files;

    })();
    filesStorage = new Files;
    filesStorage.readFiles().then(function() {
      return console.log(filesStorage.files);
    });
    return grunt.registerMultiTask("html_modules", "allows to include small html parts in other html", function() {
      var FilesChanged, filesChanged, options;

      options = this.options({
        punctuation: ".",
        separator: ", "
      });
      FilesChanged = (function() {
        function FilesChanged(o) {
          this.o = o;
          this.files = [];
          this.getFiles();
        }

        FilesChanged.prototype.getFiles = function() {
          var _this = this;

          this.dfr = new $.Deferred;
          this.o.files.forEach(function(f) {
            var $r, attr, file, i, src, _i, _len, _ref, _results;

            src = f.src.filter(function(filepath) {
              if (!grunt.file.exists(filepath)) {
                grunt.log.warn("Source file \"" + filepath + "\" not found.");
                return false;
              } else {
                return true;
              }
            }).map(function(filepath) {
              return grunt.file.read(filepath);
            });
            file = src[0];
            $r = $(file);
            _ref = $r[0].attributes;
            _results = [];
            for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
              attr = _ref[i];
              _this.files[i] = {
                name: attr.nodeName,
                val: attr.nodeValue
              };
              if (i === $r[0].attributes.length - 1) {
                _results.push(_this.dfr.resolve());
              } else {
                _results.push(void 0);
              }
            }
            return _results;
          });
          return this.dfr.promise();
        };

        return FilesChanged;

      })();
      return filesChanged = new FilesChanged({
        files: this.files
      });
    });
  };

}).call(this);
