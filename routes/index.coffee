db = require("mongoskin").db 'localhost:27017/yadev'
db_posts = db.collection 'posts'

module.exports =
	index: (req, res) ->
		db_posts.find().toArray (err, result) ->
			res.render "index",
				title: "yadev - yet another dev blog"
				posts: result

	newPost: (req, res) ->
		res.render 'add_post',
			title: "Write New Post"

	addPost: (req, res) ->
		if req.body.post.title.length > 0 and req.body.post.body.length > 0
			db_posts.insert req.body.post, (err, result) ->
				throw err if err
				res.redirect "/"
		else
			res.render 'err',
				title: 'Oh snap, something went wrong',
				error: 'title or body seems to be empty...'
