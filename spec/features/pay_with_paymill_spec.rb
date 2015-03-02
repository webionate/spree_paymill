require 'spec_helper'

describe 'Pay an order with Paymill' do
  context 'with paymill keys' do
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
      fill_in 'Name on card', with: 'Hans Wurst'
      fill_in 'Card Number', with: '4111111111111111'
      fill_in 'Expiration', with: 2.years.since.strftime('%m / %y')
      fill_in 'Card Code', with: '123'
      click_on 'Save and Continue'
      sleep 5
      expect(page).to have_content 'Your order has been processed successfully'
    end


    scenario "pay an order with a creditcard and enter a wrong card data", js: true do
      visit spree.checkout_state_path(:payment)
      fill_in 'Name on card', with: 'D'
      fill_in 'Card Number', with: '2323253232323'
      fill_in 'Expiration', with: '12/11'
      fill_in 'Card Code', with: 'ABD'

      click_on 'Save and Continue'
      wait_for_ajax

      expect(page).to have_content 'Please enter a valid cardholder'
      expect(page).to have_content 'Please enter a valid creditcard number'
      expect(page).to have_content 'Please enter a valid expiry date'
      expect(page).to have_content 'Please enter a valid CVC number'

      fill_in 'Card Number', with: '4111111111111111'
      click_on 'Save and Continue'
      wait_for_ajax

      expect(page).to_not have_content 'Please enter a valid creditcard number'
    end

    scenario "pay an order with invalid creditcard", js: true do
      visit spree.checkout_state_path(:payment)
      fill_in 'Name on card', with: 'Hans Wurst'
      fill_in 'Card Number', with: '5105105105105100'
      fill_in 'Expiration', with: '10/20'
      fill_in 'Card Code', with: '123'
      click_on 'Save and Continue'
      sleep 5
      expect(page).to have_content 'Card invalid'
    end
  end

  scenario "a paymill bridge error occured while paying an order with a creditcard ", js: true do
    page.driver.browser.js_errors = false
    paymill_payment_method = Spree::Gateway::PaymillCreditCard.create!(
      name: 'Creditcard',
      environment: 'test',
      preferences: {
        public_key: '',
        private_key: ''
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

    visit spree.checkout_state_path(:payment)
    fill_in 'Name on card', with: 'Hans Wurst'
    fill_in 'Card Number', with: '4111111111111111'
    fill_in 'Expiration', with: 2.years.since.strftime('%m / %y')
    fill_in 'Card Code', with: '123'
    click_on 'Save and Continue'
    sleep 1
    expect(page).to have_content('An error occured while processing your payment data')
  end


end
