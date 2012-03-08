class PfQuest
	private_class_method :new
	
	def PfQuest.set_event_system(event_system)
		@@event_system = event_system
	end
	
	def PfQuest.init()
		@@event_system.add_listener("TAKE", "Strippe", get_quest_status.quest_id) do |c, o|
			c.puts "Du hast die #{o.to_s} des Todes aufgenommen und bist von nun an dazu verdammt sie in deinem Inventar zu haben. Muhahahaha"
		end
	end
	
	def PfQuest.get_quest_status
		quest_id = "pf_quest"
		return PfQuestStatus.new(quest_id)
	end
end

class PfQuestStatus
	attr_reader :quest_id
	attr_accessor :quest_state
	
	def initialize(quest_id, quest_state = {})
		@quest_id = quest_id
		@quest_state = quest_state
	end
end