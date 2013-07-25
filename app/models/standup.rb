require "ipaddr"

class Standup < ActiveRecord::Base
  attr_accessible :title, :to_address, :subject_prefix, :closing_message, :time_zone_name, :ip_addresses_string, :start_time_string

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

  def ip_addresses
    (ip_addresses_string || "").split(/\s|,/).map(&:strip).select(&:present?).map do |string|
      IPAddr.new(string)
    end
  end

  private

  def time_zone
    ActiveSupport::TimeZone.new(time_zone_name)
  end
end
