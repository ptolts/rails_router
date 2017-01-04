#encoding: utf-8

class Iproute2

  def self.insert_table name
    number = Iproute2.table_data.scan(/([0-9]{1,})/).to_a.flatten.sort.last.to_i
    number += 1
    Run.run "echo \"#{number} #{name}\" | sudo tee -a /etc/iproute2/rt_tables"
    return number
  end

  def self.look_up_iproute2_number country
    if number = Iproute2.table_data.match(/([0-9]{1,}) #{country}/) and number = number[0]
      return number
    else
      number = Iproute2.insert_table country
      return number
    end
  end

  def self.table_data
    table = Run.run "sudo cat /etc/iproute2/rt_tables"
    table ||= TABLE
    return table
  end

  def self.interface country
    interfaces = Run.run "sudo ip address show"

    interfaces ||= INTERFACES

    interfaces = interfaces.scan(/^([0-9]{1,}.*?)(?=^[0-9]|\z)/m).flatten

    interfaces.each do |interface|
      next unless interface =~ /POINTOPOINT/
      name = interface.scan(/[0-9]{1,}: ([[:alnum:]]*):/).first
      ip = interface.scan(/inet (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/).first
      Iproute2.look_up_iproute2_number name
      Run.run "sudo ip route replace default via #{ip} dev #{name} table #{name}"
    end

    Run.run "sudo ip route flush cache"

    return false
  end

end