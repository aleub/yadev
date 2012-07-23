{settings} = require('../../settings')
{_} = require "underscore"
moment = require "moment"

db = require("mongoskin").db 'localhost:27017/' + settings.db
db_posts = db.collection 'posts'

module.exports =
  count: (callback) ->
    db_posts.find().count (err, result) ->
      callback(result) unless err

module.exports.routes =
  articles: (req, res) ->
    db_posts.find().sort(timestamp: 1).toArray (err, result) ->
      _.each result, (el) ->
        el.ts = moment(el.timestamp).fromNow()

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

    if mid == undefined
      res.redirect '/articles'
    else
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

  #post action save button in edit view
  articles_save: (req, res) ->
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

