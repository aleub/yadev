db = require("mongoskin").db 'localhost:27017/yadev'
db_posts = db.collection 'posts'

{_} = require "underscore"
moment = require "moment"
moment.lang 'de'



module.exports =
  index: (req, res) ->
    db_posts.find().toArray (err, result) ->
      _.each result, (el) ->
        console.log el
        el.ts = moment(el.timestamp).format('LLLL')

      res.render "index",
        title: "yadev - yet another dev blog"
        posts: result

  newPost: (req, res) ->
    res.render 'edit_post',
      title: "Write New Post"
      post: {}

  viewPost: (req, res) ->
    db_posts.findOne 'title': req.params.post_title
    , (err, result) ->
      if err or result == null
        res.render 'err'
          title: 'damnit',
          error: "couldnt find post '#{req.params.post_title}'"

      console.log result


  editPost: (req, res) ->
    db_posts.findOne(_id: db.ObjectID.createFromHexString(req.params.id), (err, result) ->
        console.log(result)
        res.render 'edit_post',
          title: "Edit Post",
          post: result)

  savePost: (req, res) ->
    mid = db.ObjectID.createFromHexString(req.params.id)
    req.body.post.publish = if req.body.post.publish == 'on' then true else false
    req.body.post.pin = if req.body.post.pin == 'on' then true else false

    db_posts.update((_id: mid), req.body.post, (err, result) ->
      if err
        res.render 'err',
          title: 'damnit',
          error: 'couldnt save'

      res.redirect "/"
    )

  addPost: (req, res) ->
    if req.body.post.title.length > 0 and req.body.post.body.length > 0
      dbobj = _.extend(req.body.post, timestamp: (new Date()).getTime())
      console.log dbobj

      db_posts.insert dbobj, (err, result) ->
        throw err if err
        res.redirect "/"
    else
      res.render 'err',
        title: 'Oh snap',
        error: 'title or body seems to be empty...'

  removePost: (req, res) ->
    db_posts.remove(_id: db.ObjectID.createFromHexString(req.params.id), -> res.send success: true)


