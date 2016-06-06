class Rate < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :task

  validates :rate, presence: true, numericality: { greater_than: 0 }
  
end
