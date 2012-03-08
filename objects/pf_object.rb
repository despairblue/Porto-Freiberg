class PfObject
	
def to_s
		"Ein Ding"
	end
	
	def inspect(char)
		"Es handelt sich hier um irgendein Ding. Du kannst nicht erkennen was es ist."
	end
	
	def use(char)
		"Du weißt nicht wie du es benutzen sollst."
	end
	
	def take(char)
		char.inventory.push(self)
		"Du nimmst #{self.to_s} \n Es befindet sich jetzt in deinem Inventar."
	end
	
	def attack(char)
		"Das Ding wehrt sich nicht, also lass es doch in Frieden"
	end
	
	def speak_to(char)
		"Das Ding redet nicht mit dir, egal von welcher Seite du es ansprichst. Du denkst dir 'Wie unhöflich'"
	end
	
	alias view to_s
end