FactoryGirl.define do
  factory :rate do
    rate 30
    association :user, factory: :user
    association :task, factory: :task
    association :project, factory: :project
  end
end
