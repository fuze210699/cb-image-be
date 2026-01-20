class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # CanCanCan exception handling
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: exception.message
  end

  # Helper method to check if user has active subscription
  def require_active_subscription
    unless current_user&.has_active_subscription?
      redirect_to new_subscription_path, alert: 'You need an active subscription to access this feature.'
    end
  end
end
