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

require 'yajl'
require 'yajl/json_gem'

include Mongo

# TODO: I need a better approach about this...
@@mongo = Connection.new("localhost", 27017, :pool_size => 1, :timeout => 5)

post "/store/:database/:collection" do
  database, collection = params[:database], params[:collection]
  pure_json_object     = params[:object]
  
  object = JSON.parse(pure_json_object)
   
  puts object.inspect
   
  db   = @@mongo.db(database)
  coll = db.collection(collection)
  coll.insert(object)
   
  content_type 'text/json'
  { :result => :ok }.to_json
end

get "/query/:database/:collection" do
  database, collection = params[:database], params[:collection]
  pure_json_query      = params[:query] || '{}'
  
  query = JSON.parse(pure_json_query)

  db   = @@mongo.db(database)
  coll = db.collection(collection)
  data = coll.find(query)

  result         = {}
  result[:count] = data.count
  result[:rows]  = data.collect

  content_type 'text/json'
  result.to_json
end

post "/upload/:database" do
  database      = params[:database]
  uploaded_file = params["file"][:tempfile]
  
  db   = @@mongo.db(database)
  fs   = Grid.new(db)
  oid  = fs.put(uploaded_file, :filename => params["file"][:filename])

  { :result => :ok, :id => oid.to_s }.to_json
end

get "/download/:database/:id" do
  database = params[:database]
  
  bson_id = BSON::ObjectID.from_string(params[:id])
  
  db   = @@mongo.db(database)
  fs   = Grid.new(db)
  file = fs.get(bson_id)
  
  if file.nil?
    status 404
    "File not found"
  else
    content_type file.content_type
    file.read
  end
end
