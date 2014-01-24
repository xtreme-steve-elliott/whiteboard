class StandupsController < ApplicationController
  def create
    @standup = standup_service.create(attributes: params[:standup])

    if @standup.persisted?
      flash[:notice] = "#{@standup.title} Standup successfully created"
      redirect_to @standup
    else
      render 'standups/new'
    end
  end

  def new
    @standup = Standup.new(params[:standup])
  end

  def index
    if session[:logged_in]
      @standups = Standup.all
    else
      mapper = IpToStandupMapper.new
      @standups = mapper.standups_matching_ip_address(ip_address: request.remote_ip)
    end
  end

  def edit
    @standup = Standup.find(params[:id])
  end

  def show
    @standup = Standup.find(params[:id])
    redirect_to standup_items_path(@standup)
  end

  def update
    @standup = standup_service.update(id: params[:id], attributes: params[:standup])

    if @standup.changed?
      render 'standups/edit'
    else
      redirect_to @standup
    end
  end

  def destroy
    @standup = Standup.find(params[:id])
    @standup.destroy
    redirect_to standups_path
  end

  private

  def standup_service
    @standup_service ||= StandupService.new()
  end
end
