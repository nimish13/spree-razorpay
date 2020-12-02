module Spree
  class Gateway::RazorpayGateway < Gateway
    preference :key_id, :string
    preference :key_secret, :string
    preference :merchant_name, :string
    preference :merchant_description, :text
    preference :merchant_address, :string
    preference :theme_color, :string, default: '#F37254'

    def supports?(source)
      true
    end

    def provider_class
      self.class
    end

    def provider
      self.class
    end

    def auto_capture?
      true
    end

    def method_type
      'razorpay'
    end

    def credit(amount_in_cents, response_code, options)
      begin
        payment_method = Spree::PaymentMethod.find_by(type: 'Spree::Gateway::RazorpayGateway')
        Razorpay.setup(payment_method.preferences[:key_id], payment_method.preferences[:key_secret])
        razorpay_response = Razorpay::Payment.fetch(response_code).refund({amount: amount_in_cents})
      rescue => e
        return ActiveMerchant::Billing::Response.new(false, e.message)
      end

      if(razorpay_response.status === 'processed')
        ActiveMerchant::Billing::Response.new(true, 'Refund success')
      else
        ActiveMerchant::Billing::Response.new(false, 'Refund failed')
      end
    end

    def void(response_code, _credit_card, _options = {})
      begin
        payment_method = Spree::PaymentMethod.find_by(type: 'Spree::Gateway::RazorpayGateway')
        Razorpay.setup(payment_method.preferences[:key_id], payment_method.preferences[:key_secret])
        razorpay_response = Razorpay::Refund.create(payment_id: response_code)
      rescue => e
        return ActiveMerchant::Billing::Response.new(false, e.message)
      end

      if(razorpay_response.status === 'processed')
        ActiveMerchant::Billing::Response.new(true, 'Refund success')
      else
        ActiveMerchant::Billing::Response.new(false, 'Refund failed')
      end
    end

    def cancel(response_code)
      begin
        payment_method = Spree::PaymentMethod.find_by(type: 'Spree::Gateway::RazorpayGateway')
        Razorpay.setup(payment_method.preferences[:key_id], payment_method.preferences[:key_secret])
        razorpay_response = Razorpay::Refund.create(payment_id: response_code)
      rescue => e
        return ActiveMerchant::Billing::Response.new(false, e.message)
      end

      if(razorpay_response.status === 'processed')
        ActiveMerchant::Billing::Response.new(true, 'Refund success')
      else
        ActiveMerchant::Billing::Response.new(false, 'Refund failed')
      end
    end

    def purchase(amount, transaction_details, gateway_options={})
      ActiveMerchant::Billing::Response.new(true, 'razorpay success')
    end

    def request_type
      'DEFAULT'
    end
  end
end
