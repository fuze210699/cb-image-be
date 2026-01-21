module Api
  module V1
    class SessionsController < BaseController
      before_action :authenticate_user!, only: [:destroy, :me, :ping]

      # GET /api/v1/ping
      # Check if session is still valid
      def ping
        render_success({
          valid: true,
          user: {
            id: current_user.id.to_s,
            email: current_user.email,
            role: current_user.role
          },
          expires_at: session[:expires_at]
        }, 'Session is valid')
      end

      # POST /api/v1/login
      def create
        email = params[:email] || params.dig(:session, :email)
        password = params[:password] || params.dig(:session, :password)

        unless email && password
          return render_error('Email and password are required', :bad_request)
        end

        user = User.where(email: email).first

        if user&.valid_password?(password)
          # Set user_id in session for authentication
          session[:user_id] = user.id.to_s
          # Set session expiry to 24 hours
          session[:expires_at] = 24.hours.from_now.iso8601
          render_success(user_response(user), 'Logged in successfully')
        else
          render_error('Invalid email or password', :unauthorized)
        end
      rescue => e
        Rails.logger.error("Login error: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        render_error("Login failed: #{e.message}", :internal_server_error)
      end

      # DELETE /api/v1/logout
      def destroy
        session[:user_id] = nil
        session[:expires_at] = nil
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
