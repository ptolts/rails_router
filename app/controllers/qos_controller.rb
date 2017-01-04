class QosController < ApplicationController
  	skip_before_filter :verify_authenticity_token

	def all     
		render json: Qos.all.as_json
	end
end
