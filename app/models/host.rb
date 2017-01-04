#encoding: utf-8

class Host
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "hosts", database: "router"

  field :hostname, type: String
  field :ip_address, type: String
  field :mac_address, type: String
  field :card_type, type: String, default: "Unknown"
  field :seen_count, type: Integer, default: 0
  field :online, type: Boolean, default: true

  belongs_to :vpn, class_name: "Vpn", index: true
  belongs_to :qos, class_name: "Qos", index: true

  # default_scope -> { asc(:position) }
  before_save :set_rules

  def serializable_hash options
    hash = super {}
    hash[:id] = self.id
    hash[:vpn] = self.vpn.id if self.vpn
    return hash
  end

  def set_rules

    lines = []
    iptables = Run.run "sudo iptables -t mangle --line-numbers --list PREROUTING"
    iptables.each_line do |line|
      next unless line =~ /#{ip_address}/
      lines << line.to_i
    end
    lines.reverse.each{|e| Run.run "sudo iptables -t mangle -D PREROUTING #{e}"}

    if qos
      Run.run "sudo iptables -t mangle -A PREROUTING -s #{ip_address} -j MARK --set-mark #{qos.class_number}"
    end

    if vpn
      Run.run "sudo ip rule del from #{ip_address}"
      Run.run "sudo ip rule add from #{ip_address} table #{vpn.country}"
      Run.run "sudo ip route flush cache"
    else
      Run.run "sudo ip rule del from #{ip_address}"
      Run.run "sudo ip route flush cache"
    end  
  end

  def mac_address=(val)
    self[:mac_address] = val.upcase if val
  end

  def self.create_self target_ip
    regex = /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}.*?([0-9A-F]{2}[:-]){5}([0-9A-F]{2}))/i
    arp_table = Run.run "sudo arp -v"
    arp_table ||= ARP_TABLE
    result = arp_table.scan(regex).inject({}) do |res,x|
      value = x.first.to_s
      puts "'#{value.to_s}'"
      ip = value.match(/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/)[0]
      mac = value.match(/([0-9A-F]{2}[:-]){5}([0-9A-F]{2})/i)[0]
      res[ip] = mac
      next res
    end
    target_host = result[target_ip]
    host = Host.where(mac_address:target_host).first
    host ||= Host.create(mac_address:target_host,ip_address: target_ip)
    return host
  end  

end