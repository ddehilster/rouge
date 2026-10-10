# -*- coding: utf-8 -*- #
# frozen_string_literal: true

describe Rouge::Lexers::NLPPlusKbb do
  let(:subject) { Rouge::Lexers::NLPPlusKbb.new }

  describe 'guessing' do
    include Support::Guessing

    it 'guesses by filename' do
      assert_guess :filename => 'en-nationalities.kbb'
    end

    it 'guesses by mimetype' do
      assert_guess :mimetype => 'text/x-nlpplus-kbb'
    end
  end

  describe 'lexing' do
    include Support::Lexing

    it 'recognizes top-level and nested concepts' do
      assert_tokens_equal "nationalities\n  nationality",
        ['Name.Namespace', 'nationalities'],
        ['Text', "\n  "],
        ['Name.Class', 'nationality']
    end

    it 'recognizes attributes, quoted values, numbers and lists' do
      assert_tokens_includes '    bs: name="bachelor of science", professional=1, synonym=[bsc,sb]',
        ['Name.Class', 'bs'],
        ['Punctuation', ':'],
        ['Name.Attribute', 'name'],
        ['Literal.String.Double', '"bachelor of science"'],
        ['Literal.Number', '1'],
        ['Punctuation', '['],
        ['Literal.String', 'bsc'],
        ['Punctuation', ']']
    end

    it 'keeps the rest of a line after a quoted value as attributes' do
      assert_tokens_includes '    x: name="a b", level=bachelor',
        ['Name.Attribute', 'level'],
        ['Literal.String', 'bachelor']
    end

    it 'lexes the demo and the visual sample without errors' do
      assert_no_errors File.read(File.join(__dir__, '../../lib/rouge/demos/nlpplus-kbb'))
      assert_no_errors File.read(File.join(__dir__, '../visual/samples/nlpplus-kbb'))
    end
  end
end
