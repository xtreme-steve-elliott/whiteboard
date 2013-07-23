class Standup < ActiveRecord::Base
  attr_accessible :title, :to_address, :subject_prefix, :ip_key, :closing_message, :time_zone_name

  has_many :items, dependent: :destroy
  has_many :posts, dependent: :destroy

  validates :title, presence: true
  validates :to_address, presence: true

  def date_today
    time_zone.now.to_date
  end

  def date_tomorrow
    date_today + 1.day
  end

  private

  def time_zone
    ActiveSupport::TimeZone.new(time_zone_name)
  end
end
