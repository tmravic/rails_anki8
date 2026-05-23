require 'capybara/rspec'

# Docker networking
Capybara.server_host = '0.0.0.0'
Capybara.app_host = 'http://rspec'

Capybara.register_driver :remote_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  # options.add_argument('--headless=new') # uncomment later if you want headless

  Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    url: 'http://selenium:4444/wd/hub',
    options: options
  )
end

# Fast tests by default, real browser only when needed
Capybara.default_driver = :rack_test # fast fallback for any accidental Capybara use, overwritten in rails_helper
Capybara.javascript_driver = :remote_chrome # used if you ever write `js: true` in a test

Capybara.default_max_wait_time = 10