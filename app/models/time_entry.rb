class TimeEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :task
  has_many :statement_time_entries
  has_many :statements, through: :statement_time_entries
  belongs_to :location

  validates :user, presence: true
  validates :project, presence: true
  validates :task, presence: true
  validates :entry_date, presence: true
  validates :duration_in_hours, presence: true

  validate :statement_editable?
  # Before save prevents user selecting holiday / secondary rate task + changing it afterwards.
  # Before create prevents user from updating old entries when they have a new rate, therefore updating it.

  scope :between, -> (from, to) { where('time_entries.entry_date BETWEEN ? AND ?', from.beginning_of_day, to.end_of_day) }

  def as_json(options)
    {
      id: id,
      user: user.as_json(options),
      project: project.as_json(options),
      task: task.as_json(options),
      date: entry_date,
      duration_in_hours: duration_in_hours,
      comments: comments
    }
  end

  class << self
    def query(from, to, user_ids = nil, project_ids = nil, task_ids = nil)
      result = TimeEntry.where("time_entries.entry_date >= ? AND time_entries.entry_date <= ?", from, to)

      if user_ids.present?
        result = result.where(user_id: user_ids)
      end

      if project_ids.present?
        result = result.where(project_id: project_ids)
      end

      if task_ids.present?
        result = result.where(task_id: task_ids)
      end

      result.order(entry_date: :desc)
    end

    def with_no_statement
      statement_ids = Statement.not_in_state(:void).pluck(:id)
      # Select all time entries that are not associated either voided statements / no statement
      joins('
        LEFT OUTER JOIN statement_time_entries on statement_time_entries.time_entry_id = time_entries.id
        LEFT OUTER JOIN statements on statements.id = statement_time_entries.statement_id')
        .group('time_entries.id')
        .having('COUNT(statements.id NOT IN (?) ) = 0', statement_ids)
    end
  end

  private

  def statement_editable?
    if statements.in_state(:locked).present?
      errors.add(:statement, 'is locked.')
    end
  end
end
