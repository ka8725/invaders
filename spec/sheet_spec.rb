RSpec.describe Sheet do
  let(:config) { Config.new }

  def sheet(lines)
    Sheet.new(lines: lines, width: lines.first&.size || 0, height: lines.size)
  end

  describe '.build' do
    subject { described_class.build(entity_type, sheet_string, config) }

    context 'when entity type is sample' do
      let(:entity_type) { :sample }

      context 'with one line' do
        let(:sheet_string) { '-' }
        it { is_expected.to eq(sheet(['-'])) }
      end

      context 'with valid multiline' do
        let(:sheet_string) { "-o\no-" }
        it { is_expected.to eq(sheet(['-o', 'o-']))}
      end

      context 'with nil' do
        let(:sheet_string) { nil }
        it { is_expected.to eq(sheet([])) }
      end

      context 'with "\n"' do
        let(:sheet_string) { "\n" }
        it { is_expected.to eq(sheet([])) }
      end

      context 'with noise point' do
        let(:sheet_string) { 'O' }
        it { is_expected.to eq(sheet(['O'])) }
      end

      context 'when has unknown point' do
        let(:sheet_string) { 'x' }
        it { is_expected.to eq(sheet(['x'])) }
      end

      context 'when is not rectangular' do
        let(:sheet_string) { "-\n--" }
        specify { expect { subject }.to raise_error(ArgumentError, 'sample must be rectangular') }
      end
    end

    context 'when entity type is invader' do
      let(:entity_type) { :invader }

      context 'with one line' do
        let(:sheet_string) { '-' }
        it { is_expected.to eq(sheet(['-'])) }
      end

      context 'with valid multiline' do
        let(:sheet_string) { "-o\no-" }
        it { is_expected.to eq(sheet(['-o', 'o-']))}
      end

      context 'with nil' do
        let(:sheet_string) { nil }
        it { is_expected.to eq(sheet([])) }
      end

      context 'with "\n"' do
        let(:sheet_string) { "\n" }
        it { is_expected.to eq(sheet([])) }
      end

      context 'with noise point' do
        let(:sheet_string) { 'O' }
        specify { expect { subject }.to raise_error(ArgumentError, 'not allowed char for invader: O') }
      end

      context 'when has invalid point' do
        let(:sheet_string) { 'x' }
        specify { expect { subject }.to raise_error(ArgumentError, 'not allowed char for invader: x') }
      end

      context 'when is not rectangular' do
        let(:sheet_string) { "-\n--" }
        specify { expect { subject }.to raise_error(ArgumentError, 'invader must be rectangular') }
      end
    end

    context 'when entity type is no registered' do
      let(:entity_type) { :invalid }
      let(:sheet_string) { '' }
      specify { expect { subject}.to raise_error(KeyError) }
    end
  end
end
