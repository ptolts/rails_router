#encoding: utf-8

class GeoPoint
  attr_accessor :lat, :lon
  def initialize(lat, lon)
    @lat=Float(lat)
    @lon=Float(lon)
  end
  def to_s
    "[#{lat}, #{lon}]"
  end
  def distance(p2)
    Math.sqrt((p2.lon - lon)**2 + (p2.lat-lat)**2)
  end
end

class Speedtest
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "speedtest", database: "router"

  field :upRate, type: Float
  field :downRate, type: Float


  DEBUG = true

  DOWNLOAD_FILES = [
    'speedtest/random750x750.jpg',
    'speedtest/random1500x1500.jpg',
  ]

  UPLOAD_SIZES = [
    197190,
    483960
  ]
  DOWNLOAD_RUNS=4  

  def serializable_hash options
    hash = super {}
    hash[:id] = self.id
    return hash
  end

  def timemillis(time)
    (time.to_f*1000).to_i
  end

  def self.run
    Speedtest.new.run
  end

  def run
    @a = Mechanize.new
    @a.open_timeout=1
    @a.read_timeout=1
    server = pickServer
    @server_root = server[:url]
    latency = server[:latency]
    # puts "Server #{@server_root}"
    downRate = download/8/1000
    # puts "Download: #{pretty_speed downRate}"
    upRate = upload/8/1000
    # puts "Upload: #{pretty_speed upRate}"
    Speedtest.create(upRate: upRate, downRate: downRate)
    {:server => @server_root, :latency => latency, :downRate => downRate, :upRate => upRate}
  end

  def pretty_speed(speed)
    units = [ "bps", "Kbps", "Mbps", "Gbps"]
    idx=0
    while speed > 1024 #&& idx < units.length - 1
      speed /= 1024
      idx+=1
    end
    "%.2f #{units[idx]}" % speed
  end

  def log(msg)
    if DEBUG
      puts msg
    end
  end

  def downloadthread(url)
    page = @a.get(url)
    Thread.current["downloaded"] = page.body.length
    #log "#{url} #{Thread.current["downloaded"]}"
  end

  def download
    threads=[]

    start_time=Time.new
    DOWNLOAD_FILES.each { |f| 
      1.upto(DOWNLOAD_RUNS) { |i|
        threads << Thread.new(f) { |myPage|
          msec=timemillis(Time.new)
          downloadthread("#{@server_root}/#{myPage}?x=#{msec}&y=#{i}")
        }
      }
    }
    total_downloaded=0
    threads.each { |t|  
      t.join
      total_downloaded += t["downloaded"]
    }
    total_time=Time.new - start_time 
    log "Took #{total_time} seconds to download #{total_downloaded} bytes in #{threads.length} threads"
    total_downloaded * 8 / total_time
  end

  def uploadthread(url, myData)
    page = @a.post(url, { "content0" => myData })
    Thread.current["uploaded"] = page.body.split('=')[1].to_i
    #log "#{url} #{Thread.current["uploaded"]}"
  end

  def randomString(alphabet, size)
    (1.upto(size)).map {alphabet[rand(alphabet.length)] }.join
  end

  def upload
    runs=4
    data=[]
    UPLOAD_SIZES.each { |size|
      1.upto(runs) { 
        data << randomString(('A'..'Z').to_a, size)
      }
    }

    threads=[]
    start_time=Time.new
    threads = data.map { |data| 
      Thread.new(data) { |myData|
        msec=timemillis(Time.new)
        uploadthread("#{@server_root}//speedtest/upload.php?x=#{rand}", myData)
      }
    }
    total_uploaded=0
    threads.each { |t|  
      t.join
      total_uploaded += t["uploaded"]
    }
    total_time=Time.new - start_time 
    log "Took #{total_time} seconds to upload #{total_uploaded} bytes in #{threads.length} threads"
    total_uploaded * 8 / total_time
  end

  def pickServer
    page = @a.get("http://www.speedtest.net/speedtest-config.php")
    ip,lat,lon=page.body.scan(/<client ip="([^"]*)" lat="([^"]*)" lon="([^"]*)"/)[0]
    orig=GeoPoint.new(lat, lon)
    log "Your IP: #{ip}\nYour coordinates: #{orig}\n"
    page = @a.get("http://www.speedtest.net/speedtest-servers.php")
    sorted_servers = page.body.scan(/<server url="([^"]*)" lat="([^"]*)" lon="([^"]*)/).map do |x| 
      next {
        :distance => orig.distance(GeoPoint.new(x[1],x[2])),
        :url => x[0].split(/(http:\/\/.*)\/speedtest.*/)[1]
      } 
    end.sort_by { |x| x[:distance] }

    # sort the nearest 10 by download latency
    latency_sorted_servers = sorted_servers[0..9].map do |x|
      next {
        :latency => ping(x[:url]),
        :url => x[:url]
      }
    end.sort_by { |x| x[:latency] }

    selected=latency_sorted_servers[0]
    log "Automatically selected server: #{selected[:url]} - #{selected[:latency]} ms"
    selected
  end

  def ping(server)
    times=[]
    1.upto(6) do
      start=Time.new
      msec=timemillis(start)
      begin
        page=@a.get("#{server}/speedtest/latency.txt?x=#{msec}")
        times << Time.new-start
      rescue Timeout::Error
        times << 999999
      end
    end
    times.sort
    times[1,4].inject(:+)*1000/4 # average in milliseconds
  end  
end