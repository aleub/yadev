db = require("mongoskin").db 'localhost:27017/yadev'
db_posts = db.collection 'posts'

{_} = require "underscore"
moment = require "moment"
moment.lang 'de'

module.exports =
  dashboard: (req, res) ->
    req.session.accessTime = moment()
    res.render 'dashboard'

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