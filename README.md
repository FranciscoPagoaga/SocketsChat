# SocketsChat
This repo contains a private chat made using Sockets and Sqlite in Ruby. It's structured employing Object Oriented Programming. It contains 2 classes: Server.rb and Client.rb. In order to run this project, you first have to run the Server File, and while it is running open a new Command Line to run the Client File in order for it to interact with the Server. 

The database needed to run the project comes already packaged in the project and it contains 4 users to try it out

## Getting Started
Before running the project, you have to install certain things before.

### Prerequisites
In order to run this project you will need to install sqlite and sqlite for ruby.
To install build dependencies

```
sudo apt-get install sqlite3 libsqlite3-dev
```
And
```
sudo gem install sqlite3-ruby
```

### Installation
1. Clone the repo
```
git clone https://github.com/FranciscoPagoaga/SocketsChat.git
```

## Usage
To run this project 
1. Run the Server File inside the project folder
```
./Server.rb
```

2. Run the Client File inside the project folder
```
./Client.rb
```

After this you will have a menu in which you can login or register. The repo comes with some users by defualt, althought you can also create your own user.
Default User List (User:Password):
* fpagoaga:12345
* Luis:12345
* prueba:12345
* asd:12345

After you've logged in, you can make use of different commands, here is a list of all the commands available:
* \h -> Show which commands are available
* \u -> Show which users are online on the server
* \c <ScreenName> -> Chat with the specified user
* \p -> Shows a list detailiong how many messages you have pending and from which users
* \n -> Shows how often (in seconds) will the pending message show
* \n <Number> -> Changes how often (in seconds) will the pending message show

Now, you can choose someone to chat with (Its recommended that you actually open a new Command Line to run another Client and get another user to chat with). If you get a message sent and you're not chatting with that person at the moment, you will get a message saying that user just sent you a message. Otherwise, if you just logged in and have pending messages to read, when you switch to those chats its will get the sent messages from before.