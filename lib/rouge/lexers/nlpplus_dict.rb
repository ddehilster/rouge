# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class NLPPlusDict < RegexLexer
      title "NLP++ Dictionary"
      desc "NLP++ dictionaries: a headword followed by attribute=value pairs (https://visualtext.org/nlp/)"
      tag 'nlpplus-dict'
      filenames '*.dict'
      mimetypes 'text/x-nlpplus-dict'

      state :root do
        rule %r/\s+/, Text
        rule %r/#.*$/, Comment::Single
        rule %r{/\*}, Comment::Multiline, :comment
        # The headword: words separated by spaces, up to the first attribute
        # name. Words and spaces never overlap, so a long line cannot make
        # the match backtrack.
        rule %r/^[^\s#\/=][^\s=]*(?:[ \t]+(?![\w-]+[ \t]*=)[^\s=]+)*/, Name::Label, :entry
      end

      state :comment do
        rule %r/[^*]+/, Comment::Multiline
        rule %r{\*/}, Comment::Multiline, :pop!
        rule %r/\*/, Comment::Multiline
      end

      state :entry do
        rule %r/\n/, Text, :pop!
        rule %r/[ \t]+/, Text
        rule %r/([\w-]+)(\s*)(=)/ do
          groups Name::Attribute, Text, Operator
        end
        rule %r/"/, Str::Double, :string
        rule %r/-?\d+(?:\.\d+)?(?!\S)/, Num
        rule %r/[^\s"=]+/, Str
      end

      state :string do
        rule %r/[^"\\\n]+/, Str::Double
        rule %r/\\./, Str::Escape
        rule %r/"/, Str::Double, :pop!
        # an unterminated string ends with its line
        rule(/(?=\n)/) { pop! }
      end
    end
  end
end
