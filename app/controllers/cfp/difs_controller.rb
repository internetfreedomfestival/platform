class Cfp::DifsController < ApplicationController
  layout 'cfp'

  before_action :authenticate_user!, except: :confirm

  def new
    @dif = Dif.new(status: "pending")
  end

  def create
    authorize! :submit, Dif

    @dif = Dif.new(dif_params.merge( person_id: current_user.person.id, status: "pending"))
    respond_to do |format|
      if travel_support_blank
        flash[:alert] = "You must fill out all the required fields"
        format.html { render action: 'new' }
      elsif @dif.save
        format.html { redirect_to(cfp_person_path, notice: t('cfp.dif_created')) }
      else
        flash[:alert] = "You must fill out all the reuired fields"
        format.html { render action: 'new' }
      end
    end
  end


  def edit
    authorize! :submit, Dif
    @edit = true
    @dif = current_user.person.dif
  end

  def update
    authorize! :submit, Event
    @dif = current_user.person.dif
    respond_to do |format|
      if travel_support_blank
        flash[:alert] = "You must fill out all the required fields!"
        format.html { render action: 'edit' }        
      elsif @dif.update_attributes(dif_params)
        format.html { redirect_to(cfp_person_path, notice: t('cfp.dif_update_notice')) }
      else
        flash[:alert] = "You must fill out all the required fields!"
        format.html { render action: 'edit' }
      end
    end
  end

  private
  def dif_params
    params.require(:dif).permit(
      :past_travel_assistance, :status, :person_id, :willing_to_facilitate, { travel_support: [] }
    )
  end

  def travel_support_blank
    if params["dif"]["travel_support"] === [""]
      return true
    else
      false
    end
  end
end
