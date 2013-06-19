require 'mongo'
require 'timeout'

STDOUT.sync = true

conn = Mongo::MongoClient.new("localhost").db("test")

while true
  begin
    Timeout.timeout(0.005) do
      conn["coll"].insert({'foo' => 'bar'})
    end
    print "."
  rescue Timeout::Error
    print "T"
  rescue Mongo::ConnectionFailure
    print "M"
  end
end
