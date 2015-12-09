### Using ruby-test with a Ruby project running on Vagrant or other VM

**Warning:** This is kind of an insecure setup.

On the VM, create a server that accepts and runs shell commands. For
example, create this command (e.g., `~/bin/command_server`):

```ruby
#!/usr/bin/env ruby

require 'socket'
require 'open3'

port = ARGV[0] || 2000
puts "Starting server on port #{port}"
server = TCPServer.new(port.to_i) # Server bind to port 2000
loop do
  client = server.accept    # Wait for a client to connect
  cmd = client.gets
  client.puts "Running command: #{cmd}"

  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
    stdin.close
    while !stderr.eof? || !stdout.eof?
      client.print stderr.gets
      client.print stdout.gets
    end
  end
end
```

Start the server: `~/bin/command_server` from your project's directory in the Vagrant VM.

In the ruby-test settings, wrap each test command in an `echo ''`, and append `| nc VM_ADDR 2000`. Replace `VM_ADDR` with the IP address or hostname of the
VM. `nc` (netcat) will forward the test commands to the server, which will
then execute the commands.

For example:

rspecFileCommand:

```
echo 'bundle exec spring rspec {relative_path}' | nc 10.11.12.13 2000
```
