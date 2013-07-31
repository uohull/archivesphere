module UserLogin
  def login_as(login)
      user = login.is_a?(String) ? User.find_or_create_by(login:login) : login
      driver_name = "rack_test_authenticated_header_#{user.user_key}"
      Capybara.register_driver(driver_name) do |app|
        Capybara::RackTest::Driver.new(app, headers: { 'REMOTE_USER' => user.user_key })
      end
      Capybara.current_driver = driver_name
  end  
end
