{settings} = require('../../settings')
fs = require("fs")
path = require("path")

db = require("mongoskin").db 'localhost:27017/' + settings.db
db_posts = db.collection 'posts'

{_} = require "underscore"
moment = require "moment"
jade = require 'jade'
Markdown = require 'github-flavored-markdown'
markdown = Markdown.parse

articles_controller = require("../controllers/articles")
settings_controller = require("../controllers/settings")
auth_controller = require("../controllers/auth")
media_controller = require("../controllers/media")

module.exports =
  dashboard: (req, res) ->
    articles_controller.count (result) ->
      res.render 'dashboard',
        current: 'dashboard'
        article_count: result

  compile: (req, res) ->
    if req.body.templating == "jade"
      jade_fn = jade.compile(req.body.src, {})
      foo = jade_fn({})
      res.send html: foo
    else
      out = markdown req.body.src
      res.send html: out


  pages: (req, res) ->
    res.render 'pages',
      current: 'pages'

  comments: (req, res) ->
    res.render 'comments',
      current: 'comments'

_.extend(module.exports, articles_controller.routes, settings_controller.routes, auth_controller.routes, media_controller.routes)