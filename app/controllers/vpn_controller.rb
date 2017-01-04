class VpnController < ApplicationController
  	skip_before_filter :verify_authenticity_token

	def all     
		render json: Vpn.all.as_json
	end
end
