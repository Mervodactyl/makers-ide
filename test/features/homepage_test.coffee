process.env.NODE_ENV = 'test'
server = require('../../server')
expect = require('expect.js')
Browser = require('zombie')
fs = require('fs')

describe 'home page',  ->

  before ->
    @server = server.listen(3000)
    @browser = new Browser { site: 'http://localhost:3000' }
    @fs = fs
    @fs.writeFile 'code/_test.txt', 'Lorem ipsum'

  before (done) ->
    @browser.visit '/', done

  after ->
    @fs.unlink 'code/_test.txt'


  it 'should show a welcome message',  ->
    expect(@browser.text('h1')).to.eql('Welcome to Makers IDE')

  it 'should show a file picker',  ->
    expect(@browser.text('.files a:first-child')).to.eql('_test.txt')


  # BAAAAAAAAAAAAAAM!!!!!!
  it 'there should be no file left after delete button is clicked',  ->
    @browser.onconfirm("Really delete this file?", true)
    @browser.fire('.files a:first-child img:last-child','click').
      then =>
        expect(@browser.text('.files a:first-child')).not.to.eql('_test.txt')

  it 'takes you to an edit page when a file is selected', ->
    @browser.clickLink '_test.txt', =>
      expect(@browser.location.pathname).to.eql('/edit?file=_test.txt')
