module Admin
  class PromotionsController < BaseController
    def index
      @promotions = Promotion.order_by(created_at: :desc).page(params[:page]).per(20)
    end

    def new
      @promotion = Promotion.new
    end

    def create
      @promotion = Promotion.new(promotion_params)
      
      if @promotion.save
        redirect_to admin_promotions_path, notice: 'Promotion created successfully.'
      else
        render :new
      end
    end

    def edit
      @promotion = Promotion.find(params[:id])
    end

    def update
      @promotion = Promotion.find(params[:id])
      
      if @promotion.update(promotion_params)
        redirect_to admin_promotions_path, notice: 'Promotion updated successfully.'
      else
        render :edit
      end
    end

    def destroy
      @promotion = Promotion.find(params[:id])
      @promotion.destroy
      redirect_to admin_promotions_path, notice: 'Promotion deleted successfully.'
    end

    def toggle_active
      @promotion = Promotion.find(params[:id])
      @promotion.update(active: !@promotion.active)
      redirect_to admin_promotions_path, notice: 'Promotion status updated.'
    end

    private

    def promotion_params
      params.require(:promotion).permit(
        :code, :description, :discount_type, :discount_value,
        :start_date, :end_date, :max_uses, :active, :min_purchase_amount
      )
    end
  end
end
