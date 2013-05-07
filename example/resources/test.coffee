fetchTest = ->
	@test = { secretField: 'secretValue' }
	@next()

GET 'fetch', fetchTest, ->
	@res.send "ok, test=#{JSON.stringify @test}"

asyncFetchTest = ->
	setTimeout =>
		@test = { secretField: 'secretValue' }
		@next()
	, 1000

GET 'afetch', asyncFetchTest, ->
	setTimeout =>
		@respond "ok, test=#{JSON.stringify @test}"
		# @next()
	, 1000

GET 'secretField', fetchTest, ->
	@res.send "ok, secretField=#{@test.secretField}"

GET 'syncerror', ->
	@next new Error 'test error'

GET 'asyncerror', ->
	setTimeout =>
		@globalNext new Error 'test error'
	, 1000

GET 'asyncerrorrespond', ->
	setTimeout =>
		@respond new Error 'test error'
	, 1000

m1 = ->
	@m1 = 1
	@next()
a1 = [
	->
		@a1 = {} if not @a1
		@a1.one = 11
		@next()
	->
		@a1 = {} if not @a1
		@a1.two = 12
		@next()
]
a2 = [
	->
		@res.send { m1:@m1, a1:@a1 }
]

GET 'middlewaresTest', m1, a1, a2