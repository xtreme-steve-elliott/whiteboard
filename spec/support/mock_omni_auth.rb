module MockOmniAuth
  def mock_omniauth
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = {
      'info' => {
        'email' => 'mkocher@pivotallabs.com'
      }
    }
  end
end