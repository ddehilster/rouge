# -*- coding: utf-8 -*- #
# frozen_string_literal: true

describe Rouge::Lexers::NLPPlusSeq do
  let(:subject) { Rouge::Lexers::NLPPlusSeq.new }

  describe 'guessing' do
    include Support::Guessing

    it 'guesses by filename' do
      assert_guess :filename => 'analyzer.seq'
    end

    it 'guesses by mimetype' do
      assert_guess :mimetype => 'text/x-nlpplus-seq'
    end
  end

  describe 'lexing' do
    include Support::Lexing

    it 'recognizes a pass type, its file and its comment' do
      assert_tokens_equal "nlp\tsentences\t# cut the text into sentences",
        ['Keyword', 'nlp'],
        ['Text', "\t"],
        ['Name.Function', 'sentences'],
        ['Text', "\t"],
        ['Comment.Single', '# cut the text into sentences']
    end

    it 'recognizes nil and an inactive pass' do
      assert_tokens_equal "tokenize\tnil\n/nlp\toldPass",
        ['Keyword', 'tokenize'],
        ['Text', "\t"],
        ['Keyword.Constant', 'nil'],
        ['Text', "\n"],
        ['Comment.Special', "/nlp\toldPass"]
    end

    it 'lexes the demo and the visual sample without errors' do
      assert_no_errors File.read(File.join(__dir__, '../../lib/rouge/demos/nlpplus-seq'))
      assert_no_errors File.read(File.join(__dir__, '../visual/samples/nlpplus-seq'))
    end
  end
end
