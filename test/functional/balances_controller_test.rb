require 'test_helper'

class BalancesControllerTest < ActionController::TestCase

  setup do
  	UserSession.create users(:founder)
  end

  test "should get index" do
    get :index, patient_id: 1
    assert_response :success
    assert_not_nil assigns(:treatments)
  end

  test "should create an income entry" do
    entry = {
      :amount => 9.99,
      :notes => 'Can of soda'
    }

    assert_difference 'Balance.count' do
      post :create, { balance: entry, patient_id: 1, format: :js }
    end
  end

  test "should create an expense entry" do
    entry = {
      :amount => -9.99,
      :notes => 'Returned the can of soda'
    }

    assert_difference 'Balance.count' do
      post :create, { balance: entry, patient_id: 1, format: :js }
    end
  end

end
