require 'mongo'
require 'timeout'

STDOUT.sync = true

while true
  begin
    Timeout.timeout(0.005) do
      begin
        conn = Mongo::MongoClient.new("localhost")
        conn.db("test")["coll"].insert({'foo' => 'bar'})
        conn.close
      end
    end
    print "."
  rescue Timeout::Error
    print "T"
  rescue Mongo::ConnectionFailure
    print "M"
  end
end
