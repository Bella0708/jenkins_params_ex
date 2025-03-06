require './app'

Rack::Server.new(
  app: App.new,
  server: 'puma',
  Host: '0.0.0.0',
  Port: 3000
).start
