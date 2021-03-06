require 'socket'

def HasBackslashEnd(path)
    if path.rindex('/') == path.length - 1
        return true
    end
    return false
end

def getResponseFromClient(client)
    # get input from client
    first_line = client.gets
    verb, path = first_line.split

    if verb == nil and path == nil
        first_line = client.gets
        verb, path = first_line.split

        # we exit, as no valid input was given
        if verb == nil and path == nil
            return nil, nil
        end
    end

    data = ""
    # check that verb is GET
    if verb != 'GET'
        header = "405 Method Not Allowed"
        return header, data
    end

    # remove '/' from the begining of path
    if path.index('/') == 0
        path = path.slice(1, path.length)
    end

    # check path, and GET proper answer
    if File.file?(path)
        header = "200 OK"
        data = File.read(path)
    elsif File.directory?(path)
        # Check if path has '/' at the end
        if HasBackslashEnd(path)
            add = "*"
        else
            add = "/*"
        end
        header = "200 OK"
        data = Dir.glob(path + add).join("\n")
    else
        header = "404 Not Found"
    end
    return header, data
end

if __FILE__ == $0
    httpd = TCPServer.open("0.0.0.0", 6000)
    client = httpd.accept

    # header
    client.puts "HTTP/1.0 200 OK"
    client.puts ""

    loop do
        # get input from client
        header, data = getResponseFromClient(client)
        if header == nil and data == nil
            break
        else
            client.puts header
            client.puts data
        end
    end

    # end connection
    client.puts "Closing connection..."
    client.close
end
