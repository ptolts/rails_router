require 'mongoid'
require './app/models/host'
require './app/models/vpn'

class Run
  def self.run cmd
    if `uname -a` =~ /arm/i
      res = `#{cmd}`
      puts res
      return res
    end
    return nil
  end
end

Mongoid.load!("./config/mongoid.yml", :development)

puts "Working..."

result = `sudo nmap -sP 192.168.3.1/24`
results = result.scan(/(Nmap scan report for.*?\).*?\))/m)

mac_array = []

results.each do |host_data|
	host_data = host_data.first
	ip = host_data.match(/\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/)[0]
	mac = host_data.match(/([0-9A-F]{2}[:-]){5}([0-9A-F]{2})/)[0]
	card_type = host_data.match(/MAC.*?\((.*)\)/)[1]

	mac_array << mac

	puts "IP: #{ip} MAC: #{mac}"

	host = Host.where(mac_address:mac).first

	host = Host.create(mac_address:mac,ip_address:ip) if !host

	host.ip_address = ip
	host.online = true
	host.card_type = card_type
	host.seen_count += 1
	host.save
end

Host.not_in(mac_address: mac_array).update_all(online:false)

