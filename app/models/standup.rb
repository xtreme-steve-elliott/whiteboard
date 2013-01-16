class Standup < ActiveRecord::Base
  attr_accessible :title, :to_address, :subject_prefix, :ip_key

  has_many :items, dependent: :destroy
  has_many :posts, dependent: :destroy

  validates :title, presence: true
  validates :to_address, presence: true

  def authorized_domain(domain)
    domain == "pivotallabs.com" || domain == "matthewkocher.com"
  end
end
