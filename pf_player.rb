require 'digest/sha1'

class PfPlayer
	attr_accessor :username, :characters
	
	def initialize(username, password)
		@username = username
		@password = Digest::MD5.hexdigest(password)
		@characters = []
		@sock = nil	 
	end
	
	def connect(sock)
		@sock = sock
	end
	
	def disconnect()
		@sock.close() unless @sock.closed?
		@sock = nil
	end
	
	def check_password(password)
		@password == Digest::MD5.hexdigest(password)
	end
	
	def puts(str)
		@sock.write(str + "\n")
	end
	
	def gets
		@sock.gets.chomp
	end
	
	def print(str)
		@sock.write(str)
	end
	
	def create_character(given_name, family_name, archetype, event_system)
		char = PfCharacter.new(given_name, family_name, archetype, self, event_system)
		@characters.push( char )

		return char
	end
end