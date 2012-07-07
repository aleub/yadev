{settings} = require('../../settings')
fs = require("fs")
path = require("path")

db = require("mongoskin").db 'localhost:27017/' + settings.db
db_settings = db.collection 'settings'

{_} = require "underscore"
moment = require "moment"

module.exports =
  get: (callback) ->
    db_settings.findOne (err, my_settings) ->
      unless err
        callback(my_settings)

module.exports.routes =
  settings_save: (req, res) ->
    db_settings.findOne (err, my_settings) ->
      data = _.extend(req.body.settings, updated_ad: moment().valueOf())

      if my_settings
        db_settings.update(
          my_settings,
          data, (err, result) ->
            if err
              res.render 'err',
                tittle: 'damnit',
                error: 'saving settings gone wrong'
            res.redirect "/settings")
      else
        db_settings.insert data, (err, result) ->
          throw err if err
          res.redirect '/settings'

  settings: (req, res) ->
    db_settings.findOne (err, my_settings) ->
      console.log(my_settings)
      fs.readdir path.normalize(__dirname + '/../../public/themes/'), (err, files) ->
        res.render 'settings',
          current: 'settings',
          settings: my_settings || {},
          themes: files || ['default']


