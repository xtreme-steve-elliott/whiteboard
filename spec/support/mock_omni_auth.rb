module MockOmniAuth
  def mock_omniauth(email_address='mkocher@pivotallabs.com')
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = {
      'info' => {
        'email' => email_address
      }
    }
  end
end