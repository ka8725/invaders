RSpec.describe App do
  let(:app) { described_class.new(invaders: invaders) }

  let(:invaders) { ["--\noo"] }
  let(:sample) { "--\noo" }

  def point(x, y)
    Point.new(x: x, y: y)
  end

  describe '#find_invaders' do
    subject { app.find_invaders(sample) }

    context 'when sample has invaders' do
      let(:sample) { "--\noo" }
      it { is_expected.to eq([point(0, 0)]) }
    end

    context 'when sample does not have invaders' do
      context 'with empty sample' do
        let(:sample) { '' }
        it { is_expected.to eq([]) }
      end

      context 'with unmatched sample' do
        let(:sample) { "oo\noo" }
        it { is_expected.to eq([]) }
      end

      context 'with sample smaller than invaders' do
        let(:sample) { '-' }
        it { is_expected.to eq([]) }
      end
    end

    context 'with real invaders and sample' do
      let(:sample) { File.read("#{__dir__}/fixtures/sample.txt") }
      let(:invaders) { File.read("#{__dir__}/fixtures/invaders.txt").split('~') }

      it { is_expected.to eq([]) }

      context 'when increased noise threshold' do
        let(:app) { described_class.new(invaders: invaders, noise_threshold: 8) }

        it { is_expected.to eq([point(13, 60), point(0, 42)]) }
      end
    end
  end
end
