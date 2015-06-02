require 'spec_helper'

describe SessionsController, :type => :controller do
  describe '#create' do
    before { expect_any_instance_of(ActionController::Base).to receive(:verify_authenticity_token).never }

    it "sets the session['logged_in'] to true" do
      request.env['omniauth.auth'] = { 'info' => { 'email' => 'mkocher@pivotal.io' } }
      post :create
      expect(request.session['logged_in']).to eq(true)
    end

    it "sets the session['username'] to the current user's name" do
      request.env['omniauth.auth'] = { 'info' => { 'name' => 'Dennis' } }
      post :create
      expect(request.session['username']).to eq('Dennis')
    end
  end

  describe '#destroy' do
    it "sets the session['logged_in'] to false" do
      request.session['logged_in'] = true
      delete :destroy
      expect(request.session['logged_in']).to eq(false)
    end
  end
end
