class StandupService
  def initialize(user_ip_address: nil)
    self.user_ip_address = user_ip_address
  end

  def create(attributes: {})
    standup = Standup.new(attributes)

    validate_ip_addresses(standup)

    standup.tap(&:save)
  end


  def update(id: nil, attributes: {})
    standup = Standup.find(id)
    standup.attributes = attributes

    validate_ip_addresses(standup)

    standup.tap(&:save)
  end

  private

  attr_accessor :user_ip_address

  def validate_ip_addresses(standup)
    standup.ip_addresses_string ||= ""
    mapper = IpToStandupMapper.new(standups: [standup])
    user_ip_is_included = mapper.includes?(ip_address: user_ip_address)

    standup.ip_addresses_string += "\r\n#{user_ip_address}" unless user_ip_is_included
  end
end
