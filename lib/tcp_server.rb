require 'socket'                 # Get sockets from stdlib

server = TCPServer.open(2000)
puts ">> Waiting for connections..."
loop {                           # Servers run forever
	socket = server.accept
   Thread.start(socket) do |client|
   		puts ">> Connection received..."
   		while line = socket.gets
   		  puts ">> #{line}" # Prints whatever the client enters on the server's output
   		end
	   client.puts(Time.now.ctime)   # Send the time to the client
	   client.puts('Hi. Thanks for connecting to me.')   # Send the time to the client
	   client.puts "Closing the connection. Bye!"
	   client.close                  # Disconnect from the client
   end
}