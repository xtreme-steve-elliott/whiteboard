class Item < ActiveRecord::Base
  KINDS = [{name: 'New face', subtitle: ''},
    {name: 'Help', subtitle: ''},
    {name: 'Interesting', subtitle: 'News, Articles, Tools, Best Practices, etc'},
    {name: 'Event', subtitle: ''},
    {name: 'Win', subtitle: 'Use this to announce achievements in line with company goals. Eg. signed client X, incepted project Y, released product Z...'}
  ]

  default_scope { order('date ASC') }

  belongs_to :post
  belongs_to :standup

  validates_inclusion_of :kind, in: KINDS.map { |k| k[:name] }
  validates :title, presence: true
  validates :standup_id, presence: true
  # validate :standup_present
  validate :face_is_in_the_future

  attr_accessible :title, :description, :kind, :public, :post_id, :date, :standup_id, :author

  def to_builder(should_build = false, fields = nil)
    builder = Jbuilder.new do |json|
      json.set! :category_name, self.kind
      if fields.nil?
        json.(self, :id, :title, :description, :public, :bumped, :created_at, :updated_at, :date, :author)
      else
        json.(self, fields)
      end
    end
    should_build ? builder.target! : builder
  end

  def self.public
    where(public: true)
  end

  def self.orphans
    where(post_id: nil).where.not(kind: 'Event').where("date >= ? OR kind = 'Help' OR kind = 'Interesting'", Date.today).order("date ASC").group_by(&:kind)
  end

  def self.events_on_or_after(date, standup)
    where(kind: "Event").
      where("standup_id = #{standup.id} OR standup_id IS NULL").
      where("date >= ?", date).
      where(post_id: nil).
      order("date").
      group_by(&:kind)
  end

  def self.for_post(standup)
    where(post_id: nil, bumped: false).
      where("standup_id = #{standup.id} OR standup_id IS NULL").
      where("(kind != 'Event' OR date = ?)", Date.today).
      where("date IS NULL OR date <= ?", Date.today)
  end

  def possible_template_name
    kind && "items/new_#{kind.downcase.gsub(" ", '_')}"
  end

  def relative_date
    case date
    when standup.date_today then
      :today
    when standup.date_tomorrow then
      :tomorrow
    else
      :upcoming
    end
  end

  def self.kinds
    kinds = KINDS.map { |kind| Kind.new(kind[:name], kind[:subtitle]) }
    unless ENV['ENABLE_WINS'] == 'true'
      kinds.delete_if {|kind| kind.name == 'Win'}
    end
    kinds
  end

  private
  def face_is_in_the_future
    if kind == 'New face' && (date || Time.at(0)).to_time < Time.now.beginning_of_day
      errors.add(:date, "must be in the present or future")
    end
  end
end
