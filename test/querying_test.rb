require 'test/test_helper'

class QueryingTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def setup
    db = Connection.new.db(TEST_DB)
    db.drop_collection(TEST_COLLECTION)
  end

  def browser
    @browser ||= Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
  end

  def test_query_object_using_equal
    browser.post "/store/#{TEST_DB}/#{TEST_COLLECTION}", 
      { :object => { :name => 'FooBar', :age => 21 }.to_json }
    
    browser.get "/query/#{TEST_DB}/#{TEST_COLLECTION}", 
      { :query => { :name => "FooBar" }.to_json }
    
    assert browser.last_response.ok?
    
    json_result = JSON.parse(browser.last_response.body)
    assert_equal 1       , json_result["count"]
    assert_equal "FooBar", json_result["rows"].first["name"]
  end
  
  def test_query_object_using_gt
    browser.post "/store/#{TEST_DB}/#{TEST_COLLECTION}", 
      { :object => { :name => 'OMG', :age => 21 }.to_json }
    
    browser.get "/query/#{TEST_DB}/#{TEST_COLLECTION}", 
      { :query => { :age => { "$gt" => 19 } }.to_json }

    assert browser.last_response.ok?
    
    json_result = JSON.parse(browser.last_response.body)
    assert_equal 1       , json_result["count"]
    assert_equal "OMG"   , json_result["rows"].first["name"]
  end
end