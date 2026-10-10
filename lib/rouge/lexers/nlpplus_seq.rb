# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class NLPPlusSeq < RegexLexer
      title "NLP++ Analyzer Sequence"
      desc "NLP++ analyzer sequences: one pass per line (https://visualtext.org/nlp/)"
      tag 'nlpplus-seq'
      filenames 'analyzer.seq'
      mimetypes 'text/x-nlpplus-seq'

      # Pass types the engine's sequence reader accepts; "pat" is read as "nlp".
      PASS_TYPES = %w(
        chartok cmltok cmltokenize dicttok dicttokz end folder gen genhash
        hash intern line lines nintern nlp pat python rec stub tok token
        tokenize
      )

      state :root do
        rule %r/\s+/, Text
        rule %r/#.*$/, Comment::Single
        rule %r{/\*}, Comment::Multiline, :comment
        rule %r{^//.*$}, Comment::Single
        # a lone slash at the start of a line switches the pass off
        rule %r{^/.*$}, Comment::Special
        rule %r/^(?:#{PASS_TYPES.join('|')})\b/i, Keyword
        rule %r/\bnil\b/, Keyword::Constant
        rule %r{[^\s#/]+}, Name::Function
      end

      state :comment do
        rule %r/[^*]+/, Comment::Multiline
        rule %r{\*/}, Comment::Multiline, :pop!
        rule %r/\*/, Comment::Multiline
      end
    end
  end
end
