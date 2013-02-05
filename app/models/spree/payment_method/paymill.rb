# encoding: UTF-8
require 'paymill'

module Spree
  class PaymentMethod::Paymill < Spree::PaymentMethod
    preference :private_key, :string
    preference :public_key, :string

    attr_accessible :preferred_private_key, :preferred_public_key

    def payment_source_class
      CreditCard
    end

    def authorize(money, credit_card, options = {})
      init_data
      order = find_order(options)

      client = ::Paymill::Client.create(
        email: "#{options[:email]}"
      )

      unless client.id.nil?
        payment = create_payment(order, client, credit_card, options)

        unless payment.id.nil?
          preauth = create_preauthorization(payment, money)

          unless preauth.id.nil?
            ActiveMerchant::Billing::Response.new(true, 'Paymill creating preauthorization successful', {}, :authorization => preauth.preauthorization["id"])
          else
            ActiveMerchant::Billing::Response.new(false, 'Paymill creating preauthorization unsuccessful')
          end
        else
          ActiveMerchant::Billing::Response.new(false, 'Paymill creating payment unsuccessful')
        end
      else
        ActiveMerchant::Billing::Response.new(false, 'Paymill creating client unsuccessful')
      end
    end

    def capture(authorization, credit_card, options = {})
      init_data
      order = find_order(options)
      transaction = create_transaction(authorization, order)

      unless transaction.id.nil?
        ActiveMerchant::Billing::Response.new(true, 'Paymill creating transaction successful', {}, :authorization => transaction.id)
      else
        ActiveMerchant::Billing::Response.new(false, 'Paymill creating transaction unsuccessful')
      end
    end

  private
    def init_data
      ::Paymill.api_key = preferred_private_key
    end

    def find_order(options = {})
      Spree::Order.find_by_number(options[:order_id])
    end

    def create_transaction(authorization, order)
      ::Paymill::Transaction.create(
        amount: authorization,
        preauthorization: order.payment.response_code,
        currency: "EUR"
      )
    end

    def create_payment(order, client, credit_card, options = {})
      ::Paymill::Payment.create(
        id: "pay_#{options[:order_id]}",
        client: "#{client.id}",
        card_type: credit_card.spree_cc_type,
        token: order.payment.response_code,
        country: nil,
        expire_month: credit_card.month,
        expire_year: credit_card.year,
        card_holder: nil,
        last4: credit_card.display_number[15..18],
        created_at: Time.zone.now,
        updated_at: Time.zone.now
      )
    end

    def create_preauthorization(payment, money)
      ::Paymill::Preauthorization.create(
        payment: payment.id,
        amount: money,
        currency: "EUR"
      )
    end
  end
end
