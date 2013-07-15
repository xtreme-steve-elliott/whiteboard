require 'spec_helper'

describe SessionsController do
  describe '#create' do
    before { ActionController::Base.any_instance.should_receive(:verify_authenticity_token).never }

    it "sets the session['logged_in'] to true" do
      request.env['omniauth.auth'] = { 'info' => { 'email' => 'mkocher@pivotallabs.com' } }
      post :create
      request.session['logged_in'].should == true
    end

    it "sets the session['username'] to the current user's name" do
      request.env['omniauth.auth'] = { 'info' => { 'name' => 'Dennis' } }
      post :create
      request.session['username'].should == 'Dennis'
    end

    it "does not allow someone from outside pivotallabs.com to log in" do
      request.env['omniauth.auth'] = { 'info' => { 'email' => 'mkocher@l33thack3r.com' } }
      post :create
      request.session['logged_in'].should be_nil
    end
  end

  describe '#destroy' do
    it "sets the session['logged_in'] to false" do
      request.session['logged_in'] = true
      delete :destroy
      request.session['logged_in'].should == false
    end
  end
end
