#encoding: utf-8

class Vpn
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "vpns", database: "router"

  field :country, type: String
  field :config, type: String
  field :ip, type: String

  # belongs_to :restaurant, class_name: "Restaurant", index: true
  has_many :hosts, class_name: "Host"

  # default_scope -> { asc(:position) }
  before_save :check_table 

  def serializable_hash options
    hash = super {}
    hash[:id] = self.id
    return hash
  end

  def check_table
    Iproute2.look_up_iproute2_number country
  end

  def check_interface
    Iproute2.interface country
  end  

  def bring_online
    check_table
    check_interface
  end

  def self.setup_vpns

    Run.run "sudo iptables -F"
    Run.run "sudo iptables -t nat -A PREROUTING -p tcp -d 192.168.3.1 --dport 80 -j REDIRECT --to-ports 3000"
    Run.run "sudo iptables -t nat -A POSTROUTING -o #{MAIN_INTERFACE} -j MASQUERADE"
    Run.run "sudo iptables -A FORWARD -i wlan0 -o #{MAIN_INTERFACE} -j ACCEPT"

    interfaces = Run.run "sudo ip address show"

    interfaces ||= INTERFACES

    interfaces = interfaces.scan(/^([0-9]{1,}.*?)(?=^[0-9]|\z)/m).flatten

    interfaces.each do |interface|
      next unless interface =~ /POINTOPOINT/
      name = interface.scan(/[0-9]{1,}: ([[:alnum:]]*):/).flatten.first
      ip = interface.scan(/inet (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/).flatten.first
      Iproute2.look_up_iproute2_number name
      Run.run "sudo ip route replace default via #{ip} dev #{name} table #{name}"
      # Run.run "sudo ip route add default via #{ip} dev #{name} table #{name}"
      Run.run "sudo iptables -t nat -A POSTROUTING -o #{name} -j MASQUERADE"
      vpn = Vpn.where(country: name).first
      vpn = Vpn.create(country:name) unless vpn
      vpn.ip = ip
      vpn.save
    end

    Run.run "sudo ip route flush cache"

    return false
  end

end