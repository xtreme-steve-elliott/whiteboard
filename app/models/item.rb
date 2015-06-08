class Item < ActiveRecord::Base
  KIND_NEW_FACE = 'New face'
  KIND_HELP = 'Help'
  KIND_INTERESTING = 'Interesting'
  KIND_EVENT = 'Event'
  KIND_WIN = 'Win'
  KINDS = [{name: KIND_NEW_FACE, subtitle: ''},
    {name: KIND_HELP, subtitle: ''},
    {name: KIND_INTERESTING, subtitle: 'News, Articles, Tools, Best Practices, etc'},
    {name: KIND_EVENT, subtitle: ''},
    {name: KIND_WIN, subtitle: 'Use this to announce achievements in line with company goals. Eg. signed client X, incepted project Y, released product Z...'}
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
    where(post_id: nil).where.not(kind: KIND_EVENT).where("date >= ? OR kind = '#{KIND_HELP}' OR kind = '#{KIND_INTERESTING}'", Date.today).order("date ASC").group_by(&:kind)
  end

  def self.events_on_or_after(date, standup)
    where(kind: KIND_EVENT).
      where("standup_id = #{standup.id} OR standup_id IS NULL").
      where("date >= ?", date).
      where(post_id: nil).
      order("date").
      group_by(&:kind)
  end

  def self.for_post(standup)
    where(post_id: nil, bumped: false).
      where("standup_id = #{standup.id} OR standup_id IS NULL").
      where("(kind != '#{KIND_EVENT}' OR date = ?)", Date.today).
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
      kinds.delete_if {|kind| kind.name == KIND_WIN}
    end
    kinds
  end

  private
  def face_is_in_the_future
    if kind == KIND_NEW_FACE && (date || Time.at(0)).to_time < Time.now.beginning_of_day
      errors.add(:date, 'must be in the present or future')
    end
  end
end
