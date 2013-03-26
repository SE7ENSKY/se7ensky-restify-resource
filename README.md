se7ensky-restify-resource
=========================

Pretty resource routing for restify

Installing
----------
```bash
$ npm install se7ensky-restify-resource
```

Usage
-----
server.coffee:
```coffee
...
log = bunyan.createLogger ...
server = restify.createServer ...
server.use ...
...

require('se7ensky-restify-resource')(server, log, "#{__dirname}/resources") # initialize module

server.resource 'items' # initialize resource under URI '/items'
```

resources/items.coffee
```coffee
customers = [
  { id: 1, title: 'item 1' }
  { id: 2, title: 'item 2' }
  { id: 3, title: 'item 3' }
]

GET ->
  @res.send customers
GET ':id', ->
  @res.send customers[@req.params.id]
POST ->
  customers.push { id: @req.body.id, title: @req.body.title }
  @res.send customers[@req.params.id]
PUT ':id', ->
  customers[@req.params.id] = { id: @req.body.id, title: @req.body.title }
  @res.send customers[@req.params.id]
DELETE ':id', ->
  @res.send customers[@req.params.id]
  delete customers[@req.params.id]
```
