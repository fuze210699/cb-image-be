class User
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Role management
  field :role, type: String, default: 'user'

  ## Associations
  has_one :user_subscription, dependent: :destroy
  has_many :user_purchase_histories, dependent: :destroy

  ## Validations
  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: %w[user admin super_user], message: "%{value} is not a valid role" }

  ## Indexes
  index({ email: 1 }, { unique: true })
  index({ role: 1 })

  ## Methods
  def admin?
    role == 'admin'
  end

  def super_user?
    role == 'super_user'
  end

  def has_active_subscription?
    # Super user always has active subscription
    return true if super_user?
    user_subscription&.active?
  end
end
