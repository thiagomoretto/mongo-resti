begin
  # Require the preresolved locked set of gems.
  require ::File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fallback on doing the resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

require 'sinatra'
require 'mongo'

include Mongo
  
get "/" do
   "Hello World"
end

get "/store/:database/:collection" do
   database, collection = params[:database], params[:collection]
   object               = params[:object]
   
   db   = Connection.new.db(database)
   coll = db.collection(collection)
   coll.insert({ :nome => 'Fulano',  :permissoes => [ 'FAZER', 'DESFAZER', 'ETC'] })
   
   "{ return: ok }"   
end
