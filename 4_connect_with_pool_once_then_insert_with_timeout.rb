require 'mongo'
require 'timeout'

STDOUT.sync = true

db = Mongo::MongoClient.new("localhost", :pool_size => 5).db("test")

while true
  begin
    Timeout.timeout(0.005) do
      db["coll"].insert({'foo' => 'bar'})
    end
    print "."
  rescue Timeout::Error
    print "T"
  rescue Mongo::ConnectionFailure
    print "M"
  end
end
