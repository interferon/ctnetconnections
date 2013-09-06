// Generated by CoffeeScript 1.6.2
(function() {
  var dataProcFn, fs, pathmodule;

  fs = require('fs');

  pathmodule = require('path');

  dataProcFn = require('./dataProcessingFunctions');

  module.exports.start = function(app) {
    app.get('/odfimageslist', function(req, res) {
      var query;

      query = req.query;
      return fs.readdir(pathmodule.join(__dirname, "/../images/odfimgs/", query.foldername), function(err, files) {
        return dataProcFn.runResponse(res, {
          'files': files
        }, 'text/plain');
      });
    });
    app.post('/uploadbillimage', function(req, res) {
      var image, path;

      path = req.files.file.path;
      image = path.substring(path.length, path.length - 36);
      return res.end(image);
    });
    return app.post('/uploadequipmentimage', function(req, res) {
      var deleteUploadedImage, image, newfilename, params, path, renameUploadedImage, targetpath;

      params = JSON.parse(req.body.params);
      path = req.files.file.path;
      switch (params.type) {
        case 'odf':
          targetpath = pathmodule.join(__dirname, '/../images/odfimgs/', params.targetpath);
          newfilename = pathmodule.join(__dirname, '/../images/odfimgs/', params.newfilename);
          break;
        case 'box':
          targetpath = pathmodule.join(__dirname, '/../images/boxes');
          newfilename = pathmodule.join(__dirname, '/../images/boxes', params.newfilename);
      }
      image = path.substring(path.length, path.length - 36);
      fs.exists(targetpath, function(exists) {
        if (exists) {
          renameUploadedImage();
          return res.end();
        } else {
          return fs.mkdir(targetpath, function() {
            renameUploadedImage();
            return res.end();
          });
        }
      });
      renameUploadedImage = function() {
        return fs.rename(path, newfilename, function(err) {
          deleteUploadedImage();
          if (err) {
            return console.log(err);
          }
        });
      };
      return deleteUploadedImage = function() {
        return fs.unlink(path, function() {
          return console.log('deleted');
        });
      };
    });
  };

}).call(this);