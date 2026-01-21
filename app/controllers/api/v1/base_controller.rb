module Api
  module V1
    class BaseController < ActionController::API
      include ActionController::Cookies
      
      # Include Devise helpers
      before_action :configure_permitted_parameters, if: :devise_controller?
      
      # Set JSON response format
      respond_to :json

      # Handle exceptions
      rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found
      rescue_from CanCan::AccessDenied, with: :forbidden

      private

      # Override Devise's default redirect behavior for API
      def authenticate_user!
        unless current_user
          render json: { 
            success: false, 
            message: 'Not authenticated' 
          }, status: :unauthorized
          return
        end
      end

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
