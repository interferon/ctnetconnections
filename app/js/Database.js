// Generated by CoffeeScript 1.7.1
(function() {
  var Database, collections, db, mongojs;

  mongojs = require('mongojs');

  collections = ['buildings', 'equipment', 'boxesnames', 'streetnames', 'commutatornames', 'upsnames', 'odfnames', 'connectors', 'logs', 'users', 'copperincome', 'copperuse', 'opticalplans', 'opticaluse', 'opticalincome', 'opticallogs', 'workers', 'boxstore', 'patchpanelstore', 'patchcordstore', 'pigtailsstore', 'socketsstore', 'workerscash', 'warehouselogs', 'sessions', 'accesslevel', 'other'];

  db = mongojs.connect('ctnet', collections);

  Database = (function() {
    function Database() {}

    Database.prototype.save = function(collection, object, callback) {
      return db[collection].save(object, function(error, saved) {
        if (error) {
          return callback({
            "result": "Error: " + error
          });
        } else {
          return callback({
            "result": "Збережено!",
            "object": saved
          });
        }
      });
    };

    Database.prototype.drop = function(collection) {
      return db[collection].drop();
    };

    Database.prototype.getAll = function(collection, fn) {
      return db[collection].find(function(error, items) {
        if (error) {
          return console.log("not found");
        } else {
          return fn(items);
        }
      });
    };

    Database.prototype.getByParam = function(collection, param, fn) {
      return db[collection].find(param, function(error, items) {
        if (error) {
          return console.log("not found");
        } else {
          return fn(items);
        }
      });
    };

    Database.prototype.getById = function(collection, id, fn) {
      var _id;
      _id = db.ObjectId(id);
      return db[collection].find({
        "_id": _id
      }, function(error, items) {
        if (error) {
          return console.log("not found");
        } else {
          return fn(items);
        }
      });
    };

    Database.prototype.remove = function(collection, item_id, callback) {
      var id;
      id = db.ObjectId(item_id);
      db[collection].remove({
        _id: id
      });
      callback({
        result: "Видалено!"
      });
      return id;
    };

    Database.prototype.removeByParam = function(collection, param, callback) {
      return db[collection].remove(param, function(err, result) {
        console.log(err, result);
        if (!err) {
          return callback(true);
        } else {
          return callback(false);
        }
      });
    };

    Database.prototype.update = function(collection, item_id, update, update_type, callback) {
      var id;
      id = db.ObjectId(item_id);
      switch (update_type) {
        case 'set':
          return db[collection].update({
            "_id": id
          }, {
            $set: update
          }, function(err) {
            if (err) {
              return callback({
                result: "Помилка!"
              });
            } else {
              return callback({
                result: "Вміст поля змінено!"
              });
            }
          });
        case 'push':
          return db[collection].update({
            "_id": id
          }, {
            $push: update
          }, function(err) {
            if (err) {
              return callback({
                result: "Помилка!"
              });
            } else {
              return callback({
                result: "Вміст поля змінено!"
              });
            }
          });
        case 'pull':
          return db[collection].update({
            "_id": id
          }, {
            $pull: update
          }, function(err) {
            if (err) {
              return callback({
                result: "Помилка!"
              });
            } else {
              return callback({
                result: "Вміст поля змінено!"
              });
            }
          });
        case 'inc':
          return db[collection].update({
            "_id": id
          }, {
            $inc: update
          }, function(err) {
            if (err) {
              return callback({
                result: "Помилка!"
              });
            } else {
              return callback({
                result: "Вміст поля змінено!"
              });
            }
          });
      }
    };

    Database.prototype.findAndModify = function(collection, item_id, data, fn) {
      return db[collection].findAndModify({
        query: {
          id: db.ObjectId(item_id)
        },
        update: {
          $inc: data
        },
        "new": true
      }, function(err, doc) {
        return fn(doc);
      });
    };

    Database.prototype.getCollections = function() {
      return collections;
    };

    Database.prototype.dropDatabase = function() {
      return db.dropDatabase();
    };

    return Database;

  })();

  module.exports.Database = Database;

}).call(this);
