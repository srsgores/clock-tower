class User < ActiveRecord::Base
  has_secure_password
  has_many :projects
  has_many :time_entries

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :email, presence: true, uniqueness: true, email: true
  
  validates :password_reset_token, uniqueness: true
  validates :password, presence: true, if: :validate_password?
  validates :password_confirmation, presence: true, if: :validate_password?

  scope :hourly, -> { where(hourly: true) }

  after_create :send_email_invite

  attr_accessor :creator # virtual attribute

  def fullname
    "#{firstname} #{lastname}"
  end

  def rate_for(task, holiday = false)
    return nil unless hourly?
    if secondary_rate? && task.apply_secondary_rate?
      rate = self.secondary_rate
    else
      rate = self.rate
    end
    holiday ? rate.to_f * holiday_rate_multiplier : rate.to_f
  end

  def as_json(options)
    {
      id: id,
      firstname: firstname,
      lastname: lastname,
      fullname: fullname,
      email: email
    }
  end

  private 

  def validate_password?
    password || password_confirmation
  end

  def send_email_invite
    UserMailer.user_invite(self, creator).deliver
  end

end
