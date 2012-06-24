{settings} = require('../../settings')

db = require("mongoskin").db 'localhost:27017/' + settings.db
db_posts = db.collection 'posts'

{_} = require "underscore"
moment = require "moment"
moment.lang 'de'

module.exports =
  dashboard: (req, res) ->
    db_posts.find().count (err, result) ->
      res.render 'dashboard',
        current: 'dashboard'
        article_count: result

  articles: (req, res) ->
    db_posts.find().sort(timestamp: 1).toArray (err, result) ->
      _.each result, (el) ->
        el.ts = moment(el.timestamp).fromNow()
        console.log el.timestamp

      res.render 'articles',
        articles: result
        current: 'articles'

  articles_new: (req, res) ->
    res.render 'edit_post',
      current: 'articles'
      post: {}
      title: 'Create a new Article'

  articles_edit: (req, res) ->
    if (req.params.id.length == 12 or req.params.id.length == 24)
      mid = db.ObjectID.createFromHexString(req.params.id) #unless (req.params.id.length == 12 or req.params.id.length == 24)

    console.log mid
    if mid == undefined
      console.log "redirecting to articles"
      res.redirect '/articles'
    else
      console.log "searching id"
      db_posts.findOne(_id: mid, (err, result) ->
        if err || !result
          res.render 'err',
            title: 'oops',
            error: 'cant find the article'
        else
          res.render 'edit_post',
            current: 'articles'
            post: result
            title: 'Edit Article'
      )

  articles_save: (req, res) ->
    console.log req.body.post.body
    req.body.post.publish = req.body.post.publish == 'on' || false
    req.body.post.pin = req.body.post.pin == 'on' || false

    if req.params.id
      mid = db.ObjectID.createFromHexString(req.params.id)
      db_posts.findOne(_id: mid, (err, result) ->
        db_posts.update((_id: mid), _.extend(result, req.body.post), (err, result) ->
          if err
            res.render 'err',
              title: 'damnit',
              error: 'couldnt save'

          res.redirect "/articles"
        )
      )
    else
      data = _.extend(req.body.post, timestamp: moment().valueOf())
      db_posts.insert data, (err, result) ->
        throw err if err
        res.redirect '/articles'

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
    if req.body.post.username != settings.user_admin or req.body.post.password != settings.pwd_admin
      delete req.session.user
      res.render 'login',
        layout: 'layout_clean'
        actions: {
          error: "  no way!"
        }
    else
      req.session.user = req.body.post.username
      res.redirect '/dashboard'