module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :check_admin

    private

    def check_admin
      unless current_user&.admin?
        redirect_to root_path, alert: 'Access denied. Admin privileges required.'
      end
    end
  end
end
