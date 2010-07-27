require "memento"

require "test/unit"
require "rack/test"

require "digest"
require "mongo"
include Mongo

TEST_DB, TEST_COLLECTION="testdb", "testcollection"

set :environment, :test