require 'date'

class PfCharacter
	attr_accessor :family_name, :given_name, :inventory, :quests
	
	def initialize(given_name, family_name, archetype, player, event_system)
		@player = player
		@family_name = family_name
		@given_name = given_name
		@archetype = archetype
		@date_of_birth = DateTime.now
		@inventory = []
		@position = [2,2]
		@map = nil
		@quests = []
		@money = 0
		@hp = 100
		@mp = 100
		@ap = 100
		@event_system = event_system
	end
	
	def connect (map, event_system)
		@map = map
		field.chars.push(self)
		
		@event_system = event_system
	end
	
	def disconnect
		field.chars.delete(self)
		@map = nil
		@event_system = nil
	end
	
	def add_quest(q)
		@quests.push(q)
	end
	
	def field
		@map.field(@position)
	end
	
	def full_name
		return @given_name + " " + @family_name
	end
	
	def puts(str)
		@player.puts(">> #{str}")
	end
	
	def gets
		@player.gets
	end
	
	def command(str)
		if str == ""
			puts @map.field(@position).description
			return
		end
		str = str.split(" ")
		cmd = str[0]
		str.delete_at(0)
		str = str.join(" ")
		
		# puts "[#{cmd},#{str}]"
		
		case cmd
		when "betrachte"
			if str.empty? then
				puts field.description
			else
				item = @inventory.detect { |item| item.to_s == str}
				item = field.objects.detect { |item| item} if item == nil
				if item.nil? then
					puts "Du hast kein #{str} in deinem Inventar."
				else
					puts item.inspect(self)
					@event_system.raise_event("INSPECT", self, item)
				end
			end
		when "benutze"
		when "rede"
		when "sage"
			field.broadcast_msg(self, str)
		when "gehe"
		when "nimm"
			if str.empty?
				field.objects.each do |item|
					puts item.to_s
				end
				puts "Was möchtest du nehmen?"
			else
				item = field.objects.detect{|item| item.to_s == str}
				if item.nil?
					puts "Hier liegt kein #{str} rum."
				else
					puts item.take(self)
					@event_system.raise_event("TAKE", self, item)
				end
			end
		when "attackiere"
		when "wer"
			field.who.each do |c|
				puts c.full_name()
			end
		when "journal"
		when "gib"
		when "inventar"
			if @inventory.empty?
				puts "Dein Inventar ist leer"
			else
				@inventory.each do |item|
					puts "[#{item.to_s}]"
				end #do
			end #if
		else
			pp str
			pp cmd
			puts "Dieser Befehlt ist mir nicht bekannt."
		end #case
	end #command
end #class