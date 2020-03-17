# TODO: edge case invader greater than sample
RSpec.describe Radar do
  subject(:radar) { described_class.new(invaders) }

  let(:invaders) { ["--\noo"] }

  def point(x, y)
    described_class::Point.new(x: x, y: y)
  end

  def invader(lines)
    described_class::Invader.new(lines: lines, width: lines.first.size, height: lines.size)
  end

  describe '#initialize invaders' do
    subject { radar.invaders }

    context 'when some invaders are nil' do
      let(:invaders) { [nil, 'o'] }
      it { is_expected.to eq([invader(['o'])]) }
    end

    context 'when invader is a multiline' do
      let(:invaders) { ["o\n-"] }
      it { is_expected.to eq([invader(['o', '-'])]) }
    end
  end

  describe '#find_invaders' do
    subject { radar.find_invaders(sample) }

    context 'when sample is empty string' do
      let(:sample) { '' }
      it { is_expected.to eq([].to_set) }
    end

    context 'when sample is nil' do
      let(:sample) { nil }
      it { is_expected.to eq([].to_set) }
    end

    context 'when sample is "\n"' do
      let(:sample) { "\n" }
      it { is_expected.to eq([].to_set) }
    end

    context 'when sample has invaders' do
      let(:sample) { "--\noo" }

      it 'returns invaders coordinates' do
        expect(subject).to eq([point(0, 0)].to_set)
      end
    end

    context 'when sample does not have invaders' do
      context 'with empty sample' do
        let(:sample) { '' }
        it { is_expected.to eq([].to_set) }
      end

      context 'with unmatched sample' do
        let(:sample) { "oo\noo" }
        it { is_expected.to eq([].to_set) }
      end
    end

    context 'with real invaders and sample' do
      let(:sample) { File.read("#{__dir__}/fixtures/sample.txt") }
      let(:invaders) { File.read("#{__dir__}/fixtures/invaders.txt").split('~') }

      it { is_expected.to eq([].to_set) }

      context 'when increased allowed noise' do
        subject { radar.find_invaders(sample, allowed_noise: 8) }

        it { is_expected.to eq([point(13, 60), point(0, 42)].to_set) }
      end
    end
  end
end
