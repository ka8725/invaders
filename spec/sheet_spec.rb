RSpec.describe Sheet do
  let(:config) do
    Config.new(
      invaders: invaders,
      noise_threshold: noise_threshold,
      allowed_points: allowed_points
    )
  end

  describe '.build' do
    subject { described_class.build(entity_type, sheet_string, config) }


  end
end
