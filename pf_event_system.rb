class PfEventSystem
	def initialize()
		@inspect_event_listeners = []
		@use_event_listeners = []
		@take_event_listeners = []
		@attack_event_listeners = []
		@speak_to_event_listeners = []
	end
	
	def add_listener(kind, obj_name, quest_id, &proc)
		event = PfEvent.new(obj_name, quest_id, proc)
		case kind
		when "INSPECT"
			@inspect_event_listeners.push(event)
		when "USE"
			@use_event_listeners.push(event)
		when "TAKE"
			not_there = @take_event_listeners.any? {}
			@take_event_listeners.push(event)
		when "ATTACK"
			@attack_event_listeners.push(event)
		when "SPEAKTO"
			@speak_to_event_listeners.push(event)
		end
	end
	
	def raise_event(kind, char, object)
		case kind
		when "INSPECT"
			@inspect_event_listeners.each do |event|
				char_has_quest = char.quests.any? {|q| q.quest_id == event.quest_id}
				if char_has_quest
					if object.to_s == event.obj_name
						event.proc.call(char, object)
					end
				end
			end #do
		when "USE"
			@use_event_listeners.each do |event|
				char_has_quest = char.quests.any? {|q| q.quest_id == event.quest_id}
				if char_has_quest
					if object.to_s == event.obj_name
						event.proc.call(char, object)
					end
				end
			end #do
		when "TAKE"
			@take_event_listeners.each do |event|
				char_has_quest = char.quests.any? {|q| q.quest_id == event.quest_id}
				if char_has_quest
					if object.to_s == event.obj_name
						event.proc.call(char, object)
					end
				end
			end #do
		when "ATTACK"
			@attack_event_listeners.each do |event|
				char_has_quest = char.quests.any? {|q| q.quest_id == event.quest_id}
				if char_has_quest
					if object.to_s == event.obj_name
						event.proc.call(char, object)
					end
				end
			end #do
		when "SPEAKTO"
			@speak_to_event_listeners.each do |event|
				char_has_quest = char.quests.any? {|q| q.quest_id == event.quest_id}
				if char_has_quest
					if object.to_s == event.obj_name
						event.proc.call(char, object)
					end
				end
			end #do
		end #case
	end
end

class PfEvent
	attr_accessor :obj_name, :quest_id, :proc
	def initialize(obj_name, quest_id, proc)
		@obj_name = obj_name
		@quest_id = quest_id
		@proc = proc
	end
end