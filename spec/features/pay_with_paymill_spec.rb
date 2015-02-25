require 'spec_helper'

describe 'Pay an order with Paymill' do
  before(:each) do
    if ENV['TEST_PAYMILL_PUBLIC_KEY'].blank? || ENV['TEST_PAYMILL_PRIVATE_KEY'].blank?
      pending
      raise 'Public and private Key for Paymill needed'
    end
    paymill_payment_method = Spree::Gateway::PaymillCreditCard.create!(
      name: 'Creditcard',
      environment: 'test',
      preferences: {
        public_key: ENV['TEST_PAYMILL_PUBLIC_KEY'],
        private_key: ENV['TEST_PAYMILL_PRIVATE_KEY']
      }
    )

    order = OrderWalkthrough.up_to(:delivery)
    allow(order).to receive_messages(confirmation_required?: false)
    allow(order).to receive_messages(available_payment_methods: [ paymill_payment_method ])

    user = create(:user)
    order.user = user
    order.update!

    allow_any_instance_of(Spree::CheckoutController).to receive_messages(:current_order => order)
    allow_any_instance_of(Spree::CheckoutController).to receive_messages(:try_spree_current_user => user)
  end

  scenario "pay an order with a creditcard", js: true do
    visit spree.checkout_state_path(:payment)
    fill_in 'Card Number', with: '4111111111111111'
    fill_in 'Expiration', with: 2.years.since.strftime('%m / %y')
    fill_in 'Card Code', with: '123'
    click_on 'Save and Continue'
    sleep 5
    expect(page).to have_content 'Your order has been processed successfully'
  end


  scenario "pay an order with a creditcard and enter a wrong card number", js: true do
    visit spree.checkout_state_path(:payment)
    fill_in 'Card Number', with: '2323253232323'
    fill_in 'Expiration', with: 2.years.since.strftime('%m / %y')
    fill_in 'Card Code', with: '123'
    click_on 'Save and Continue'
    sleep 5
    expect(page).to have_content 'Please enter a valid creditcard number'
  end

  scenario "pay an order with a creditcard and enter a wrong expiration date", js: true do
    visit spree.checkout_state_path(:payment)
    fill_in 'Card Number', with: '4111111111111111'
    fill_in 'Expiration', with: ''
    fill_in 'Card Code', with: '123'
    click_on 'Save and Continue'
    sleep 5
    expect(page).to have_content 'The creditcard is expired'
  end
end
