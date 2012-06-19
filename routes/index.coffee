db = require("mongoskin").db 'localhost:27017/yadev'
db_posts = db.collection 'posts'
{_} = require "underscore"
moment = require "moment"
moment.lang 'de'

module.exports =
  index: (req, res) ->
    db_posts.find().toArray (err, result) ->
      _.each result, (el) ->
        el.ts = moment(el.timestamp).format('LLLL')
      res.render "index",
        title: "yadev - yet another dev blog"
        posts: result

  newPost: (req, res) ->
    res.render 'add_post',
      title: "Write New Post"

  addPost: (req, res) ->
    if req.body.post.title.length > 0 and req.body.post.body.length > 0
      dbobj = _.extend(req.body.post, timestamp: (new Date()).getTime())
      console.log dbobj

      db_posts.insert dbobj, (err, result) ->
        throw err if err
        res.redirect "/"
    else
      res.render 'err',
        title: 'Oh snap, something went wrong',
        error: 'title or body seems to be empty...'

  removePost: (req, res) ->
    db_posts.remove(_id: db.ObjectID.createFromHexString(req.params.id), -> res.send success: true)
