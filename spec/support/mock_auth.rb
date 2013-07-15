module MockAuth
  def login
    ApplicationController.any_instance.stub(:session).and_return({logged_in: true, username: nil})
  end
end