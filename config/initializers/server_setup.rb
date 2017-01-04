begin
	Speedtest.run if !Speedtest.first
rescue => msg
	Rails.logger.warn "Speedtest failed."
end
Vpn.setup_vpns
Qos.setup
