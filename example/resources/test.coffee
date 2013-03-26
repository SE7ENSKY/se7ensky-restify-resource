fetchTest = ->
	@test = { secretField: 'secretValue' }
	@next()

GET fetchTest, ->
	@res.send "ok, test=#{JSON.stringify @test}"

GET 'secretField', fetchTest, ->
	@res.send "ok, secretField=#{@test.secretField}"