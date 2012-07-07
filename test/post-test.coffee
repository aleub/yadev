db = require("mongoskin").db('localhost:27017/yadev')
require "should"

describe 'Post', ->
  it 'should create a new post', (done) ->
    db.collection('posts').insert {'title': 'Testitel', 'body': 'First Body!!'}, (err, res) ->
      throw err if err
      res[0].should.have.property 'title', 'Testitel'
      res[0].should.have.property 'body', 'First Body!!'
      res[0].should.have.property '_id'
      db.collection('posts').remove {'title': 'Testitel', 'body': 'First Body!!'}, (err, res) ->
        throw err if err
        done()

        ###
        db.collection('posts').findOne (err, res) ->
        err.should.not.eql true
        console.log res
        res.should.have.property 'title', 'Testtitel'
        res.should.have.property 'body', 'First Body!!'
        done()
        ###
        ###db.collection("posts").find().toArray (err, result) ->
        throw err if err
        ###
