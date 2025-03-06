require 'webrick'

class App
  def call(env)
    [200, {'Content-Type' => 'text/plain'}, ['Hello, world!']]
  end
end


server = WEBrick::HTTPServer.new(:Port => 3000)

server.mount_proc '/' do |req, res|
  res.status = 200
  res['Content-Type'] = 'text/plain'
  res.body = "Hello, world!"
end

trap "INT" do
  server.shutdown
end

server.start
