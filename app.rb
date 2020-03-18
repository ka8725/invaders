require_relative './config'
require_relative './sheet'
require_relative './matcher'

# Entry point of the application.
#
# @example
#   app = App.new(invaders: ["--\--"], noise_threshold: 1)
#   app.find_invaders("--\-O") => [Point.new(x: 0, y: 0)]
class App
  def initialize(invaders:, noise_threshold: 0)
    @config = Config.configure do |config|
      config.invaders = build_invaders_sheets(invaders, config)
      config.noise_threshold = noise_threshold
    end
  end

  # @param sample [String] a joined string of the sample
  # @return [Array<Point>] left top corners of the found invaders for the given sample
  # @raise [StandardError] @see Sheet.build for more details
  def find_invaders(sample)
    sample = Sheet.build(:sample, sample || '', config)
    Matcher.new(config).matched_invaders(sample)
  end

  private

  attr_reader :config

  def build_invaders_sheets(invaders, app_config)
    invaders.compact.map { |invader| Sheet.build(:invader, invader, app_config) }
  end
end
