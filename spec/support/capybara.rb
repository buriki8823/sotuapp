require "capybara/rspec"
require "selenium-webdriver"

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.binary = ENV.fetch("CHROME_BIN", "/usr/bin/chromium")
  options.add_argument("--headless=new")
  options.add_argument("--disable-gpu")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--window-size=1400,1400")
  options.add_argument("--disable-extensions")
  options.add_argument("--disable-background-timer-throttling")
  options.add_argument("--disable-backgrounding-occluded-windows")
  options.add_option('goog:loggingPrefs', { browser: 'ALL' })

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Web サーバーがコンテナ内で動き、ブラウザも同コンテナ内で動作する想定
Capybara.server = :puma, { Silent: true }
Capybara.server_host = ENV.fetch("CAPYBARA_SERVER_HOST", "127.0.0.1")
Capybara.server_port = ENV.fetch("CAPYBARA_SERVER_PORT", "3001").to_i
Capybara.app_host = ENV.fetch("CAPYBARA_APP_HOST", "http://127.0.0.1:#{Capybara.server_port}")

Capybara.javascript_driver = :selenium_chrome_headless
Capybara.default_driver = :rack_test
Capybara.default_max_wait_time = 10