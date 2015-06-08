FactoryGirl.define do
  factory :item do
    title 'Test Item'
    kind Item::KIND_HELP
    date Date.today

    association :standup
  end

  factory :help_item, :parent => :item do
    title 'Test Hep'
    kind Item::KIND_HELP
  end

  factory :interesting_item, :parent => :item do
    title 'Test Interesting'
    kind Item::KIND_INTERESTING
  end

  factory :event_item, :parent => :item do
    title 'Test Event'
    kind Item::KIND_EVENT
  end

  factory :new_face_item, :parent => :item do
    title 'Test New Face'
    kind Item::KIND_NEW_FACE
  end
end
