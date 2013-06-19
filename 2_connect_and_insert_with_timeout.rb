require 'mongo'
require 'timeout'

STDOUT.sync = true

while true
  begin
    Timeout.timeout(0.005) do
      conn = Mongo::MongoClient.new("localhost").db("test")
      conn["coll"].insert({'foo' => 'bar'})
    end
    print "."
  rescue Timeout::Error
    print "T"
  rescue Mongo::ConnectionFailure
    print "M"
  end
end
