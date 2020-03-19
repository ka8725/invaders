require_relative './config'
require_relative './sheet'
require_relative './point'
require_relative './match'

# Entry point of the application.
#
# @example
#   app = App.new(invaders: ["--\--"], mismatch_threshold: 1)
#   app.find_invaders("--\-O") => [Point.new(row: 0, column: 0)]
class App
  # Incapsulates the matching functionality.
  class Matcher
    # @param app_config [Config]
    def initialize(app_config)
      @app_config = app_config
    end

    # @param sample [Sheet]
    # @return [Array<Match>]
    def matched_invaders(sample)
      app_config.invaders.each_with_object([]).with_index do |(invader, result), index|
        max_row = sample.height - invader.height
        max_column = sample.width - invader.width
        (0..max_row).each do |row|
          (0..max_column).each do |column|
            left_top_sample_corner = Point.new(row: row, column: column)
            if invader_matches?(sample, left_top_sample_corner, invader)
              result << Match.new(point: left_top_sample_corner, invader: index)
            end
          end
        end
      end
    end

    private

    attr_reader :app_config

    def invader_matches?(sample, start_point, invader)
      mismatches = 0
      invader.each_point do |invader_point|
        sample_point = start_point + invader_point
        mismatches += mismatch_score(sample.at(sample_point), invader.at(invader_point))
      end
      !threshold_reached?(mismatches)
    end

    def threshold_reached?(mismatches)
      mismatches > app_config.mismatch_threshold
    end

    # Calculates a penalty score for the given chars match:
    # 0 - when matches
    # 1 - mismatch and sample char is not a noise
    # 0.5 - mismatch and sample char is a noise
    def mismatch_score(sample_char, invader_char)
      is_noise = !app_config.sheet_builders[:invader].allowed_points.include?(sample_char)
      case {matches: sample_char == invader_char, is_noise: is_noise}
      in {matches: true, is_noise: _}
        0
      in {matches: false, is_noise: true}
        0.5
      in {matches: false, is_noise: false}
        1
      end
    end
  end

  def initialize(invaders:, mismatch_threshold: 0)
    @config = Config.configure do |config|
      config.invaders = build_invaders_sheets(invaders, config)
      config.mismatch_threshold = mismatch_threshold
    end
  end

  private_constant :Matcher

  # @param sample [String] a joined string of the sample
  # @return [Array<Match>] left top corners of the found invaders for the given sample and the invaders indexes
  # @raise [StandardError] @see Sheet.build for more details
  def find_invaders(sample)
    sample = Sheet.build(:sample, sample, config)
    Matcher.new(config).matched_invaders(sample)
  end

  private

  attr_reader :config

  def build_invaders_sheets(invaders, app_config)
    invaders.compact.map { |invader| Sheet.build(:invader, invader, app_config) }
  end
end
