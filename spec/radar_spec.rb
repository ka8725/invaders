RSpec.describe Radar do
  subject(:radar) { described_class.new(invaders) }

  let(:invaders) { ["--\n00"] }

  def point(x, y)
    described_class::Point.new(x: x, y: y)
  end

  def invader(lines)
    described_class::Invader.new(lines: lines, width: lines.first.size, height: lines.size)
  end

  describe '#initialize invaders' do
    subject { radar.invaders }

    context 'when some invaders are nil' do
      let(:invaders) { [nil, '0'] }
      it { is_expected.to eq([invader(['0'])]) }
    end

    context 'when invader is a multiline' do
      let(:invaders) { ["0\n-"] }
      it { is_expected.to eq([invader(['0', '-'])]) }
    end
  end

  describe '#find_invaders' do
    subject { radar.find_invaders(sample) }

    context 'when sample is empty string' do
      let(:sample) { '' }
      it { is_expected.to eq([]) }
    end

    context 'when sample is nil' do
      let(:sample) { nil }
      it { is_expected.to eq([]) }
    end

    context 'when sample is "\n"' do
      let(:sample) { "\n" }
      it { is_expected.to eq([]) }
    end

    context 'when sample has invaders' do
      let(:sample) { "--\n00" }

      it 'returns invaders coordinates' do
        expect(subject).to eq([point(0, 0)])
      end
    end

    context 'when sample does not have invaders' do
      context 'with empty sample' do
        let(:sample) { '' }
        it { is_expected.to eq([]) }
      end

      context 'with unmatched sample' do
        let(:sample) { "00\n00" }
        it { is_expected.to eq([]) }
      end
    end
  end
end
