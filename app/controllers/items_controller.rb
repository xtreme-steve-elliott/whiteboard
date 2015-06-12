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
        format.js {
          if @item.post
            redirect_to edit_post_path(@item.post)
          else
            session[:notice] = "Item \"#{@item.title}\" successfully created"
            render inline: 'location.reload();'
          end
        }
        format.json { render :json => @item.to_builder(true) }
      end
    else
      respond_to do |format|
        format.js { render 'items/edit_or_new' }
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
    options = (params[:item] || {}).merge({post_id: params[:post_id], author: session[:username]}).reverse_merge!({standup_id: params[:standup_id]})
    @item = @standup.items.build(options)
    respond_to do |format|
      format.js { render 'items/edit_or_new' }
      format.html {
        redirect_to standup_items_path(@standup)
        # TODO: see if we can get it to reopen the edit/new panel too
      }
    end
  end

  def index
    @standup = Standup.find_by_id(params[:standup_id])
    events = Item.events_on_or_after(Date.today, @standup)
    @items = @standup.items.orphans.merge(events)
    flash[:notice] = session[:notice]
    session[:notice] = nil
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
    if @item.destroyed?
      respond_to do |format|
        format.js {
          session[:notice] = 'Successfully deleted item'
          render inline: 'location.reload();'
        }
        format.json {
          render :json => {
              :status => :ok,
              :message => 'Successfully deleted item'
            }
        }
      end
    else # TODO: figure out how to get a deletion failure
      respond_to do |format|
        format.js { render 'items/edit_or_new' }
        format.json {
          render :status => :bad_request, :json => {
              :status => :error,
              :message => @item.errors.map { |attribute, error| attribute.to_s + ' ' + error.to_s }
            }
        }
      end
    end
  end

  def edit
    @item = Item.find(params[:id])
    respond_to do |format|
      format.js { render 'items/edit_or_new' }
      format.html {
        redirect_to standup_items_path(@item.standup)
        # TODO: see if we can get it to reopen the edit/new panel too
      }
    end
    # render_custom_item_template @item
  end

  def update
    @item = Item.find(params[:id])
    @item.update_attributes(params[:item])
    if @item.save
      respond_to do |format|
        format.js {
          session[:notice] = 'Successfully updated item'
          render inline: 'location.reload();'
        }
        format.json {
          render :json => {
            :status => :ok,
            :message => 'Successfully updated item'
          }.to_json
        }
      end
    else
      respond_to do |format|
        format.js { render 'items/edit_or_new' }
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
      render 'items/new'
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
