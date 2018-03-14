require 'socket'                 # Get sockets from stdlib

server = TCPServer.open(2000)
puts ">> Waiting for connections..."
loop {                           # Servers run forever
   Thread.start(server.accept) do |client|
   		puts ">> Connection received..."
	   client.puts(Time.now.ctime)   # Send the time to the client
	   client.puts('Hi. Thanks for connecting to me.')   # Send the time to the client
	   client.puts "Closing the connection. Bye!"
	   client.close                  # Disconnect from the client
   end
}