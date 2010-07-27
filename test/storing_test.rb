require 'test/test_helper'

class StoringTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def setup
    db = Connection.new.db(TEST_DB)
    db.drop_collection(TEST_COLLECTION)
  end

  def browser
    @browser ||= Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
  end
  
  def test_store_simple_object
    browser.post "/store/#{TEST_DB}/#{TEST_COLLECTION}", 
      { :object => { :name => 'FooBar', :age => 21 }.to_json }

    assert browser.last_response.ok?
    assert_equal 'ok', JSON.parse(browser.last_response.body)['result']
  end
  
  def test_upload_and_download_of_a_file
    browser.post "/upload/#{TEST_DB}",
        "file" => Rack::Test::UploadedFile.new("test/me.jpeg", "image/jpeg")
    
    assert browser.last_response.ok?
    
    assert_equal 'ok', JSON.parse(browser.last_response.body)['result']
    oid = JSON.parse(browser.last_response.body)['id']
    
    assert_not_nil oid
    
    # now, i want to download
    browser.get "/download/#{TEST_DB}/#{oid}"
    assert browser.last_response.ok?
    
    original_content    = File.open("test/me.jpeg").read
    
    assert_equal  Digest::MD5.hexdigest(original_content), 
                  Digest::MD5.hexdigest(browser.last_response.body)
  end
end 
