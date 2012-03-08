load "pf_object.rb"

class PfString < PfObject
	def to_s
		"Strippe"
	end
	
	def inspect(char)
		"Es sieht aus wie eine ganz normale Strippe. Könnte vielleicht nützlich sein."
	end
	
	def use(char)
		"Du weißt nicht wie du es benutzen sollst."
	end
	
	def take(char)
		already_taken = char.inventory.any? {|item| item.to_s == self.to_s}
		if already_taken
			"Du hast bereits eine Strippe im Inventar"
		else
			char.inventory.push(PfString.new())
			"Du nimmst die Strippe auf. Sie befindet sich jetzt in deinem Inventar."
		end
	end
	
	def attack(char)
		"Die Strippe hat dir doch gar nichts getan!"
	end
	
	def speak_to(char)
		"Willst du wirklich mit einer Strippe reden?"
	end
end