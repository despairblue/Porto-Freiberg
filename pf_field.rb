load 'pf_objects.rb'

class PfField
	attr_accessor :description, :objects, :npcs, :chars
	
	def initialize(description, objects=[], npcs=[])
		@description = description
		@objects = objects
		@npcs = npcs
		@chars = []
	end
	
	def broadcast_msg (char, msg)
		@chars.each do |c|
			c.puts("[#{char.full_name}]: #{msg}") unless c == char
		end
	end
	
	def who
		# @chars.each do |c|
		# 	puts c
		# end
		return @chars
	end
end