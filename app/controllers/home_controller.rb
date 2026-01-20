class HomeController < ApplicationController
  def index
    @promotions = Promotion.active.valid_now.limit(5)
  end
end
