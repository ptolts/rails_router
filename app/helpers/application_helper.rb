module ApplicationHelper

	def active name
		return 'active' if action_name == name
		return ''
	end

end
