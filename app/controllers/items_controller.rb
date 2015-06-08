require 'jbuilder'

class ItemsController < ApplicationController
  before_filter :load_standup, except: [:create]

  def create
    options = (params[:item] || {}).reverse_merge!({standup_id: params[:standup_id]})
    @standup = Standup.find_by_id(options[:standup_id])
    @url_standup = Standup.find_by_id(params[:standup_id])
    @item = Item.new(options)
    if @item.save
      respond_to do |format|
        format.html {
          flash[:notice] = "#{@item.title} item successfully created"
          redirect_to @item.post ? edit_post_path(@item.post) : standup_path(@url_standup)
        }
        format.json { render :json => @item.to_builder(true) }
      end
    else
      respond_to do |format|
        format.html { render 'items/new' }
        format.json {
          render :status => :bad_request, :json => {
              :status => :error,
              :message => @item.errors.map { |attribute, error| attribute.to_s + ' ' + error.to_s }
            }
        }
      end
    end
  end

  def new
    @standup = Standup.find_by_id(params[:standup_id])
    options = (params[:item] || {}).merge({standup_id: params[:standup_id], post_id: params[:post_id], author: session[:username]})
    @item = @standup.items.build(options)
    render_custom_item_template @item
  end

  def index
    @standup = Standup.find_by_id(params[:standup_id])
    events = Item.events_on_or_after(Date.today, @standup)
    @items = @standup.items.orphans.merge(events)
    respond_to do |format|
      format.html { @items }
      format.json {
        result = Jbuilder.encode do |json|
          json.array! @items do |category, item_list|
            json.set! :category_name, category
            json.items item_list.map { |item| item.to_builder.attributes!.select { |x| x != 'category_name' } }
          end
        end
        render :json => result
      }
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    redirect_to request.referer
  end

  def edit
    @item = Item.find(params[:id])
    render_custom_item_template @item
  end

  def update
    @item = Item.find(params[:id])
    @item.update_attributes(params[:item])
    if @item.save
      respond_to do |format|
        format.html { redirect_to(params[:redirect_to] || @standup) }
        format.json {
          render :json => {
            :status => :ok,
            :message => 'Successfully updated item'
          }.to_json
        }
      end
    else
      respond_to do |format|
        format.html { render_custom_item_template @item }
        format.json {
          render :status => :bad_request, :json => {
            :status => :error,
            :message => @standup.errors.map { |attribute, error| attribute.to_s + ' ' + error.to_s }
          }
        }
      end
    end
  end

  def presentation
    events = Item.events_on_or_after(Date.today, @standup)
    @items = @standup.items.orphans.merge(events)
    render layout: 'deck'
  end

  private

  def render_custom_item_template(item)
    if item.possible_template_name && template_exists?(item.possible_template_name)
      render item.possible_template_name
    else
      render "items/new"
    end
  end

  def load_standup
    if params[:standup_id].present?
      standup = Standup.find(params[:standup_id])
    else
      standup = Item.find(params[:id]).standup
    end

    @standup = StandupPresenter.new(standup)
  end
end
