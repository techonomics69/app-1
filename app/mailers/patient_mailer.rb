class PatientMailer < ActionMailer::Base

  layout 'email'

  def appointment_soon_email(patient_email, patient_name, start_time, end_time, practice_name, practice_locale, practice_timezone, doctor_name, practice_email)
    
    @patient_name = patient_name
    @start_time = start_time
    @end_time = end_time
    @practice_name = practice_name
    @practice_timezone = practice_timezone
    @doctor_name = doctor_name
    
    # temporarely set the locale and then change it back
    # when the block finishes
    I18n.with_locale(practice_locale) do
      mail(:from => "#{practice_name} <hello@odonto.me>", 
           :to => patient_email, 
           :subject => I18n.t("mailers.patient.appointment_soon_email.subject", practice_name: practice_name), 
           :reply_to => practice_email)
    end
  end

  def appointment_scheduled_email(patient_email, patient_name, start_time, end_time, practice_name, practice_locale, practice_timezone, doctor_name, practice_email, passbook_url)
    
    @patient_name = patient_name
    @start_time = start_time
    @end_time = end_time
    @practice_name = practice_name
    @practice_timezone = practice_timezone
    @doctor_name = doctor_name
    @passbook_url = passbook_url
    
    # temporarely set the locale and then change it back
    # when the block finishes
    I18n.with_locale(practice_locale) do
      mail(:from => "#{practice_name} <hello@odonto.me>", 
           :to => patient_email, 
           :subject => I18n.t("mailers.patient.appointment_scheduled_email.subject", practice_name: practice_name), 
           :reply_to => practice_email)
    end
  end

end
