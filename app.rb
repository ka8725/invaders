class App
  def initialize(invaders:, noise_threshold: 0)
    @config = Config.configure do |config|
      config.invaders = build_invaders_sheets(invaders, config)
      config.noise_threshold = noise_threshold
    end
  end

  def matched_invaders(sample)
    sample = Sheet.build(:sample, sample || '')
    Matcher.new(config).matched_invaders(sample)
  end

  private

  attr_reader :config

  def build_invaders_sheets(invaders, app_config)
    invaders.compact.each { |invader| Sheet.build(:invader, invader, app_config) }
  end
end