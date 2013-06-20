require 'mongo'

STDOUT.sync = true

conn = Mongo::MongoClient.new("localhost", :op_timeout => 0.001).db("test")

while true
  begin
    conn["coll"].insert({'foo' => 'bar'})
    print "."
  rescue Mongo::OperationTimeout
    print "T"
  rescue Mongo::ConnectionFailure
    print "M"
  end
end
