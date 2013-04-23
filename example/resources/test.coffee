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