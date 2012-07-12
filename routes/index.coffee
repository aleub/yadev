db = require("mongoskin").db 'localhost:27017/yadev'
db_posts = db.collection 'posts'
db_settings = db.collection 'settings'
db_comments = db.collection 'comments'
jade = require 'jade'
fs = require 'fs'
crypto = require 'crypto'
md5sum = crypto.createHash 'md5'

markdown = require('github-flavored-markdown').parse
uglifycss = require 'uglifycss/uglifycss-lib'
{_} = require "underscore"

moment = require "moment"

walkRead = (files, done) ->
  results = []
  i = 0
  next = ->
    file = files[i++]
    if not file
      return done null, results

    fs.readFile file, 'utf8', (err, data) ->
      if err 
        done null, results
      else
        results.push data
        next()
  next()

walk = (dir, done) ->
  results = []
  fs.readdir dir, (err, list) ->
    return done err if err
    i = 0
    next = ->
      file = list[i++]
      if not file
        return done null, results

      file = "#{dir}/#{file}"
      fs.stat file, (err, stat) ->
        if stat and stat.isDirectory()
          walk file, (err, res) ->
            results = results.concat res
            next()
        else
          results.push file
          next()
    next()

module.exports =
  index: (req, res) ->
    db_posts.find(publish: true).sort(pin: -1, timestamp: -1).toArray (err, result) ->
      _.each result, (el) ->
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

        #find comments
        db_comments.find('article_id' : result._id).toArray (err_c, result_c) ->
          _.each result_c, (el_c) ->
            el_c.created_at = moment(el_c.created_at).fromNow()
            el_c.gravatar_hash = crypto.createHash('md5').update(el_c.mail.toLowerCase()).digest("hex");

          res.render "post",
            post: result
            comments: result_c

  viewCategory: (req, res) ->
    db_posts.find(category: req.params.category).sort(pin: -1, timestamp: -1).toArray (err, result) ->
      _.each result, (el) ->
        el.ts = moment(el.timestamp).fromNow()
      res.render "index",
        title: "yadev - " + req.params.category
        posts: result

  combineResources: (req, res) ->
    db_settings.findOne (err, result) ->
      theme_files = []

      unless err
        walk __dirname + '/../public/stylesheets', (err, theme_files) ->
          out = []
          walkRead theme_files, (err, out) ->
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
      #find post againreq
      mid = db.ObjectID.createFromHexString(req.params.article_id) #unless (req.params.id.length == 12 or req.params.id.length == 24)
      db_posts.findOne '_id': mid, (err, result) ->
        console.log err, result
        res.redirect "/#{result.title}"
