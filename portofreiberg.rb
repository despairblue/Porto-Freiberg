require 'pf_objects'
require 'pf_player'
require 'pf_character'
require 'pf_map'
require 'pf_quests'
require 'pf_event_system'
require 'yaml'
require 'pp'
require 'socket'
require "thread"

class PortoFreiberg
	def initialize( port ) 
		@serverSocket = TCPServer.new( "", port ) 
		@serverSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
		
		@players = load_players("players.yaml")
		@a_players = {}
		@a_chars = {}
		@socks = []
		@mutex = Mutex.new
		@a_players[@serverSocket] = self
		@a_players[STDIN] = self
		@threads = []
		@map = PfMap.new
		@event_system = PfEventSystem.new
		
		PfQuest.set_event_system(@event_system)
		PfQuest.init
		
		trap("TERM") do 
			puts "Porto Freiberg is terminating..."
			shutdown()
		end

		trap("KILL") do
			puts "Porto Freiberg was killed"
			shutdown()
		end

		trap("INT") do
			puts "Porto Freiberg caught an interrupt and is going to terminate"
			shutdown()
		end
		
		printf("Porto Freiberg lauscht auf Port %d\n", port)
	end # initialize

	def run
		while true
			res = select(@a_players.keys, nil, nil, 1)
			
			if res != nil then
				for sock in res[0]
					if sock == @serverSocket then
						@threads.push Thread.new {accept_new_connection}
					elsif sock == STDIN
						case gets.chomp
						when "list players"
							puts "> players:"
							@a_players.each do |sock, player|
								puts "> #{player.username}"
							end
						when "list chars"
							puts "> chars:"
							@a_chars.each do |sock, char|
								puts"> #{char.full_name}"
							end
						when "list threads"
							puts "> threads:"
							@threads.each do |t|
								if t.alive? then
									puts "> #{t}"
								else
									@threads.delete(t)
									t.join
								end
							end
						when "list socks"
							puts "> socks:"
							@socks.each do |sock|
								puts sock
							end
						when "restart"
							shutdown(true)
							return true
						end
					else
						if sock.eof? then
							str = sprintf("Client left %s:%s\n", sock.peeraddr[2], sock.peeraddr[1])
							
							puts "#{@a_players[sock].username} disconnected."
							
							sock.close
							@mutex.synchronize do
								# call disconnect on player and char, closing the sock und making them serializable
								@a_chars[sock].disconnect()
								@a_players[sock].disconnect()
								# deleting them from the active lists
								@a_chars.delete(sock)
								@a_players.delete(sock)
								@socks.delete(sock)
							end
						 
						else
							player = @a_players[sock]
							char = @a_chars[sock]
							
							if player.nil? or char.nil? then
								sock.write "bau kein scheiß"
								pp sock
								pp player
								pp char
							end

							cmd = sock.gets().chomp
							
							str = sprintf("[%s|%s]: %s\n", @a_players[sock].username, @a_chars[sock].full_name, cmd)
							@a_chars[sock].command(cmd)
							puts str
						end #if
					end #if
				end #for
			end #if
		end #while
	end #def
	
	private
	
	def accept_new_connection
		newsock = @serverSocket.accept
		
		@mutex.synchronize do
			@socks.push(newsock)
		end
		
		newsock.write("You're connected to Porto Freiberg\n")
		str = sprintf("Client joined %s:%s\n", newsock.peeraddr[2], newsock.peeraddr[1])
		
		login(newsock)
		
	end # accept_new_connection

	def shutdown(restart = false)
		@mutex.synchronize do
			@socks.each do |sock|
				sock.puts("Porto Freiberg wird heruntergefahren.") unless sock == @serverSocket or sock == STDIN
				sock.close unless sock == STDIN
			end
			@serverSocket.close
			
			@threads.each do |t|
				t.kill
			end
			
			@a_players.each_value do |p|
				p.disconnect
				puts "called #{p.username}.disconnect"
			end
			
			@a_chars.each_value do |c|
				c.disconnect
				puts "called #{c.full_name}.disconnect"
			end
		end
		
		File.open("players.yaml", "w") {|f| YAML.dump(@players, f)}
		
		exit unless restart
	end

	def register (sock)
		exists = true

		while exists
			sock.puts "Bitte gebe deinen gewünschten Benutzernamen ein: "
			username = sock.gets.chomp
			exists = @players.any?{ |p| p.username == username}
		end

		sock.puts "Bitte gebe jetzt dein Passwort ein: "
		password = sock.gets.chomp

		player = PfPlayer.new(username, password)

		@mutex.synchronize do
			@players.push(player)
		end

		return player
	end

	def login (sock)
		player = nil
		
		while player == nil
			sock.puts "Bitte gebe deinen Benutzernamen ein oder einfach nichts falls du noch nicht registriert bist: "
			username = sock.gets.chomp

			if username == ""
				register(sock)
				sock.puts "Bitte gebe deinen Benutzernamen ein oder einfach nichts falls du noch nicht registriert bist: "
				username = sock.gets.chomp
			end

			sock.puts "Bitte gebe jetzt dein Passwort ein: "
			password = sock.gets.chomp
			
			player = @players.detect{ |p|
				true if p.username == username and p.check_password(password)
			}
		end
		
		player.connect(sock)
		
		char = select_character(player)
		
		@mutex.synchronize do
			@a_players[sock] = player
			@a_chars[sock] = char
		end
	end

	def load_players(file)
		players = []
		unless File.exist?(file)
			File.open(file, 'w') {|f| YAML.dump(players, f)}
		end

		players = YAML.load_file("players.yaml")

		return players
	end

	def create_character(player)
		player.print "Vorname:"
		given_name = player.gets.chomp

		player.print "Nachname:"
		family_name = player.gets.chomp

		player.print "Archetyp:"
		archetype = player.gets.chomp

		char = player.create_character(given_name, family_name, archetype, @event_system)

		char.add_quest(PfQuest.get_quest_status())

		return char
	end

	def select_character(player)
		char = nil
		
		char = create_character(player) if player.characters.empty?

		while char == nil
			player.puts "Mit welchem Charakter möchtest du weiterspielen?"

			player.characters.each{ |c| player.puts c.full_name }

			player.puts 'Oder tippe "neu" ein um einen neuen Charakter zu erstellen.'

			input = player.gets

			create_character(player) if input == "neu"

			char = player.characters.detect{ |c|
				true if input == c.full_name
			}

			player.puts "Dieser Charakter existiert nicht." if char.nil?
		end
		
		player.puts("Du spielst jetzt mit #{char.full_name}")
		char.connect(@map, @event_system)

		return char
	end
	
	def method_missing(id)
		return "Method Missing #{id.id2name}"
	end
	
end #server

pf = PortoFreiberg.new(1337)
restart = pf.run

while restart == true do
	load 'pf_objects.rb'
	load 'pf_player.rb'
	load 'pf_character.rb'
	load 'pf_map.rb'
	load 'pf_quests.rb'
	load 'pf_event_system.rb'
	pf = PortoFreiberg.new(1337)
	restart = pf.run
end