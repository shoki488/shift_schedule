Capybara.register_driver :remote_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--disable-gpu')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1920,1080')
  options.binary = ENV['CHROME_BIN']

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    if ENV["SELENIUM_DRIVER_URL"].present?
      Capybara.register_driver :remote_chrome do |app|
        options = Selenium::WebDriver::Chrome::Options.new
        options.add_argument('--headless')
        options.add_argument('--disable-gpu')
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        options.add_argument('--window-size=1920,1080')
        options.binary = ENV['CHROME_BIN']
        
        Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
      end

      driven_by :remote_chrome, using: :remote_chrome, options: {
        browser: :remote,
        url: ENV.fetch("SELENIUM_DRIVER_URL")
      }
    else
      driven_by :headless_chrome
    end
  end
end
