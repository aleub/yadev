routes = require "../routes/"
require "should"

describe "feature", ->
	it "should add two numbers", ->
		(2+2).should.equal 4

describe "routes", ->
	req = {}
	res = {}
	describe "index", ->
		it "should display index with posts", (done)->
			res =
				render: (view, vars) ->
					view.should.equal "index"
					vars.title.should.equal "yadev - yet another dev blog"
					done()
			routes.index(req, res)

	describe "new post", ->
		it "should display the add post page", (done)->
			res.render = (view, vars) ->
					view.should.equal "add_post"
					vars.title.should.equal "Write New Post"
					done()
			routes.newPost req, res
