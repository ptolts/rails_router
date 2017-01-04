class Run

  def self.run cmd
    Rails.logger.warn cmd
    if `uname -a` =~ /arm/i
      res = `#{cmd}`
      Rails.logger.warn "Result: #{res}"
      return res
    end
    return nil
  end

end