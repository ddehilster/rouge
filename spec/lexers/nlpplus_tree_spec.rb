# -*- coding: utf-8 -*- #
# frozen_string_literal: true

describe Rouge::Lexers::NLPPlusTree do
  let(:subject) { Rouge::Lexers::NLPPlusTree.new }

  describe 'guessing' do
    include Support::Guessing

    it 'guesses by filename' do
      assert_guess :filename => 'final.tree'
    end

    it 'guesses by mimetype' do
      assert_guess :mimetype => 'text/x-nlpplus-tree'
    end
  end

  describe 'lexing' do
    include Support::Lexing

    it 'recognizes a built node and its record' do
      assert_tokens_includes '   _verb [0,3,0,3,8,23,node,fired,blt, ("verb" "take")]',
        ['Name.Variable', '_verb'],
        ['Literal.Number.Integer', '0'],
        ['Keyword.Type', 'node'],
        ['Keyword', 'fired'],
        ['Keyword', 'blt'],
        ['Name.Attribute', '"verb"'],
        ['Literal.String.Double', '"take"']
    end

    it 'recognizes a leaf token' do
      assert_tokens_includes '      Take [0,3,0,3,0,0,alpha]',
        ['Name', 'Take'],
        ['Keyword.Type', 'alpha']
    end

    it 'recognizes pass headers' do
      assert_tokens_includes "***************\n    PASS 12 (doses)\nPAT OUTPUT TREE:",
        ['Comment.Special', '***************'],
        ['Generic.Heading', 'PASS'],
        ['Generic.Subheading', '(doses)'],
        ['Generic.Heading', 'PAT OUTPUT TREE:']
    end

    it 'lexes the demo and the visual sample without errors' do
      assert_no_errors File.read(File.join(__dir__, '../../lib/rouge/demos/nlpplus-tree'))
      assert_no_errors File.read(File.join(__dir__, '../visual/samples/nlpplus-tree'))
    end
  end
end
