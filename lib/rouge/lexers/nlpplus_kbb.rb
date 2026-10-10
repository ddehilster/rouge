# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class NLPPlusKbb < RegexLexer
      title "NLP++ Knowledge Base"
      desc "NLP++ knowledge bases: an indented concept hierarchy with attributes (https://visualtext.org/nlp/)"
      tag 'nlpplus-kbb'
      aliases 'kbb'
      filenames '*.kbb'
      mimetypes 'text/x-nlpplus-kbb'

      state :root do
        # Indentation is the hierarchy, so it belongs to the concept rules;
        # only newlines and blank or comment-only lines are plain text here.
        rule %r/\n/, Text
        rule %r/^[ \t]+(?=\n|#|\/\*)/, Text
        rule %r/#.*$/, Comment::Single
        rule %r{/\*}, Comment::Multiline, :comment
        # a top-level concept, then an indented one
        rule %r/^([^\s#:\/][^:\n]*?)(:)/ do
          groups Name::Namespace, Punctuation
          push :attributes
        end
        rule %r/^[^\s#:\/][^:\n]*/, Name::Namespace
        rule %r/^([ \t]+)([^\s#:][^:\n]*?)(:)/ do
          groups Text, Name::Class, Punctuation
          push :attributes
        end
        rule %r/^([ \t]+)([^\s#:][^:\n]*)/ do
          groups Text, Name::Class
        end
        rule %r/[ \t]+/, Text
      end

      state :comment do
        rule %r/[^*]+/, Comment::Multiline
        rule %r{\*/}, Comment::Multiline, :pop!
        rule %r/\*/, Comment::Multiline
      end

      # name=value pairs; a value is a quoted string, a number, a bare word,
      # or a [list, "of", values]
      state :attributes do
        rule %r/\n/, Text, :pop!
        rule %r/[ \t]+/, Text
        rule %r/([\w-]+)(\s*)(=)/ do
          groups Name::Attribute, Text, Operator
        end
        rule %r/"/, Str::Double, :string
        rule %r/-?\d+(?:\.\d+)?(?![^\s,\]])/, Num
        rule %r/[\[\],]/, Punctuation
        rule %r/[^\s"\[\],=]+/, Str
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
