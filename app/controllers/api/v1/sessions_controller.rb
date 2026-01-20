module Api
  module V1
    class SessionsController < BaseController
      # Devise helpers
      include Devise::Controllers::Helpers
      
      before_action :authenticate_user!, only: [:destroy, :me]

      # POST /api/v1/login
      def create
        user = User.find_by(email: params[:email])

        if user&.valid_password?(params[:password])
          sign_in(:user, user)
          render_success(user_response(user), 'Logged in successfully')
        else
          render_error('Invalid email or password', :unauthorized)
        end
      end

      # DELETE /api/v1/logout
      def destroy
        signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
        render_success(nil, 'Logged out successfully')
      end

      # GET /api/v1/me
      def me
        render_success(user_response(current_user))
      end

      private

      def resource_name
        :user
      end

      def user_response(user)
        {
          id: user.id.to_s,
          email: user.email,
          role: user.role,
          is_admin: user.admin?,
          is_super_user: user.super_user?,
          has_active_subscription: user.has_active_subscription?,
          subscription: subscription_response(user.user_subscription),
          sign_in_count: user.sign_in_count,
          current_sign_in_at: user.current_sign_in_at,
          last_sign_in_at: user.last_sign_in_at,
          created_at: user.created_at,
          updated_at: user.updated_at
        }
      end

      def subscription_response(subscription)
        return nil unless subscription

        {
          id: subscription.id.to_s,
          subscription_type: subscription.subscription_type,
          start_date: subscription.start_date,
          end_date: subscription.end_date,
          status: subscription.status,
          auto_renew: subscription.auto_renew,
          price: subscription.price,
          days_remaining: subscription.days_remaining,
          is_active: subscription.active?,
          is_expired: subscription.expired?
        }
      end
    end
  end
end
