require 'mongo'

STDOUT.sync = true

while true
  begin
    conn = Mongo::MongoClient.new("localhost")
    conn.db("test")["coll"].insert({'foo' => 'bar'})
    conn.close
    print "."
  rescue Mongo::ConnectionFailure
    print "M"
  end
end
