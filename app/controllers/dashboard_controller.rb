class DashboardController < ApplicationController
  	skip_before_filter :verify_authenticity_token
	layout 'application'
	
	def index     
		render 'index'
	end

	def hosts     
		render 'hosts'
	end	

	def setup
		render 'setup'
	end
end
