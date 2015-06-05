class StandupsController < ApplicationController
  def create
    @standup = standup_service.create(attributes: params[:standup])

    if @standup.persisted?
      respond_to do |format|
        format.html {
          flash[:notice] = "#{@standup.title} Standup successfully created"
          redirect_to @standup
        }
        format.json { render :json => @standup.to_builder(true) }
      end
    else
      respond_to do |format|
        format.html { render 'standups/new' }
        format.json {
          render :status => :bad_request, :json => {
              :status => :error,
              :message => @standup.errors.map { |attribute, error| attribute.to_s + ' ' + error.to_s }
          }
        }
      end
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
    @standups.sort_by { |x| x.id }
    respond_to do |format|
      format.html
      format.json {
        result = Jbuilder.encode do |json|
          # We have to actually map the attributes to produce items when doing collections
          json.array! @standups.map { |standup| standup.to_builder.attributes! }
        end
        render :json => result
      }
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
      respond_to do |format|
        format.html { render 'standups/edit' }
        format.json {
          render :status => :bad_request, :json => {
            :status => :error,
            :message => @standup.errors.map { |attribute, error| attribute.to_s + ' ' + error.to_s }
          }
        }
      end
    else
      respond_to do |format|
        format.html {
          flash[:notice] = "#{@standup.title} Standup successfully updated"
          redirect_to @standup
        }
        format.json { render :json => @standup.to_builder(true) }
      end
    end
  end

  def destroy
    @standup = standup_service.delete(id: params[:id])
    if @standup.destroyed?
      respond_to do |format|
        format.html { redirect_to standups_path }
        format.json {
          render :json => {
            :status => :ok,
            :message => 'Successfully deleted standup'
          }
        }
      end
    else # TODO: figure out how to get a deletion failure
      respond_to do |format|
        format.html { render @standup }
        format.json {
          render :status => :bad_request, :json => {
            :status => :error,
            :message => @standup.errors.map { |attribute, error| attribute.to_s + ' ' + error.to_s }
          }
        }
      end
    end
  end

  private

  def standup_service
    @standup_service ||= StandupService.new()
  end
end
