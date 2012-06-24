db = require("mongoskin").db 'localhost:27017/yadev'
db_posts = db.collection 'posts'

{_} = require "underscore"
moment = require "moment"
moment.lang 'de'

module.exports =
  dashboard: (req, res) ->
    req.session.accessTime = moment()
    res.render 'dashboard',
      current: 'dashboard'

  articles: (req, res) ->
    db_posts.find().toArray (err, result) ->
      _.each result, (el) ->
        el.ts = moment(el.timestamp).fromNow()

      res.render 'articles',
        articles: result
        current: 'articles'

  media: (req, res) ->
    res.render 'media',
      current: 'media'

  pages: (req, res) ->
    res.render 'pages',
      current: 'pages'

  comments: (req, res) ->
    res.render 'comments',
      current: 'comments'

  settings: (req, res) ->
    res.render 'settings',
      current: 'settings'

  login: (req, res) ->
    res.render 'login',
      actions: {}
      layout: 'layout_clean'

  logout: (req, res) ->
    req.session.destroy()
    res.redirect '/'

  auth: (req, res) ->
    if req.body.post.username != "root"
      delete req.session.user
      res.render 'login',
        layout: 'layout_clean'
        actions: {
          error: "Nope!"
        }
    else
      req.session.user = req.body.post.username
      res.redirect '/dashboard'