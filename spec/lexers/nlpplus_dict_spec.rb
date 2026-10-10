# -*- coding: utf-8 -*- #
# frozen_string_literal: true

describe Rouge::Lexers::NLPPlusDict do
  let(:subject) { Rouge::Lexers::NLPPlusDict.new }

  describe 'guessing' do
    include Support::Guessing

    it 'guesses by filename' do
      assert_guess :filename => 'en-nationalities.dict'
    end

    it 'guesses by mimetype' do
      assert_guess :mimetype => 'text/x-nlpplus-dict'
    end
  end

  describe 'lexing' do
    include Support::Lexing

    it 'recognizes a headword and its attributes' do
      assert_tokens_equal 'afghan pos=noun iso2=af',
        ['Name.Label', 'afghan'],
        ['Text', ' '],
        ['Name.Attribute', 'pos'],
        ['Operator', '='],
        ['Literal.String', 'noun'],
        ['Text', ' '],
        ['Name.Attribute', 'iso2'],
        ['Operator', '='],
        ['Literal.String', 'af']
    end

    it 'recognizes multi-word headwords, numbers and quoted values' do
      assert_tokens_includes 'american samoan nationality=1 country="american samoa"',
        ['Name.Label', 'american samoan'],
        ['Literal.Number', '1'],
        ['Literal.String.Double', '"american samoa"']
    end

    it 'recognizes a headword with no attributes, and comments' do
      assert_tokens_equal "# a comment\naardvark",
        ['Comment.Single', '# a comment'],
        ['Text', "\n"],
        ['Name.Label', 'aardvark']
    end

    it 'lexes the demo and the visual sample without errors' do
      assert_no_errors File.read(File.join(__dir__, '../../lib/rouge/demos/nlpplus-dict'))
      assert_no_errors File.read(File.join(__dir__, '../visual/samples/nlpplus-dict'))
    end
  end
end
