class PatientCommunication < ActiveRecord::Base
  # permitted attributes
  attr_accessible :user_id, :subject, :message, :number_of_patients
end
