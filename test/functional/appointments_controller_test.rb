# frozen_string_literal: true

require 'test_helper'

class AppointmentsControllerTest < ActionController::TestCase
  setup do
    @controller.session['user'] = users(:founder)
  end

  test 'should get index' do
    get :index, params: { datebook_id: 1 }, format: :json
    assert_response :success
    assert_not_nil assigns(:appointments)
  end

  test 'should get new' do
    get :new, params: { datebook_id: 1 }
    assert_response :success
  end

  test 'should create an appointment with an existing patient' do
    appointment = {
      doctor_id: 1,
      starts_at: '2014-01-04 14:00:00 +0000',
      ends_at: '2014-01-04 15:00:00 +0000'
    }

    assert_difference 'Appointment.count' do
      post :create, params: { appointment: appointment, datebook_id: 1, as_values_patient_id: '4,' }, format: :js
      # see Patient.find_or_create_from to understand the 'as_values_patient_id' property
    end
  end

  test 'should create an appointment with a new patient' do
    appointment = {
      doctor_id: 2,
      starts_at: '2014-01-04 14:00:00 +0000',
      ends_at: '2014-01-04 15:00:00 +0000'
    }

    assert_difference ['Patient.count', 'Appointment.count'] do
      post :create, params: { appointment: appointment, datebook_id: 1, as_values_patient_id: 'New patient' },
                    format: :js
      # see Patient.find_or_create_from to understand the 'as_values_patient_id' property
    end
  end

  test 'should update appointments by only changing dates' do
    current_time = Time.now
    new_ends_at = current_time + 60.minutes

    appointment = {
      id: 1,
      datebook_id: 1,
      starts_at: current_time,
      ends_at: new_ends_at
    }

    patch :update, params: { appointment: appointment, datebook_id: appointment[:datebook_id], id: appointment[:id] },
                   format: :js
    updated_appointment = Appointment.find(appointment[:id])

    assert_equal updated_appointment.ends_at.to_time.to_i, new_ends_at.to_time.to_i
  end

  test 'should not create an appointment with in a foreign practice' do
    appointment = {
      doctor_id: 2,
      starts_at: '2014-01-04 14:00:00 +0000',
      ends_at: '2014-01-04 15:00:00 +0000'
    }

    assert_no_difference ['Appointment.count'] do
      post :create, params: { appointment: appointment, datebook_id: 99, as_values_patient_id: 'New patient' },
                    format: :js
      # see Patient.find_or_create_from to understand the 'as_values_patient_id' property
    end
  end
end
