# frozen_string_literal: true

require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create user session if valid params are given' do
    post :create, params: { signin: { email: users(:founder).email, password: '1234567890' } }

    assert_equal @controller.session['user'], users(:founder)
    assert_redirected_to root_url
  end

  test 'should request user to reset password if not migrated' do
    non_migrated_user = users(:non_migrated_user)
    post :create, params: { signin: { email: non_migrated_user.email, password: '1234567890' } }

    assert_nil @controller.session['user']
    assert_redirected_to new_password_reset_url
  end

  # FIXME: add support for this
  # test "should block user session if force entering" do
  #   # spam the login form
  #   15.times do
  #     post :create, params: {:signin => { :email => 'raulriera@hotmail.com', :password => '12345' }}
  #   end
  #   # try to enter valid credentials
  #   post :create, params: {:signin => { :email => 'raulriera@hotmail.com', :password => '1234567890' }}

  #   assert_template 'new'
  # end
end
