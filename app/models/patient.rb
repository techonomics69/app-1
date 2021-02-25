# frozen_string_literal: true

class Patient < ApplicationRecord
  # associations
  has_many :appointments, dependent: :delete_all
  has_many :balances, dependent: :delete_all
  has_many :notes, as: :noteable, dependent: :delete_all
  has_many :doctors, through: :appointments
  belongs_to :practice, counter_cache: true

  scope :with_practice, lambda { |practice_id|
    where('patients.practice_id = ? ', practice_id)
      .order('firstname')
  }

  scope :alphabetically, lambda { |letter|
    select('firstname,lastname,uid,id,date_of_birth,allergies,email,updated_at')
      .where('lower(firstname) LIKE ?', "#{letter.downcase}%")
  }

  scope :search, lambda { |q|
    select('id,uid,firstname,lastname,email,updated_at,date_of_birth')
      .where("uid LIKE ? OR lower(firstname || ' ' || lastname) LIKE ?", q, "%#{q.downcase}%")
      .limit(25)
      .order('firstname')
  }

  # validations
  validates_uniqueness_of :uid, scope: :practice_id, allow_nil: true, allow_blank: true
  validates_uniqueness_of :email, scope: :practice_id, allow_nil: true, allow_blank: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, allow_nil: true,
                    allow_blank: true
  validates_presence_of :practice_id, :firstname, :lastname, :date_of_birth

  validates_numericality_of :cigarettes_per_day, :drinks_per_day, only_integer: true,
                                                                  greater_than_or_equal_to: 0, allow_blank: true
  validates_length_of :uid, within: 0..25, allow_blank: true
  validates_length_of :firstname, within: 1..25
  validates_length_of :lastname, within: 1..25
  validates_length_of :address, within: 0..100, allow_blank: true
  validates_length_of :telephone, within: 0..20, allow_blank: true
  validates_length_of :mobile, within: 0..20, allow_blank: true
  validates_length_of :emergency_telephone, within: 5..20, allow_blank: true

  # callbacks
  after_create :destroy_nils

  def fullname
    [firstname, lastname].join(' ')
  end

  def fullname=(name)
    split = name.split(' ', 2)
    self.firstname = split.first
    self.lastname = split.last
  end

  def age
    if !missing_info?
      (Time.now.year - date_of_birth.year) - (Time.now.yday < date_of_birth.yday ? 1 : 0)
    else
      0
    end
  end

  # this functions checks if the user was created from the datebook (skipped all validation, so most of the data is invalid)
  def missing_info?
    date_of_birth.nil?
  end

  # this function tries to find a patient by an ID or it's NAME, otherwise it creates one
  def self.find_or_create_from(patient_id_or_name, practice_id)
    # remove any possible commas from this value
    patient_id_or_name.gsub!(',', '')

    # Check if we are dealing with an integer or a string
    if patient_id_or_name.to_i.zero?
      # instantiate a new patient
      patient = new
      patient.fullname = patient_id_or_name
      # set the practice_id manually because validation (and callbacks apparently as well) are skipped
      patient.practice_id = practice_id
      # skip validation when saving this patient
      patient.save!(validate: false)

      patient_id_or_name = patient.id
    end

    # validate that this patient really exists
    begin
      patient_double_check = Patient.find patient_id_or_name
    rescue ActiveRecord::RecordNotFound
      patient_id_or_name = nil
    end

    patient_id_or_name
  end

  private

  # this function is a small compromise to bypass that weird situation where a patient is created with everything set to nil
  def destroy_nils
    Patient.where(firstname: nil).destroy_all
    Appointment.where(patient_id: nil).destroy_all
  end

  def patient_params
    params.require(:patient).permit(:uid, :firstname, :lastname, :fullname, :date_of_birth, :past_illnesses, :surgeries, :medications,
                                    :drugs_use, :cigarettes_per_day, :drinks_per_day, :family_diseases, :emergency_telephone, :email, :telephone, :mobile, :address, :allergies, :practice_id)
  end
end
