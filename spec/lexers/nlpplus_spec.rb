# -*- coding: utf-8 -*- #
# frozen_string_literal: true

describe Rouge::Lexers::NLPPlus do
  let(:subject) { Rouge::Lexers::NLPPlus.new }

  describe 'guessing' do
    include Support::Guessing

    it 'guesses by filename' do
      assert_guess :filename => 'dates.nlp'
    end

    it 'guesses by mimetype' do
      assert_guess :mimetype => 'text/x-nlpplus'
    end
  end

  describe 'lexing' do
    include Support::Lexing

    it 'recognizes region markers and their closing forms' do
      assert_tokens_equal '@CODE @@CODE',
        ['Keyword.Declaration', '@CODE'],
        ['Text', ' '],
        ['Keyword.Declaration', '@@CODE']
    end

    it 'recognizes a rule, its modifiers and the @@ that ends it' do
      assert_tokens_equal '_np [base] <- _det _noun [opt] @@',
        ['Name.Variable', '_np'],
        ['Text', ' '],
        ['Punctuation', '['],
        ['Name.Attribute', 'base'],
        ['Punctuation', ']'],
        ['Text', ' '],
        ['Operator', '<-'],
        ['Text', ' '],
        ['Name.Variable', '_det'],
        ['Text', ' '],
        ['Name.Variable', '_noun'],
        ['Text', ' '],
        ['Punctuation', '['],
        ['Name.Attribute', 'opt'],
        ['Punctuation', ']'],
        ['Text', ' '],
        ['Keyword.Declaration', '@@']
    end

    it 'recognizes special node constants inside and outside modifiers' do
      assert_tokens_includes '_xWILD [min=2 match=(_xCAP _xNUM)] _xEMOJI',
        ['Name.Constant', '_xWILD'],
        ['Name.Attribute', 'min'],
        ['Operator', '='],
        ['Literal.Number.Integer', '2'],
        ['Name.Attribute', 'match'],
        ['Name.Constant', '_xCAP'],
        ['Name.Constant', '_xNUM'],
        ['Name.Constant', '_xEMOJI']
    end

    it 'keeps literal words in rules plain' do
      assert_tokens_equal 'in [s] next',
        ['Name', 'in'],
        ['Text', ' '],
        ['Punctuation', '['],
        ['Name.Attribute', 's'],
        ['Punctuation', ']'],
        ['Text', ' '],
        ['Name', 'next']
    end

    it 'recognizes escaped literal characters' do
      assert_tokens_includes '_abbr <- _xALPHA \. \- @@',
        ['Literal.String.Escape', '\.'],
        ['Literal.String.Escape', '\-']
    end

    it 'distinguishes accessors, built-ins and user functions' do
      assert_tokens_includes 'L("con") = getconcept(G("caps"),N("$text",1)); AddUniqueStr(L("con")); or(1,2);',
        ['Name.Builtin.Pseudo', 'L'],
        ['Literal.String.Double', '"con"'],
        ['Name.Builtin', 'getconcept'],
        ['Name.Builtin.Pseudo', 'G'],
        ['Name.Builtin.Pseudo', 'N'],
        ['Name.Function', 'AddUniqueStr'],
        ['Name.Builtin', 'or']
    end

    it 'recognizes keywords, operators and escapes in strings' do
      assert_tokens_includes 'if (L("x") && !L("y")) "out.txt" << "a \"b\" end\n"; else return 0;',
        ['Keyword', 'if'],
        ['Operator', '&&'],
        ['Operator', '!'],
        ['Operator', '<<'],
        ['Literal.String.Escape', '\"'],
        ['Literal.String.Escape', '\n'],
        ['Keyword', 'else'],
        ['Keyword', 'return']
    end

    it 'recognizes line and block comments' do
      assert_tokens_equal "# a comment\n/* a block */",
        ['Comment.Single', '# a comment'],
        ['Text', "\n"],
        ['Comment.Multiline', '/* a block */']
    end

    it 'lexes the demo and the visual sample without errors' do
      assert_no_errors File.read(File.join(__dir__, '../../lib/rouge/demos/nlpplus'))
      assert_no_errors File.read(File.join(__dir__, '../visual/samples/nlpplus'))
    end
  end
end
