Spree::CheckoutController.class_eval do
  def update
    if @order.update_attributes(object_params)

      fire_event('spree.checkout.update')
      # storing token in session to be able to use it when 
      # order is being completed
      if params[:paymillToken].present?
        @order.payment.response_code = params[:paymillToken]
        @order.payment.save!
      end
      render :edit and return unless apply_coupon_code

      if @order.next
        state_callback(:after)
      else
        flash[:error] = t(:payment_processing_failed)
        redirect_to checkout_state_path(@order.state)
        return
      end

      if @order.state == 'complete' || @order.completed?
        flash.notice = t(:order_processed_successfully)
        flash[:commerce_tracking] = 'nothing special'
        redirect_to completion_route
      else
        redirect_to checkout_state_path(@order.state)
      end
    else
      render :edit
    end
  end
end