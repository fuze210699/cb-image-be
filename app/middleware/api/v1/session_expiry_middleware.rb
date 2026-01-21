module Api
  module V1
    class SessionExpiryMiddleware
      def initialize(app)
        @app = app
      end

      def call(env)
        request = ActionDispatch::Request.new(env)
        
        # Check if session has expired
        if request.session[:expires_at]
          expires_at = Time.parse(request.session[:expires_at])
          if Time.now > expires_at
            # Clear expired session
            request.session.clear
          end
        end
        
        @app.call(env)
      end
    end
  end
end
