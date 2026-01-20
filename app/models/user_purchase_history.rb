class UserPurchaseHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  ## Fields
  field :purchase_type, type: String  # e.g., 'subscription', 'one_time'
  field :amount, type: Float
  field :currency, type: String, default: 'USD'
  field :payment_method, type: String  # e.g., 'credit_card', 'paypal'
  field :transaction_id, type: String
  field :status, type: String, default: 'completed'  # completed, pending, failed, refunded
  field :description, type: String
  field :purchased_at, type: DateTime, default: -> { Time.current }

  ## Associations
  belongs_to :user
  belongs_to :promotion, optional: true

  ## Validations
  validates :purchase_type, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[completed pending failed refunded], message: "%{value} is not a valid status" }

  ## Indexes
  index({ user_id: 1 })
  index({ purchased_at: -1 })
  index({ status: 1 })
  index({ transaction_id: 1 })

  ## Scopes
  scope :completed, -> { where(status: 'completed') }
  scope :recent, -> { order_by(purchased_at: :desc) }

  ## Methods
  def refund!
    update(status: 'refunded')
  end

  def failed!
    update(status: 'failed')
  end
end
