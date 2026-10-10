# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class NLPPlus < RegexLexer
      title "NLP++"
      desc "NLP++, the programming language for natural language processing (https://visualtext.org/nlp/)"
      tag 'nlpplus'
      aliases 'nlp++', 'nlp'
      filenames '*.nlp'
      mimetypes 'text/x-nlpplus'

      # @RULES holds the pattern rules, @POST/@PRE/@CHECK the code attached
      # to them, @CODE and @DECL plain code; each closes with @@NAME.
      REGIONS = %w(
        CHECK CODE DECL GROUP MULTI NODES PATH POST PRE RECURSE RULES SELECT
      )

      # Special node names that match classes of text.
      CONSTANTS = %w(
        xALPHA xANY xBLANK xCAPLET xCAP xCTRL xEMOJI xEND xEOF xLET xNIL xNUM
        xPUNCT xSTART xVAR xWHITE xWILD ROOT
      )

      # Modifiers inside a rule element's [...] block.
      MODIFIERS = Set.new %w(
        attr attrs base da deacc deaccent except excepts fail fails gp group
        layer layers look lookahead match matches max min nest o one opt
        option optional pass passes plus recurse ren rename s singlet star t
        tree trig trigger unsealed
      )

      KEYWORDS = Set.new %w(if else while return)

      # The engine's built-in functions. They are highlighted only when
      # called, since the same words also appear as literal text in rules.
      def self.builtins
        @builtins ||= Set.new %w(
        abs addarg addattr addcnode addconcept addconval addnode addnumval
        addstmt addstrs addstrval addsval addword arraylength attrchange
        attrexists attrname attrtype attrvals attrwithval batchstart cap cbuf
        ceiling closefile conceptname conceptpath conval cout coutreset
        dballocstmt dbbindcol dbclose dbexec dbexecstmt dbfetch dbfreestmt
        dbopen deaccent debug dictfindword dictfirst dictgetword dictnext down
        eltnode excise exitpass exittopopup factorial fail fileout findana
        findattr findattrs findconcept findhierconcept findnode findphrase
        findroot findvals findwordpath firstnode floor flt fltval fncallstart
        fprintgvar fprintnvar fprintxvar fprintvar gdump getconcept getconval
        getnumval getpopupdata getstrval getsval ginc gp group gtolower guniq
        hitconf inc inheritval inputrange inputrangetofile interactive
        kbdumptree lasteltnode lastnode length lengthr levenshtein lextagger
        listadd listnode lj log logten lookup lowercase makeconcept
        makeparentconcept makephrase makestmt merge merger mkdir mod movecleft
        movecright movesem ndump next nextattr nextval ninc nodeconcept
        nodeowner noop num numrange numval openfile or pathconcept percentstr
        permuten phraselength phraseraw phrasetext pncopyvars pndown pninsert
        pnmakevar pnname pnnext pnprev pnreplaceval pnroot pnsingletdown pnup
        pnvar pnvarnames pow pranchor prchild preaction printvar
        pndeletechilds pnrename prev print printr prlit prrange prtree
        prunephrases prxtree randomint regexp regexpi renameattr renamechild
        renameconcept renamenode replaceval resolveurl returnstmt rfaaction
        rfaactions rfaarg rfaargtolist rfacode rfaelement rfaelt rfaexpr
        rfalist rfalitelt rfalittoaction rfalittopair rfaname rfanodes
        rfanonlit rfanonlitelt rfanum rfaop rfapair rfapairs rfapostunary
        rfapres rfarange rfarecurse rfarecurses rfaregion rfaregions rfarule
        rfarulelts rfarulemark rfarules rfarulesfile rfaselect rfastr rfasugg
        rfaunary rfavar rfbarg rfbdecl rfbdecls rightjustifynum rmattr rmattrs
        rmattrval rmchild rmchildren rmconcept rmcphrase rmnode rmphrase rmval
        rmvals rmword round sdump setbase setlookahead setunsealed single
        singler singlex singlezap sortconsbyattr sortchilds sorthier
        sortphrase sortvals spellcandidates spellcorrect spellword splice
        split sqlstr sqrt startout stem stopout str strchar strchr strchrcount
        strclean strcontains strcontainsnocase strendswith strequal
        strequalnocase strescape strunescape strgreaterthan strisalpha
        strisdigit strislower strisupper strlength strlessthan strnotequal
        strnotequalnocase strpiece strrchr strspellcandidate strspellcompare
        strstartswith strsubst strtolower strtotitle strtoupper strtrim strval
        strwrap succeed suffix system take today topdir truncate unknown
        unpackdirs up uppercase urlbase urltofile var vareq varfn varfnarray
        varinlist varne varstrs varz wninit wnsensestoconcept
        wnhypnymstoconcept whilestmt wordindex wordpath writekb xaddlen
        xaddnvar xdump xinc xmlstr xrename
        )
      end

      state :root do
        mixin :whitespace

        rule %r/@@?(?:#{REGIONS.join('|')})\b/, Keyword::Declaration
        # the @@ that closes a rule
        rule %r/@@/, Keyword::Declaration
        rule %r/<-/, Operator

        # [...] is a rule element's modifier block, but the same brackets
        # are an array subscript in code, so that state lexes code too.
        rule %r/\[/, Punctuation, :modifiers

        # a literal character in a rule is backslash-escaped: \. \, \-
        rule %r/\\./, Str::Escape

        mixin :code
      end

      state :whitespace do
        rule %r/\s+/, Text
        rule %r/#.*$/, Comment::Single
        rule %r{/\*}, Comment::Multiline, :comment
      end

      state :comment do
        rule %r/[^*]+/, Comment::Multiline
        rule %r{\*/}, Comment::Multiline, :pop!
        rule %r/\*/, Comment::Multiline
      end

      state :modifiers do
        mixin :whitespace
        rule %r/\]/, Punctuation, :pop!
        rule %r/\[/, Punctuation, :modifiers
        rule %r/\\./, Str::Escape
        rule %r/[a-z]+\b(?!\s*\()/i do |m|
          token MODIFIERS.include?(m[0].downcase) ? Name::Attribute : Name
        end
        mixin :code
      end

      state :code do
        rule %r/"/, Str::Double, :string
        rule %r/\b_(?:#{CONSTANTS.join('|')})\b/, Name::Constant
        # every other leading-underscore name is a parse-tree node
        rule %r/\b_\w+/, Name::Variable
        # N("x"), S("x"), X("x"), G("x"), L("x") reach node, semantic,
        # context, global and local variables
        rule %r/\b[GLNSX](?=\s*\()/, Name::Builtin::Pseudo
        rule %r/[a-z]\w*(?=\s*\()/i do |m|
          word = m[0].downcase
          if KEYWORDS.include?(word)
            token Keyword
          elsif self.class.builtins.include?(word)
            token Name::Builtin
          else
            token Name::Function
          end
        end
        rule %r/[a-z]\w*/i do |m|
          token KEYWORDS.include?(m[0].downcase) ? Keyword : Name
        end
        rule %r/\d+\.\d+/, Num::Float
        rule %r/\d+/, Num::Integer
        rule %r/<<|&&|\|\||\+\+|--|[!=<>]=?|[-+*\/%]/, Operator
        rule %r/[{}()\[\];,.:$]/, Punctuation
        rule %r/./, Text
      end

      state :string do
        rule %r/[^"\\]+/, Str::Double
        rule %r/\\./, Str::Escape
        rule %r/"/, Str::Double, :pop!
      end
    end
  end
end
