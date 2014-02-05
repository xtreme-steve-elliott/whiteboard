FactoryGirl.define do
  factory :item do
    title "Focused specs are broken"
    kind "Help"
    date Date.today

    association :standup
  end

  factory :event, parent: :item do
    kind "Event"
  end

  factory :new_face, class: Item do
    title "John"
    kind "New face"
    date Date.today

    association :standup
  end
end
