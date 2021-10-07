#! /usr/bin/ruby -w
require 'io/console'
require 'socket'
require 'digest'
require 'sqlite3'

class Client
  def initialize( server, screenName )
    @screenName = screenName
    @server = server
    @request = nil
    @response = nil
    listen
    send
    @request.join
    @response.join
  end

  def listen
    @response = Thread.new do
      loop {
        msg = @server.gets.chomp
        puts "#{msg}"
      }
    end
  end

  def send
    @server.puts(@screenName)
    @request = Thread.new do
      loop {
        msg = $stdin.gets.chomp
        @server.puts( msg )
      }
    end
  end
end


screenName = ""
db = SQLite3::Database.open 'Chatdb'
while true
  puts ("SISAPBOOK \n1. Login\n2. Register")
  option = gets.to_i
  if option == 1
    puts "ScreenName:"
    screenName = gets.chomp
    puts "Password:"
    password = gets.chomp
    results = db.execute("SELECT * FROM User where Name LIKE ?",[screenName])
    hash =  Digest::SHA256.hexdigest password
    if results.count() > 0
      user = results[0][1]
    end
    if user == hash
      puts "Logged in Succesfully!"
      puts "Press any key to continue"
      STDIN.getch
      system("clear")
      break;
    else
      puts "Password or Username Incorrect "
    end
  elsif option == 2
    puts "Enter ScreenName:"
    screenName = gets.chomp
    puts "Enter Password:"
    password = gets.chomp
    puts "Confirm Password:"
    confirmPassword = gets.chomp
    if password == confirmPassword
      results = db.execute("SELECT * FROM User where Name LIKE ?",[screenName])
      if results.count() == 0
        hashedPassword = Digest::SHA256.hexdigest password 
        db = SQLite3::Database.open 'Chatdb'
        db.execute("INSERT INTO User (Name, Password) VALUES (?,?)",[screenName,hashedPassword])
        puts "User Created Succesfully"
        puts "Press any key to continue..."
        STDIN.getch
        system("clear")
      else
        puts "User already exists"
      end
    else
      puts "Passwords are different"
    end
     
  else
    puts "Enter Valid Option"
  end
end

db.close if db

server = TCPSocket.open( "localhost", 3000 )
Client.new( server, screenName )