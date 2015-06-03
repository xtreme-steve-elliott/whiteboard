require 'spec_helper'

describe StandupsController, :type => :controller do
  let(:standup) { create(:standup) }
  before do
    request.session[:logged_in] = true
  end

  describe '#create' do
    context 'with valid params' do
      it 'creates a standup' do
        expect do
          post :create, standup: {title: 'Berlin', to_address: 'berlin+standup@pivotallabs.com'}
        end.to change { Standup.count }.by(1)
        expect(response).to be_redirect
      end
    end

    context 'with invalid params' do
      it 'creates a standup' do
        expect do
          post :create, standup: {}
        end.to change { Standup.count }.by(0)
        expect(response).to render_template 'standups/new'
      end
    end
  end

  describe '#new' do
    it 'renders the new standups template' do
      get :new
      expect(response).to be_ok
      expect(response).to render_template 'standups/new'
    end
  end

  describe '#index' do
    context 'when the user is logged in' do
      it 'renders an index of all of the standups' do
        standup1 = create(:standup)
        standup2 = create(:standup)

        get :index

        expect(response).to be_ok
        expect(assigns[:standups]).to eq([standup1, standup2])
      end

      it 'returns a list of JSON standups if requesting JSON' do
        standup1 = create(:standup, :title => 'Standup 1')
        standup1Json = standup1.to_json(:only => [:id, :title, :created_at, :updated_at, :time_zone_name, :start_time_string])
        standup2 = create(:standup, :title => 'Standup 2')
        standup2Json= standup2.to_json(:only => [:id, :title, :created_at, :updated_at, :time_zone_name, :start_time_string])
        request.env['HTTP_ACCEPT'] = 'application/json'
        get :index

        expect(assigns[:standups]).to eq([standup1, standup2])
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_exactly(2).items
        expect(response.body).to include_json(standup1Json)
        expect(response.body).to include_json(standup2Json)
      end
    end

    context 'when the user is not logged in' do
      before do
        allow(request).to receive(:remote_ip) { '0.0.0.9' }
        request.session[:logged_in] = false
      end

      it 'renders an index of the whitelisted standups' do
        standup1 = create(:standup, ip_addresses_string: '0.0.0.9')
        standup2 = create(:standup, ip_addresses_string: '0.0.0.8')

        get :index

        expect(response).to be_ok
        expect(assigns[:standups]).to eq([standup1])
      end

      it 'returns a list of JSON whitelisted standups' do
        standup1 = create(:standup, ip_addresses_string: '0.0.0.9')
        standup1Json = standup1.to_json(:only => [:id, :title, :created_at, :updated_at, :time_zone_name, :start_time_string])
        standup2 = create(:standup, ip_addresses_string: '0.0.0.8')

        request.env['HTTP_ACCEPT'] = 'application/json'
        get :index

        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_exactly(1).items
        expect(response.body).to include_json(standup1Json)
      end
    end
  end

  describe '#edit' do
    it 'shows the post for editing' do
      get :edit, id: standup.id
      expect(assigns[:standup]).to eq(standup)
      expect(response).to be_ok
    end
  end

  describe '#show' do
    it 'redirects to the items page of the standup' do
      get :show, id: standup.id
      expect(response.body).to redirect_to standup_items_path(standup)
    end
  end

  describe '#update' do
    context 'with valid params' do
      it 'updates the post' do
        put :update, id: standup.id, standup: {title: 'New Title'}
        expect(standup.reload.title).to eq('New Title')
      end
    end

    context 'with invalid params' do
      it 'does not update the post' do
        put :update, id: standup.id, standup: {title: nil}
        expect(standup.reload.title).to eq(standup.title)
        expect(response).to render_template 'standups/edit'
      end
    end
  end

  describe '#destroy' do
    let!(:standup) { create(:standup) }

    it 'destroys the specified standup' do
      expect {
        post :destroy, id: standup.id
      }.to change(Standup, :count).by(-1)
      expect(response).to redirect_to standups_path
    end
  end
end
