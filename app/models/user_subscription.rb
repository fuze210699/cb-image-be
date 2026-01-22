class UserSubscription
  include Mongoid::Document
  include Mongoid::Timestamps

  ## Fields
  field :subscription_type, type: String  # e.g., 'monthly', 'yearly'
  field :start_date, type: DateTime
  field :end_date, type: DateTime
  field :status, type: String, default: 'active'  # active, expired, cancelled
  field :auto_renew, type: Boolean, default: true
  field :price, type: Float

  ## Associations
  belongs_to :user
  belongs_to :promotion, optional: true

  ## Validations
  validates :subscription_type, presence: true, inclusion: { in: %w[monthly yearly], message: "%{value} is not a valid subscription type" }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :status, inclusion: { in: %w[active expired cancelled], message: "%{value} is not a valid status" }
  validate :end_date_after_start_date

  ## Indexes
  index({ user_id: 1 })
  index({ status: 1 })
  index({ end_date: 1 })

  ## Methods
  def active?
    status == 'active' && end_date > Time.current
  end

  def expired?
    end_date <= Time.current
  end

  def days_remaining
    return 0 if expired?
    ((end_date.to_time - Time.current) / 1.day).to_i
  end

  def cancel!
    update(status: 'cancelled', auto_renew: false)
  end

  def renew!(duration = subscription_type)
    return unless auto_renew && active?
    
    new_end_date = case duration
                   when 'monthly'
                     end_date + 1.month
                   when 'yearly'
                     end_date + 1.year
                   else
                     end_date
                   end
    
    update(end_date: new_end_date)
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date
    
    if end_date <= start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end
