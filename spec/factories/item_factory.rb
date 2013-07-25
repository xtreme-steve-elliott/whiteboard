FactoryGirl.define do
  factory :item do
    title "Focused specs are broken"
    kind "Help"

    association :standup
  end

  factory :event, parent: :item do
    kind "Event"
  end
end
