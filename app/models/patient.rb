class Patient < ActiveRecord::Base
  has_many :appointments
  #has_one :chart
  belongs_to :practice

  scope :mine, lambda { 
    where("patients.practice_id = ? ", UserSession.find.user.practice_id)
  }  

  validates :uid, :uniqueness => {:scope => :practice_id}
  validates_presence_of :practice_id, :firstname, :lastname, :date_of_birth
  validates_length_of :uid, :within => 0..25, :allow_blank => true
  validates_length_of :firstname, :within => 1..25
  validates_length_of :lastname, :within => 1..25
  validates_length_of :address, :within => 0..100, :allow_blank => true
  validates_length_of :telephone, :within => 0..20, :allow_blank => true
  validates_length_of :mobile, :within => 0..20, :allow_blank => true
  validates_length_of :emergency_telephone, :within => 0..20, :allow_blank => true
  validates_format_of :email, :with => Authlogic::Regex.email

  before_validation(:on => :create) do
    set_practice_id
  end

  #after_create :setup_chart
  

  def fullname
    [firstname, lastname].join(' ')
  end

  def age
    (Time.now.year - date_of_birth.year) - (Time.now.yday < date_of_birth.yday ? 1 : 0)
  end
  
  def setup_chart
    chart = Chart.create!(:user_id => self.id)
  end

end
