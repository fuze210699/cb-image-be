class Promotion
  include Mongoid::Document
  include Mongoid::Timestamps

  ## Fields
  field :code, type: String
  field :description, type: String
  field :discount_type, type: String  # 'percentage' or 'fixed'
  field :discount_value, type: Float
  field :start_date, type: DateTime
  field :end_date, type: DateTime
  field :max_uses, type: Integer
  field :current_uses, type: Integer, default: 0
  field :active, type: Boolean, default: true
  field :min_purchase_amount, type: Float, default: 0

  ## Associations
  has_many :user_subscriptions
  has_many :user_purchase_histories

  ## Validations
  validates :code, presence: true, uniqueness: true
  validates :discount_type, inclusion: { in: %w[percentage fixed], message: "%{value} is not a valid discount type" }
  validates :discount_value, presence: true, numericality: { greater_than: 0 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date
  validate :percentage_discount_valid

  ## Indexes
  index({ code: 1 }, { unique: true })
  index({ active: 1 })
  index({ start_date: 1, end_date: 1 })

  ## Scopes
  scope :active, -> { where(active: true) }
  scope :valid_now, -> { where(:start_date.lte => Time.current, :end_date.gte => Time.current) }

  ## Methods
  def promotion_valid?
    active && 
    Time.current >= start_date && 
    Time.current <= end_date &&
    (max_uses.nil? || current_uses < max_uses)
  end

  def apply_discount(amount)
    return amount unless promotion_valid?
    return amount if amount < min_purchase_amount

    case discount_type
    when 'percentage'
      amount - (amount * discount_value / 100)
    when 'fixed'
      [amount - discount_value, 0].max
    else
      amount
    end
  end

  def use!
    return false unless promotion_valid?
    
    inc(current_uses: 1)
    true
  end

  def deactivate!
    update(active: false)
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date
    
    if end_date <= start_date
      errors.add(:end_date, "must be after start date")
    end
  end

  def percentage_discount_valid
    return unless discount_type == 'percentage'
    
    if discount_value > 100
      errors.add(:discount_value, "cannot be greater than 100 for percentage discounts")
    end
  end
end
