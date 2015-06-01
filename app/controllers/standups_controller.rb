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

  def fetch_all
    @standups = Standup.all
    render :json => @standups.to_json(:only => [:id, :title, :created_at, :updated_at, :time_zone_name, :start_time_string])
  end

  def edit
    @standup = Standup.find(params[:id])
  end

  def show
    @standup = Standup.find(params[:id])
    redirect_to standup_items_path(@standup)
  end

  def fetch_items
    @standup = Standup.find(params[:id])
    events = Item.events_on_or_after(Date.today, @standup)
    @categoried_items = @standup.items.orphans.merge(events)
    item_list = []
    @categoried_items.each do |item_name, item_value|
      item_json = {
          :category_name => item_name,
          :items => item_value.map do |entry|
            {
                :id => entry.id,
                :title => entry.title,
                :description => entry.description,
                :public => entry.public,
                :bumped => entry.bumped,
                :created_at => entry.created_at,
                :updated_at => entry.updated_at,
                :date => entry.date,
                :author => entry.author
            }
          end
      }
      item_list.append item_json
    end
    render :json => item_list
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
