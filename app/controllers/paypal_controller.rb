class PaypalController < ApplicationController

  protect_from_forgery :except => [:paypal_ipn, :cancel, :success]

  # This will be called when soemone first subscribes
  # When received we make sure the practice is "active"
  def sign_up_user(practice_id, plan_id)
    practice = Practice.find_by_id(practice_id.to_i)
     unless practice.nil?
       practice.set_plan_id_and_number_of_patients = plan_id
       practice.save!
       logger.info("sign_up_user: Practice #{practice_id} to Plan #{plan_id}")
     else
       logger.error("sign_up_user: Practice #{practice_id} on IPN not found")
     end
  end

  # This will be called if someone cancels a plan
  # Or when we cancel it on Paypal administration
  def cancel_subscription(practice_id, plan_id)
    practice = Practice.find_by_id(practice_id.to_i)
     unless practice.nil?
       practice.status = "expiring"
       practice.save!
       logger.info("cancel_subscription: Practice #{practice_id} to plan #{plan_id}")
     else
       logger.error("cancel_subscription: Practice #{practice_id} on IPN not found")
     end
  end

  # subscr_eot
  # This will be called if a subscription expires (ours don't),
  # at the end of the cycle when Cancelled
  # or when billing attempts failed 3 times
  def subscription_expired(practice_id, plan_id)
    practice = Practice.find_by_id(practice_id.to_i)
     unless practice.nil?
       practice.set_as_cancelled
       practice.save!
       logger.info("subscription_expired: Practice #{practice_id} in plan #{plan_id}")
     else
       logger.error("subscription_expired: Practice #{practice_id} on IPN not found")
     end
  end

  # Called if a subscription fails
  def subscription_failed(practice_id, plan_id)
    practice = Practice.find_by_id(practice_id.to_i)
     unless practice.nil?
       practice.status = "payment_due"
       practice.save!
       logger.info("subscription_failed: Practice #{practice_id} in plan #{plan_id}")
     else
       logger.error("subscription_failed: Practice #{practice_id} on IPN not found")
     end
  end

  # Called each time paypal collects a payment
  def subscription_payment(practice_id, plan_id)
    practice = Practice.find_by_id(practice_id.to_i)
     unless practice.nil?
       practice.status = "active"
       practice.save!
       logger.info("subscription_payment: Practice #{practice_id} to plan #{plan_id}")
     else
       logger.error("subscription_payment: Practice #{practice_id} on IPN not found")
     end
  end

  # process the PayPal IPN POST
  def paypal_ipn

    # use the POSTed information to create a call back URL to PayPal
    query = 'cmd=_notify-validate'
    request.params.each_pair {|key, value| query = query + '&' + key + '=' + 
      value if key != 'register/pay_pal_ipn.html/pay_pal_ipn' }

    #paypal_url = 'www.paypal.com'
    #if ENV['RAILS_ENV'] == 'development'
      paypal_url = 'www.sandbox.paypal.com'
    #end

    # Verify all this with paypal
    http = Net::HTTP.start(paypal_url, 80)
    response = http.post('/cgi-bin/webscr', query)
    http.finish
    
    item_name = params[:item_name]
    item_number = params[:item_number]
    payment_status = params[:payment_status]
    txn_type = params[:txn_type]
    practice_id = params[:custom]

    # Paypal confirms so lets process.
    if response && response.body.chomp == 'VERIFIED' 

      if txn_type == 'subscr_signup'
        sign_up_user(practice_id, item_number)
      elsif txn_type == 'subscr_cancel'
        cancel_subscription(practice_id, item_number)
      elsif txn_type == 'subscr_eot'
        subscription_expired(practice_id, item_number)
      elsif txn_type == 'subscr_failed'
        subscription_failed(practice_id, item_number)
      elsif txn_type == 'subscr_payment' && payment_status == 'Completed'
        subscription_payment(practice_id, item_number)
      end

      render :text => 'OK'

    else
      render :text => 'ERROR'
    end
  end

  def cancel
    flash[:notice] = _("Your subscription process has been cancelled and your Paypal account won't be charged.")
    redirect_to practice_settings_url
  end

  def success
    if current_user.practice.status == "active"
      flash[:notice] = _("Your subscription is now active! Thanks for subscribing to Odonto.me")
    else
      flash[:notice] = _("Your subscription is now being processed. We'll send you an email when payment confirmation is received. Or refresh this page to check!")
    end
      redirect_to practice_settings_url
  end

end