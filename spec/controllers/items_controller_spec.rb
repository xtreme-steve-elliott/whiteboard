require 'spec_helper'

describe ItemsController, :type => :controller do
  let(:standup) { create(:standup) }
  let(:params) { { standup_id: standup.id } }
  before do
    request.session[:logged_in] = true
  end

  describe '#create' do # TODO: make a test for new face creation
    context 'with valid parameters' do
      let(:valid_item) { { :item => { :title => 'Test post', :kind => 'Event' } } }
      it 'creates an item' do
        expect {
          post :create, params.merge(valid_item)
        }.to change { standup.items.count }.by(1)
      end

      it 'redirects to parent standup (HTML)' do
        post :create, params.merge(valid_item)
        expect(response).to redirect_to(standup_path(standup))
      end

      it 'returns the item (JSON)' do
        request.env['HTTP_ACCEPT'] = 'application/json'
        post :create, params.merge(valid_item)
        expect(response).to have_http_status(:ok)
        expect(response.body).to be_json_eql(Item.where(:standup_id => standup.id).order('created_at').last.to_builder(true))
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
      let(:invalid_item) { { :item => {} } }
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
    let(:valid_new_face) { { :item => { :kind => 'New face' } } }
    let(:valid_interesting) { { :item => { :kind => 'Interesting' } } }
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
      help = create(:item, kind: "Help", standup: standup)
      new_face = create(:new_face, standup: standup)
      interesting = create(:item, kind: "Interesting", standup: standup)

      get :index, params
      expect(assigns[:items]['New face']).to    eq([ new_face ])
      expect(assigns[:items]['Help']).to        eq([ help ])
      expect(assigns[:items]['Interesting']).to eq([ interesting ])
      expect(response).to be_ok
    end

    it "sorts the hash by date asc" do
      new_help = create(:item, date: 1.days.ago, standup: standup)
      old_help = create(:item, date: 4.days.ago, standup: standup)

      get :index, params
      expect(assigns[:items]['Help']).to eq([ old_help, new_help ])
    end

    it "does not include items which are associated with a post" do
      post = create(:post, standup: standup)
      help = create(:item, kind: "Help", standup: standup)
      new_face = create(:new_face, standup: standup)
      interesting = create(:item, kind: "Interesting", standup: standup)
      posted_item = create(:item, post: post, standup: standup)

      get :index, params
      expect(assigns[:items]['New face']).to    eq([ new_face ])
      expect(assigns[:items]['Help']).to        eq([ help ])
      expect(assigns[:items]['Interesting']).to eq([ interesting ])
      expect(response).to be_ok
    end

    it "does not include items associated with other standups" do
      other_standup = create(:standup)
      standup_event = create(:item, kind: "Event", standup: standup, date: Date.tomorrow)
      other_standup_event = create(:item, kind: "Event", standup: other_standup, date: Date.tomorrow)

      get :index, params

      expect(assigns[:items]['Event']).to include standup_event
      expect(assigns[:items]['Event']).not_to include other_standup_event
    end
  end

  describe "#presentation" do
    it "renders the deck template" do
      get :presentation, params
      expect(response).to render_template('deck')
    end

    it "loads the posts" do
      get :presentation, params
      expect(assigns[:items]).to be
    end

    it "only loads items from the current standup" do
      other_standup = create(:standup)
      other_standup_event = create(:item, standup: other_standup, date: Date.tomorrow, kind: "Event")
      standup_event = create(:item, standup: standup, date: Date.tomorrow, kind: "Event")

      get :presentation, params

      expect(assigns[:items]['Event']).to include standup_event
      expect(assigns[:items]['Event']).not_to include other_standup_event
    end
  end

  describe "#destroy" do
    it "should destroy the item" do
      request.env["HTTP_REFERER"] = "the url we came from"

      item = create(:item)
      delete :destroy, id: item.id
      expect(Item.find_by_id(item.id)).not_to be

      expect(response).to redirect_to "the url we came from"
    end
  end

  describe "#edit" do
    it "should edit the item" do
      item = create(:item)
      get :edit, id: item.id
      expect(assigns[:item]).to eq(item)
      expect(response).to render_template 'items/new'
    end

    it "should render the custom template for the kind if there is one" do
      item = create(:new_face)
      get :edit, id: item.id
      expect(response).to render_template('items/new_new_face')
    end
  end

  describe "#update" do
    it "should update the item" do
      item = create(:item)
      put :update, id: item.id, item: { title: "New Title" }
      expect(item.reload.title).to eq("New Title")
    end

    context "with a redirect_to param" do
      let(:item) { create(:item, post: create(:post)) }

      it "redirects to the edit post page" do
        put :update, id: item.id, post_id: item.post, item: { title: "New Title" }, redirect_to: '/foo'
        expect(response).to redirect_to('/foo')
      end
    end

    context "without a redirect_to param" do
      let(:item) { create(:item, post: create(:post)) }

      it "redirects to the standup page" do
        put :update, id: item.id, post_id: item.post, item: { title: "New Title" }
        expect(response).to redirect_to(item.standup)
      end
    end

    describe "when the item is invalid" do
      it "should render new" do
        item = create(:item)
        put :update, id: item.id, post_id: item.post, item: { title: "" }
        expect(response).to render_template('items/new')
      end

      it "should render a custom template if there is one" do
        item = create(:new_face)
        put :update, id: item.id, post_id: item.post, item: { title: "" }
        expect(response).to render_template('items/new_new_face')
      end
    end
  end
end
