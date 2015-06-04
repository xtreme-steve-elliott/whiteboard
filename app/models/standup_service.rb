class StandupService
  def create(attributes: {})
    standup = Standup.new(attributes)
    standup.tap(&:save)
  end

  def update(id: nil, attributes: {})
    standup = Standup.find(id)
    standup.attributes = attributes
    standup.tap(&:save)
  end

  def delete(id: nil)
    standup = Standup.find(id)
    standup.tap(&:delete)
  end
end
