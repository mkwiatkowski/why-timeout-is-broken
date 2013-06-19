require 'mongo'

STDOUT.sync = true

while true
  begin
    conn = Mongo::MongoClient.new("localhost").db("test")
    conn["coll"].insert({'foo' => 'bar'})
    print "."
  rescue Mongo::ConnectionFailure
    print "M"
  end
end
