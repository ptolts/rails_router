class HostController < ApplicationController
  	skip_before_filter :verify_authenticity_token

	def all     
		render json: Host.all.as_json
	end

	def self
		host = Host.where(ip_address:request.ip).first
		if !host
			host = Host.create_self request.ip
		end
		render json: host.as_json
	end	

	def save
		data = JSON.parse(params[:data])
		host = Host.find(data["id"])

		if data["vpn_id"]
			host.vpn = Vpn.find(data["vpn_id"])
		else 
			host.vpn = nil
		end

		if data["qos_id"]
			host.qos = Qos.find(data["qos_id"])
		else 
			host.qos = nil
		end

		host.save
		render json: host.as_json
	end
end
