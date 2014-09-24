process.env.NODE_ENV = 'test'
server = require('../../server')
expect = require('expect.js')
Browser = require('zombie')
fs = require('fs')

describe 'editor page', ->

  before ->
    @server = server.listen(3000)
    @browser = new Browser({ site: 'http://localhost:3000' })
    fs.writeFile('code/_test.txt', 'Lorem ipsum')

  after ->
    fs.unlink('code/_test.txt')

  describe 'editing a non-existent file', ->
    before (done) ->
      @browser.visit('/edit?file=nonsense.txt', done)

    it 'displays an error message', ->
      expect(@browser.text('h1')).to.eql('File not found')

  describe 'editing an existent file', ->
    before (done) ->
      @browser.visit('/edit?file=_test.txt', done)

    it 'displays an edit page', ->
      expect(@browser.text('h1')).to.eql('Editing _test.txt')

    it 'prepopulates the page with the current contents of the file', ->
      expect(@browser.text('textarea')).to.eql('Lorem ipsum')

    describe 'saving changes', ->
      before (done) ->
        @browser.fill("textarea", 'Hello').
        pressButton('Save', done)

      it 'writes the changes to the file', ->
        expect(fs.readFileSync('code/_test.txt', 'utf8')).to.eql('Hello')
