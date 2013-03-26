se7ensky-restify-resource
=========================

Pretty resource routing for restify.

Features
--------
- simple and unobtrusive usage
- good logging
- mapping whole resource to uri
- relative route mapping in resource

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

exampleMiddleware = ->
  @test = 5
GET 'test', exampleMiddleware, ->
  @res.send @test
```

ToDo
----
- initialization and configuration flexibility
- better logging facilities
- more middleware syntax sugar

Contributing
------------
Feel free to post issues or pull requests at [github repo](https://github.com/Se7enSky/se7ensky-restify-resource).

Authors
-------

  - [Se7enSky studio](http://github.com/Se7enSky) – [official website](http://www.se7ensky.com/)
  - [Ivan Kravchenko](http://github.com/krava)

License
-------

(The MIT License)

Copyright (c) 2008-2013 Se7enSky studio &lt;info@se7ensky.com&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
