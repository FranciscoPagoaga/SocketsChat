#! /usr/bin/ruby -w

require 'socket'
require 'sqlite3'

class Server
  def initialize( port, ip )
    @server = TCPServer.open( ip, port )
    @connections = Hash.new
    @rooms = Hash.new
    @clients = Hash.new
    @timer = Hash.new
    @connections[:server] = @server
    @connections[:rooms] = @rooms
    @connections[:clients] = @clients
    @connections[:timer] = @timer
    run
  end

  def run
    loop {
      Thread.start(@server.accept) do | client |
        nick_name = client.gets.chomp.to_s
        @connections[:clients].each do |other_name, other_client|
          if nick_name == other_name || client == other_client
            client.puts "User already exists"
            Thread.kill self
          end
        end
        puts "#{nick_name} #{client}"
        @connections[:rooms][nick_name] = nil
        @connections[:clients][nick_name] = client
        @connections[:timer][nick_name] = 60
        client.puts "Connection Established"
        puts @connections[:clients][nick_name]
        Thread.new do
          while true
            sleep(@connections[:timer][nick_name])
            printCantMensajes(nick_name, client)            
          end
        end
        listen_user_messages( nick_name, client )
      end
    }.join
  end

  def listen_user_messages( username, client )
    db = SQLite3::Database.open 'Chatdb'
    loop {
      msg = client.gets.chomp
      if msg != ''
        if msg == '\h'
          client.puts '\h -> Show which commands are available
          \u -> Show which users are online on the server
          \c <ScreenName> -> Chat with the specified user
          \p -> Shows a list detailing how many messages you have pending and from which users
          \n -> Shows how often (in seconds) will the pending message show
          \n <Number> -> Changes how often (in seconds) will the pending message show'
        elsif msg == '\u'
          @connections[:clients].each do |other_name, other_client|
            unless other_name == username
              client.puts "#{other_name.to_s}"
            end
          end
        elsif msg.match /^\\c\s\w*$/ 
          other_name = msg.split(/\s/)[1]
          other_name = other_name.chomp
          results = db.execute("SELECT * FROM User where Name LIKE '#{other_name}'")
          puts "Reuslts = #{results}"
          if results.count() > 0
            @connections[:rooms][username] = other_name.chomp 
            client.puts "Chat Established"
            chat = db.execute("SELECT SentTo, SentBy, Content, isRead FROM Message 
              WHERE SentBy LIKE '#{other_name}' 
              AND SentTo LIKE '#{username}' 
              AND isRead = 0 
              ORDER BY Message.Id ASC")
            chat.each do |row1, row2,row3|
              client.puts "#{row2}: #{row3}"
            end
            chat = db.execute("UPDATE Message SET isRead = 1 
              WHERE SentBy LIKE '#{other_name}' 
              AND SentTo LIKE '#{username}' 
              AND isRead = 0 ")
          else
            client.puts "User doesn't exist"
          end
        elsif msg == '\p' 
          printCantMensajes( username, client )
        elsif msg == '\n'
          client.puts "#{@connections[:timer][username]} Seconds"
        elsif msg.match /^\\n\s[0-9]*$/ 
          new_timer = msg.split(/\s/)[1]
          @connections[:timer][username] = new_timer.to_i
          client.puts "Seconds changed to #{new_timer.to_s}"
        else 
          if @connections[:rooms][username] != nil
            other_name = @connections[:rooms][username].chomp
            if @connections[:clients].has_key?(other_name)
              other_client =  @connections[:clients][other_name.to_s]
              if @connections[:rooms][username] == other_name && @connections[:rooms][other_name.to_s] == username
                db.execute("INSERT INTO Message (SentTo, SentBy, Content, isRead) VALUES ('#{other_name}','#{username}','#{msg}',1)")
                other_client.puts "#{username.to_s}: #{msg}"
              elsif @connections[:rooms][username] == other_name && @connections[:rooms][other_name.to_s] != username
                db.execute("INSERT INTO Message (SentTo, SentBy, Content, isRead) VALUES ('#{other_name}','#{username}','#{msg}',0)")
                other_client.puts "User #{username} sent you a message"
              end
            else
              db.execute("INSERT INTO Message 
                (SentTo, SentBy, Content, isRead) 
                VALUES ('#{other_name}','#{username}','#{msg}',0)")
            end
          else
            client.puts "You have not chosen to chat with anyone"
          end
        end
      end

    }
  end
  
  def printCantMensajes( username, client )
    db = SQLite3::Database.open 'Chatdb'
    cantMensajes = db.execute("Select count(*) from Message 
    WHERE isRead=0 AND SentTo LIKE '#{username}'" )
    usuarios = db.execute("Select SentBy, count(*) from Message 
    WHERE isRead=0 
    AND SentTo LIKE '#{username}' 
    Group by SentBy ORDER by 1")
    client.puts "You have #{cantMensajes[0][0]} pending messages"
    if cantMensajes[0][0] > 0
      client.puts "User".ljust(15) + "Number of messages"
      usuarios.each {|usuario, cantidad| client.puts usuario.ljust(15) + cantidad.to_s}
    end
  end
  

end


  Server.new( 3000, "localhost" )