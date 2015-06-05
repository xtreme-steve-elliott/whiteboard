require 'spec_helper'

describe StandupsController, :type => :controller do
  let(:standup) { create(:standup) }
  let(:params) {
    { :id => standup.id }
  }
  before do
    request.session[:logged_in] = true
  end

  describe '#create' do
    context 'with valid parameters' do
      let(:valid_standup) {
        { :standup => { :title => 'Berlin', :to_address => 'berlin+standup@pivotallabs.com' } }
      }

      it 'creates a standup' do
        expect do
          post :create, valid_standup
        end.to change { Standup.count }.by(1)
      end

      it 'redirects to the new standup (HTML)' do
        post :create, valid_standup
        expect(response).to redirect_to(standup_path(Standup.order('created_at').last))
      end

      it 'returns the new standup (JSON)' do
        request.env['HTTP_ACCEPT'] = 'application/json'
        post :create, valid_standup
        expect(response).to have_http_status(:ok)
        expect(response.body).to be_json_eql(Standup.order('created_at').last.to_builder(true))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_standup) {
        { :standup => {} }
      }

      it 'does not create a standup' do
        expect do
          post :create, invalid_standup
        end.to change { Standup.count }.by(0)
      end

      it 'renders the new standup template (HTML)' do
        post :create, invalid_standup
        expect(response).to render_template('standups/new')
      end

      it 'returns errors (JSON)' do
        request.env['HTTP_ACCEPT'] = 'application/json'
        post :create, invalid_standup
        expected_response = Jbuilder.encode do |json|
          json.set! :status, 'error'
          json.message do
            json.array! ['title can\'t be blank', 'to_address can\'t be blank']
          end
        end
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to be_json_eql(expected_response)
      end
    end
  end

  describe '#new' do
    it 'renders the new standup template (HTML)' do
      get :new
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('standups/new')
    end
  end

  describe '#index' do
    let!(:standup1) { create(:standup, :title => 'Standup 1', ip_addresses_string: '0.0.0.9') }
    let!(:standup2) { create(:standup, :title => 'Standup 2', ip_addresses_string: '0.0.0.8') }
    context 'when the user is logged in' do
      it 'renders index of all standups (HTML)' do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('standups/index')
        expect(assigns[:standups]).to eq([standup1, standup2])
      end

      it 'returns a list of all standups (JSON)' do
        request.env['HTTP_ACCEPT'] = 'application/json'
        get :index
        expected_response = Jbuilder.encode do |json|
          json.array! [standup1.to_builder.attributes!, standup2.to_builder.attributes!]
        end
        expect(response).to have_http_status(:ok)
        expect(response.body).to be_json_eql(expected_response)
        end
    end

    context 'when the user is not logged in' do
      before do
        allow(request).to receive(:remote_ip) { '0.0.0.9' }
        request.session[:logged_in] = false
      end

      it 'renders index of whitelisted standups (HTML)' do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('standups/index')
        expect(assigns[:standups]).to eq([standup1])
      end
      it 'returns a list of whitelisted standups (JSON)' do
        request.env['HTTP_ACCEPT'] = 'application/json'
        get :index
        expected_response = Jbuilder.encode do |json|
          json.array! [standup1.to_builder.attributes!]
        end
        expect(response).to have_http_status(:ok)
        expect(response.body).to be_json_eql(expected_response)
      end
    end
  end

  describe '#edit' do
    it 'renders the edit standup template (HTML)' do
      get :edit, params
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('standups/edit')
      expect(assigns[:standup]).to eq(standup)
    end
  end

  describe '#show' do
    it 'redirects to the items page of the standup (HTML)' do
      get :show, params
      expect(response).to redirect_to(standup_items_path(standup))
    end
  end

  describe '#update' do
    context 'with valid parameters' do
      let(:start_standup) {
        { :standup => { :title => 'Start Title' } }
      }
      let(:end_standup) {
        { :standup => { :title => 'End Title' } }
      }
      after do
        put :update, params.merge(start_standup)
      end

      it 'updates the standup' do
        put :update, params.merge(end_standup)
        expect(standup.reload.title).to eq(end_standup[:standup][:title])
      end

      it 'redirects to the standup (HTML)' do
        put :update, params.merge(end_standup)
        expect(response).to redirect_to(standup_path(standup))
      end

      it 'returns the standup (JSON)' do
        request.env['HTTP_ACCEPT'] = 'application/json'
        put :update, params.merge(end_standup)
        expect(response).to have_http_status(:ok)
        standup.title = end_standup[:standup][:title]
        expect(response.body).to be_json_eql(standup.to_builder(true)).excluding('updated_at')
      end
    end

    context 'with invalid parameters' do
      let (:invalid_standup) {
        { :standup => { :title => nil } }
      }
      it 'does not update the standup' do
        put :update, params.merge(invalid_standup)
        expect(standup.reload.title).to_not eq(invalid_standup[:standup][:title])
        expect(standup.reload.title).to eql(standup.title)
      end

      it 'renders the standup edit template (HTML)' do
        put :update, params.merge(invalid_standup)
        expect(response).to render_template('standups/edit')
      end

      it 'returns errors (JSON)' do
        request.env['HTTP_ACCEPT'] = 'application/json'
        put :update, params.merge(invalid_standup)
        expected_response = Jbuilder.encode do |json|
          json.set! :status, 'error'
          json.message do
            json.array! ['title can\'t be blank']
          end
        end
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to be_json_eql(expected_response)
      end
    end
  end

  describe '#destroy' do
    let!(:standup) { create(:standup) }
    let!(:params) {
      { :id => standup.id }
    }
    it 'destroys the specified standup' do
      expect {
        post :destroy, params
      }.to change(Standup, :count).by(-1)
    end
    context 'on success' do
      it 'redirects to standups index (HTML)' do
        post :destroy, params
        expect(response).to redirect_to standups_path
      end

      it 'returns ok (JSON)' do
        request.env['HTTP_ACCEPT'] = 'application/json'
        post :destroy, params
        expected_response = Jbuilder.encode do |json|
          json.set! :status, 'ok'
          json.set! :message, 'Successfully deleted standup'
        end
        expect(response).to have_http_status(:ok)
        expect(response.body).to be_json_eql(expected_response)
      end
    end

    context 'on failure' do
      # TODO: figure out how to get a destroy failure
    end
  end
end
