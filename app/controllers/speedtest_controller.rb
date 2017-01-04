class SpeedtestController < ApplicationController
  	skip_before_filter :verify_authenticity_token

	def save     
		data = JSON.parse(params[:data])
		speedtest = Speedtest.find(data["id"])
		speedtest.upRate = data["upRate"]
		speedtest.downRate = data["downRate"]
		speedtest.save
		render json: speedtest.as_json
	end

	def fetch
		render json: Speedtest.first.as_json
	end
end
