# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class NLPPlusTree < RegexLexer
      title "NLP++ Parse Tree"
      desc "NLP++ parse trees, as the NLP engine writes them (https://visualtext.org/nlp/)"
      tag 'nlpplus-tree'
      filenames '*.tree'
      mimetypes 'text/x-nlpplus-tree'

      NODE_TYPES = %w(null node alpha num punct white ctrl emoji)
      FLAGS = %w(b un sem fired blt)

      state :root do
        rule %r/\n/, Text
        rule %r/^\*+[ \t]*$/, Comment::Special
        # pass headers between the per-pass snapshots
        rule %r/^([ \t]*)(PASS)([ \t]+)(\d+)([ \t]+)(\(.*?\))/ do
          groups Text, Generic::Heading, Text, Num, Text, Generic::Subheading
        end
        rule %r/^[A-Z][A-Z ]* TREE:[ \t]*$/, Generic::Heading
        # a node built by a rule, then a leaf token
        rule %r/^([ \t]*)(_\w+)([ \t]+)(?=\[)/ do
          groups Text, Name::Variable, Text
          push :record
        end
        rule %r/^([ \t]*)(\S+)([ \t]+)(?=\[)/ do
          groups Text, Name, Text
          push :record
        end
        # a whitespace token prints as blanks before its record
        rule %r/^[ \t]*(?=\[)/, Text, :record
        rule %r/[^\n]+/, Text
      end

      # [start,end,ostart,oend,pass,rule,type,flags..., ("name" value) ...]
      state :record do
        rule %r/\n/, Text, :pop!
        rule %r/[ \t]+/, Text
        rule %r/\d+/, Num::Integer
        rule %r/(?:#{NODE_TYPES.join('|')})\b/, Keyword::Type
        rule %r/(?:#{FLAGS.join('|')})\b/, Keyword
        # ("name" value): the variable's name, then its value(s)
        rule %r/(\()([ \t]*)("(?:\\.|[^"\\\n])*")/ do
          groups Punctuation, Text, Name::Attribute
        end
        rule %r/"(?:\\.|[^"\\\n])*"/, Str::Double
        rule %r/[\[\](),]/, Punctuation
        rule %r/[^\s\[\](),"]+/, Text
      end
    end
  end
end
