FactoryGirl.define do
  factory :rate do
    rate 30
    association :user, factory: :user
    association :task, factory: :task
    association :project, factory: :project
    note ""

    factory :rate_at_zero do
      rate 0
    end
  end
end
