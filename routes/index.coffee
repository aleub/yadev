db = require("mongoskin").db 'localhost:27017/yadev'
db_posts = db.collection 'posts'
db_settings = db.collection 'settings'
db_comments = db.collection 'comments'

fs = require 'fs'
crypto = require 'crypto'
jade = require 'jade'

markdown = require('github-flavored-markdown').parse
uglifycss = require 'uglifycss/uglifycss-lib'

moment = require "moment"
walk = require '../lib/walk'

class Post 

module.exports =
  index: (req, res) ->
    db_posts.find(publish: true).sort(pin: -1, timestamp: -1).toArray (err, result) ->
      for el in result
        do (el) ->
          el.ts = moment(el.timestamp).fromNow()
          if el.templating == "markdown"
            el.body = markdown el.body

      res.render "index",
        title: "yadev - yet another dev blog"
        posts: result
        theme: folder: "default"

  viewPost: (req, res) ->
    db_posts.findOne 'title': req.params.post_title
    , (err, result) ->
      if err or result == null
        res.render 'err'
          title: 'damnit',
          error: "couldnt find post '#{req.params.post_title}'"
      else
        result.ts = moment(result.timestamp).fromNow()
        result.body = markdown result.body
        #find comments
        db_comments.find('article_id' : result._id).toArray (err_c, result_c) ->
          for el_c in result_c
            do (el_c) ->
              el_c.created_at = moment(el_c.created_at).fromNow()
              el_c.gravatar_hash = crypto.createHash('md5').update(el_c.mail.toLowerCase()).digest("hex");

          res.render "post",
            post: result
            comments: result_c

  viewCategory: (req, res) ->
    db_posts.find(category: req.params.category)
      .sort(pin: -1, timestamp: -1)
      .toArray (err, result) ->
        for el in result
          do (el) ->
            el.ts = moment(el.timestamp).fromNow()
        res.render "index",
          title: "yadev - " + req.params.category
          posts: result

  combineResources: (req, res) ->
    db_settings.findOne (err, result) ->
      theme_files = []

      unless err
        walk.walk __dirname + '/../public/stylesheets', (err, theme_files) ->
          out = []
          walk.walkRead theme_files, (err, out) ->
            uglified = uglifycss.processString out.join('\n'), {}
            res.setHeader("Content-Type", "text/css")
            res.end uglified

  addComment: (req, res) ->
    data =
      name: req.body.comment.name
      mail: req.body.comment.mail
      post: req.body.comment.post
      article_id: db.ObjectID.createFromHexString(req.params.article_id)
      created_at: moment().valueOf()
    db_comments.insert data, (err, result) ->
      throw err if err
      #find post again
      mid = db.ObjectID.createFromHexString(req.params.article_id) #unless (req.params.id.length == 12 or req.params.id.length == 24)
      db_posts.findOne '_id': mid, (err, result) ->
        console.log err, result
        res.redirect "/#{result.title}"
