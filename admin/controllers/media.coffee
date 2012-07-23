{settings} = require('../../settings')
{_} = require "underscore"
moment = require "moment"

db = require("mongoskin").db 'localhost:27017/' + settings.db
db_media = db.collection 'meda'

module.exports =
  count: (callback) ->
    db_media.find().count (err, result) ->
      callback(result) unless err

module.exports.routes =
  media: (req, res) ->
    res.render 'media',
      current: 'media'

  media_upload: (req, res) ->
    res.send("foobar")
    console.log req.body

