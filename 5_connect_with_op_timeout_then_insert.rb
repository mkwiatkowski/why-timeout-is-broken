require 'mongo'

STDOUT.sync = true

db = Mongo::MongoClient.new("localhost", :op_timeout => 0.001).db("test")

while true
  begin
    db["coll"].insert({'foo' => 'bar'})
    print "."
  rescue Mongo::OperationTimeout
    print "T"
  rescue Mongo::ConnectionFailure
    print "M"
  end
end
