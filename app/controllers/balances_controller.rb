class BalancesController < ApplicationController  
  before_filter :require_user
  
  # provides
  respond_to :html, :js, :csv
  
  def index
    @patient = Patient.mine.find(params[:patient_id])
    @balances = Balance.where("patient_id = ?", @patient.id)
    @total = Balance.where("patient_id = ?", params[:patient_id]).sum(:amount)
    
    respond_to do |format|
      format.html { render :layout => nil }
      format.csv { 
            headers["Content-Type"] = "text/csv"
            headers["Content-disposition"] = "attachment; filename=#{@patient.fullname}.csv"
      } 
    end
  end

  def create
    @balance = Balance.new(params[:balance])
    @balance.patient_id = params[:patient_id] #FIXME yeah this sucks
    
    respond_to do |format|
      if @balance.save
          @total = Balance.where("patient_id = ?", params[:patient_id]).sum(:amount)
          format.js  { } #create.js.erb
      else
          format.js  {
            render_ujs_error(@balance, _("There was an error creating this entry"))
          }
      end
    end
  end

end
