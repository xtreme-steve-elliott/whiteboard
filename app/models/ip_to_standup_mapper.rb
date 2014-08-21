class IpToStandupMapper
  def initialize(standups: Standup.all)
    self.standups = standups
  end

  def authorized?(ip_address_string: "0.0.0.0")

    begin
      ip_address = IPAddr.new(ip_address_string)
      authorized_ips = standups.map(&:ip_addresses).flatten
      return authorized_ips.any? { |ip| ip.include? ip_address }

    rescue

      Rails.logger.debug "Rescued from exception while authenticating IP: '#{ip_address_string}'"
      return false
    end
  end

  alias_method :includes?, :authorized?

  def standups_matching_ip_address(ip_address: "0.0.0.0")
    standups.select do |standup|
      standup.ip_addresses.empty? || standup.ip_addresses.any? do |standup_ip_address|
        standup_ip_address.include?(ip_address)
      end
    end
  end

  private

  attr_accessor :standups
end
