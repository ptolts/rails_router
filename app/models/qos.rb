#encoding: utf-8

class Qos
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "qos", database: "router"

  field :mark, type: String
  field :name, type: String
  field :class_number, type: Integer
  field :priority, type: Integer
  field :rate, type: Integer

  has_many :hosts, class_name: "Host"

  # before_save :check_table 

  def serializable_hash options
    hash = super {}
    hash[:id] = self.id
    return hash
  end

  def run
    Run.run "sudo tc class add dev #{MAIN_INTERFACE} parent 1:1 classid 1:#{class_number} htb rate #{rate}kbps prio #{priority}"
    Run.run "sudo tc filter add dev #{MAIN_INTERFACE} parent 1:0 protocol ip prio #{priority} handle #{class_number} fw classid 1:#{class_number}"
    # Run.run "sudo tc qdisc add dev #{MAIN_INTERFACE} parent 1:#{class_number} handle #{class_number}: sfq perturb 10"
  end

  def self.setup
    rates = Speedtest.first
    rates = {"downRate" => 70609240/8/1000, "upRate" => 7060924/8/1000} if !rates
    downRate = (rates["downRate"] * 0.95).to_i
    upRate = (rates["upRate"] * 0.95).to_i
    halfUpRate = (rates["upRate"] * 0.5).to_i  

    Run.run "sudo tc qdisc add dev #{MAIN_INTERFACE} root handle 1: htb default 10"
    Run.run "sudo tc class add dev #{MAIN_INTERFACE} parent 1: classid 1:1 htb rate #{upRate}kbps ceil #{upRate}kbps"

    default_one = Qos.where(mark:"0x1").first || Qos.create(mark:"0x1",rate:upRate,class_number:10,priority:1,name:"High")
    default_one.run

    default_two = Qos.where(mark:"0x2").first || Qos.create(mark:"0x2",rate:halfUpRate,class_number:20,priority:2,name:"Low")
    default_two.run

    Qos.not_in(mark:["0x1","0x2"]).each {|e| e.run}
  end

end