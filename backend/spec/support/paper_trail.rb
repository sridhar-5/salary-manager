RSpec.configure do |config|
  config.before(:each) do
    PaperTrail.enabled = true
    PaperTrail.request.whodunnit = nil
  end
end
