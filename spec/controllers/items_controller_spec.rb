require 'spec_helper'

describe ItemsController, :type => :controller do
  let(:standup) { create(:standup) }
  let(:other_standup) { create(:standup) }
  let(:params) { {standup_id: standup.id} }
  before do
    request.session[:logged_in] = true
  end

  describe '#create' do # TODO: make a test for new face creation
    context 'with valid parameters' do
      let(:valid_item) { {item: {title: 'Test post', kind: Item::KIND_EVENT}} }
      let(:other_valid_item) { {item: {standup_id: other_standup.id, title: 'Test post 2', kind: Item:: KIND_EVENT}} }
      it 'creates an item' do
        expect {
          post :create, params.merge(valid_item)
        }.to change { standup.items.count }.by(1)
      end

      it 'creates an item with standup_id passed in' do
        expect {
          post :create, params.merge(other_valid_item)
        }.to change { other_standup.items.count }.by(1)
      end

      it 'redirects to parent standup (HTML)' do
        post :create, params.merge(valid_item)
        expect(response).to redirect_to(standup_path(standup))
      end

      it 'returns the item (JSON)' do
        request.env['HTTP_ACCEPT'] = 'application/json'
        post :create, params.merge(valid_item)
        expect(response).to have_http_status(:ok)
        expect(response.body).to be_json_eql(Item.where(standup_id: standup.id).order('created_at').last.to_builder(true))
      end

      it 'sets the post_id if one is provided and redirects to post edit (HTML)' do
        standup_post = create(:post)
        expect {
          post :create, params.merge(valid_item.tap do |params|
                params[:item][:post_id] = standup_post.to_param
              end)
        }.to change { standup_post.items.count }.by(1)
        expect(response).to redirect_to(edit_post_path(standup_post))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_item) { {item: {}} }
      it 'does not create an item' do
        expect {
          post :create, params.merge(invalid_item)
        }.to change { standup.items.count }.by(0)
      end

      it 'renders the new item template (HTML)' do
        post :create, params.merge(invalid_item)
        expect(response).to render_template('items/new')
      end

      it 'returns errors (JSON)' do
        request.env['HTTP_ACCEPT'] = 'application/json'
        post :create, params.merge(invalid_item)
        expected_response = Jbuilder.encode do |json|
          json.set! :status, 'error'
          json.message do
            json.array! ['kind is not included in the list','title can\'t be blank']
          end
        end
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to be_json_eql(expected_response)
      end
    end
  end

  describe '#new' do
    let(:valid_new_face) { {item: {kind: Item::KIND_NEW_FACE}} }
    let(:valid_interesting) { {item: {kind: Item::KIND_INTERESTING}} }
    it 'renders the new item template (HTML)' do
      get :new, params
      expect(assigns[:item]).to be_new_record
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('items/new')
    end

    it 'should render the custom template for the kind if there is one (HTML)' do
      get :new, params.merge(valid_new_face)
      expect(response).to render_template('items/new_new_face')
    end

    it 'uses the params to create the new item so you can set defaults in the link (HTML)' do
      get :new, params.merge(valid_interesting)
      expect(assigns[:item].kind).to eq('Interesting')
    end

    it 'should set the author on the new Item (HTML)' do
      session[:username] = 'Barney Rubble'
      get :new, params
      item = assigns[:item]
      expect(item.author).to eq('Barney Rubble')
    end
  end

  describe '#index' do
    it 'generates a hash of items by type' do
      help = create(:help_item, standup: standup)
      new_face = create(:new_face_item, standup: standup)
      interesting = create(:interesting_item, standup: standup)

      get :index, params
      expect(assigns[:items][Item::KIND_NEW_FACE]).to eq([new_face])
      expect(assigns[:items][Item::KIND_HELP]).to eq([help])
      expect(assigns[:items][Item::KIND_INTERESTING]).to eq([interesting])
      expect(response).to have_http_status(:ok)
    end

    it 'sorts the hash by date asc' do
      new_help = create(:help_item, date: 1.days.ago, standup: standup)
      old_help = create(:help_item, date: 4.days.ago, standup: standup)

      get :index, params
      expect(assigns[:items][Item::KIND_HELP]).to eq([old_help, new_help])
    end

    it 'does not include items which are associated with a post' do
      post = create(:post, standup: standup)
      help = create(:help_item, standup: standup)
      new_face = create(:new_face_item, standup: standup)
      interesting = create(:interesting_item, standup: standup)
      posted_item = create(:item, post: post, standup: standup)

      get :index, params
      expect(assigns[:items][Item::KIND_NEW_FACE]).to eq([new_face])
      expect(assigns[:items][Item::KIND_HELP]).to eq([help])
      expect(assigns[:items][Item::KIND_INTERESTING]).to eq([interesting])
      expect(response).to have_http_status(:ok)
    end

    it 'does not include items associated with other standups' do
      standup_event = create(:event_item, date: Date.tomorrow, standup: standup)
      other_standup_event = create(:event_item, date: Date.tomorrow, standup: other_standup)

      get :index, params

      expect(assigns[:items][Item::KIND_EVENT]).to include(standup_event)
      expect(assigns[:items][Item::KIND_EVENT]).not_to include(other_standup_event)
    end
  end

  describe '#presentation' do
    it 'renders the deck template' do
      get :presentation, params
      expect(response).to render_template('deck')
    end

    it 'loads the posts' do
      get :presentation, params
      expect(assigns[:items]).to be
    end

    it 'only loads items from the current standup' do
      other_standup_event = create(:event_item, date: Date.tomorrow, standup: other_standup)
      standup_event = create(:event_item, date: Date.tomorrow, standup: standup)

      get :presentation, params

      expect(assigns[:items][Item::KIND_EVENT]).to include(standup_event)
      expect(assigns[:items][Item::KIND_EVENT]).not_to include(other_standup_event)
    end
  end

  describe '#destroy' do
    let!(:item) { create(:item)}
    let!(:params) { {id: item.id}}
    it 'destroys the specified item' do
      expect {
        delete :destroy, params
      }.to change(Item, :count).by(-1)
    end

    context 'on success' do
      it 'redirects to the page we came from (HTML)' do
        request.env['HTTP_REFERER'] = 'the url we came from'
        delete :destroy, params
        expect(response).to redirect_to 'the url we came from'
      end

      it 'redirects to the standup for that item if no referer (HTML)' do
        delete :destroy, params
        expect(response).to redirect_to standup_items_path(item.standup)
      end

      it 'returns ok (JSON)' do
        request.env['HTTP_ACCEPT'] = 'application/json'
        delete :destroy, params
        expected_response = Jbuilder.encode do |json|
          json.set! :status, 'ok'
          json.set! :message, 'Successfully deleted item'
        end
        expect(response).to have_http_status(:ok)
        expect(response.body).to be_json_eql(expected_response)
      end
    end

    context 'on failure' do
      # TODO: figure out how to test deletion failure
    end
  end

  describe '#edit' do
    it 'should edit the item' do
      item = create(:item)
      get :edit, id: item.id
      expect(assigns[:item]).to eq(item)
      expect(response).to render_template 'items/new'
    end

    it 'should render the custom template for the kind if there is one' do
      item = create(:new_face_item)
      get :edit, id: item.id
      expect(response).to render_template('items/new_new_face')
    end
  end

  describe '#update' do
    it 'should update the item' do
      item = create(:item)
      put :update, id: item.id, item: { title: 'New Title' }
      expect(item.reload.title).to eq('New Title')
    end

    context 'with a redirect_to param' do
      let(:item) { create(:item, post: create(:post)) }

      it 'redirects to the edit post page' do
        put :update, id: item.id, post_id: item.post, item: { title: 'New Title' }, redirect_to: '/foo'
        expect(response).to redirect_to('/foo')
      end
    end

    context 'without a redirect_to param' do
      let(:item) { create(:item, post: create(:post)) }

      it 'redirects to the standup page' do
        put :update, id: item.id, post_id: item.post, item: { title: 'New Title' }
        expect(response).to redirect_to(item.standup)
      end
    end

    context 'when the item is invalid' do
      it 'should render new' do
        item = create(:item)
        put :update, id: item.id, post_id: item.post, item: { title: '' }
        expect(response).to render_template('items/new')
      end

      it 'should render a custom template if there is one' do
        item = create(:new_face_item)
        put :update, id: item.id, post_id: item.post, item: { title: '' }
        expect(response).to render_template('items/new_new_face')
      end
    end
  end
end
