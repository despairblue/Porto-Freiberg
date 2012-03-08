load 'pf_objects.rb'
load 'pf_field.rb'

class PfMap
	def initialize()
		@map = Array.new(5, Array.new(5, PfField.new("empty field")))
		
		dsc = "Du befindest dich in der Weingasse in Porto Freiberg. Du siehst schöne Häuser und hier liegen eine [Strippe] und andere Sachen rum."
		objs = [PfString.new]
		
		@map[2][2] = PfField.new(dsc, objs, [])
	end
	
	def field(pos)
		return @map[pos[0]][pos[1]]
	end
	
end