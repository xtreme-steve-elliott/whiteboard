FactoryGirl.define do
  factory :item do
    title "Focused specs are broken"
    kind "Help"

    association :standup
  end
end
