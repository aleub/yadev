db = require("mongoskin").db 'localhost:27017/yadev'
db_posts = db.collection 'posts'
jade = require 'jade'

{markdown} = require 'markdown'
{_} = require "underscore"

moment = require "moment"

module.exports =
  index: (req, res) ->
    db_posts.find(publish: true).sort(pin: -1, timestamp: -1).toArray (err, result) ->
      _.each result, (el) ->
        el.ts = moment(el.timestamp).fromNow()
        if el.templating == "jade"
          jade_fn = jade.compile(el.body, {})
          foo = jade_fn({})
          el.body = foo
        else
          bar = {}
          bar.foo = JSON.stringify(el.body)

          foo = markdown.toHTML(bar.foo)
          el.body = foo
          console.log(bar)

      res.render "index",
        title: "yadev - yet another dev blog"
        posts: result

  viewPost: (req, res) ->
    db_posts.findOne 'title': req.params.post_title
    , (err, result) ->
      if err or result == null
        res.render 'err'
          title: 'damnit',
          error: "couldnt find post '#{req.params.post_title}'"
      else
        result.ts = moment(result.timestamp).fromNow()
        res.render "post",
          post: result

  viewCategory: (req, res) ->
    db_posts.find(category: req.params.category).sort(pin: -1, timestamp: -1).toArray (err, result) ->
      _.each result, (el) ->
        el.ts = moment(el.timestamp).fromNow()
      res.render "index",
        title: "yadev - " + req.params.category
        posts: result

