{settings} = require('../../settings')
fs = require("fs")
path = require("path")

db = require("mongoskin").db 'localhost:27017/' + settings.db
db_posts = db.collection 'posts'
db_settings = db.collection 'settings'

{_} = require "underscore"
moment = require "moment"
jade = require 'jade'

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

      console.log result

      res.render 'articles',
        articles: result
        current: 'articles'

  articles_new: (req, res) ->
    #get categories
    db_posts.distinct 'category', {}, (err, result_cat) ->
      res.render 'edit_post',
        current: 'articles'
        post: {}
        title: 'Create a new Article'
        category_list: JSON.stringify result_cat

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
          db_posts.distinct 'category', {}, (err, result_cat) ->
            res.render 'edit_post',
              current: 'articles'
              post: result
              title: 'Edit Article'
              category_list: JSON.stringify(result_cat)
      )

  articles_save: (req, res) ->
    console.log req.body.post
    req.body.post.publish = req.body.post.publish == 'on' || false
    req.body.post.pin = req.body.post.pin == 'on' || false

    if req.params.id
      mid = db.ObjectID.createFromHexString(req.params.id)
      db_posts.findOne(_id: mid, (err, result) ->
        db_posts.update(
          _id: mid,
          _.extend(
            result,
            req.body.post,
            updated_at: moment().valueOf()
          ), (err, result) ->
          if err
            res.render 'err',
              title: 'damnit',
              error: 'couldnt save'

          res.redirect "/articles"
        )
      )
    else
      data = _.extend(
        req.body.post,
        timestamp: moment().valueOf(),
        updated_at: moment().valueOf()
      )
      db_posts.insert data, (err, result) ->
        throw err if err
        res.redirect '/articles'

  articles_remove: (req, res) ->
    ids = [].concat req.body.ids
    dbids = []

    _.each(ids, (id) ->
      dbids.push db.ObjectID.createFromHexString(id)
    )

    db_posts.remove(
      _id: $in: dbids
    )

    res.redirect "/articles"

  compile: (req, res) ->
    console.log 'compile', req.body.templating , req.body
    if req.body.templating == "jade"
      jade_fn = jade.compile(req.body.src, {})
      foo = jade_fn({})
      res.send html: foo
    else
      foo = require( "markdown" ).markdown.toHTML(req.body.src)
      res.send html: foo

  media: (req, res) ->
    res.render 'media',
      current: 'media'

  pages: (req, res) ->
    res.render 'pages',
      current: 'pages'

  comments: (req, res) ->
    res.render 'comments',
      current: 'comments'

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