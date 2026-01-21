module Api
  module V1
    class BaseController < ActionController::API
      include ActionController::Cookies
      
      # Set JSON response format
      respond_to :json

      # Handle exceptions
      rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found
      rescue_from CanCan::AccessDenied, with: :forbidden

      protected

      # Override Devise's authenticate_user! to return JSON instead of redirect
      def authenticate_user!
        unless user_signed_in?
          render json: { 
            success: false, 
            message: 'Not authenticated' 
          }, status: :unauthorized
        end
      end

      # Helper method to get current user from session
      def current_user
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
      rescue Mongoid::Errors::DocumentNotFound
        session[:user_id] = nil
        nil
      end

      def user_signed_in?
        current_user.present?
      end

      private

      def not_found
        render json: { error: 'Resource not found' }, status: :not_found
      end

      def forbidden
        render json: { error: 'Access denied' }, status: :forbidden
      end

      def render_error(message, status = :unprocessable_entity)
        render json: { error: message }, status: status
      end

      def render_success(data, message = nil, status = :ok)
        response = { success: true, data: data }
        response[:message] = message if message
        render json: response, status: status
      end

      def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])
      end
    end
  end
end
