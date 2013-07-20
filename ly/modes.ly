\version "2.17.9"
\include "english.ly"

\paper { 
  indent = #0
  ragged-right = ##t
  ragged-last = ##t
}

emphasisColor = #(x11-color 'ForestGreen)
emphasisColor = #red

emphasise = \once {
  \large
  \override NoteHead.color = \emphasisColor
  \override Stem.color = \emphasisColor

  % Would need to stop/restart staff for this to work; see
  % example of how to do that here:
  % http://lsr.dsi.unimi.it/LSR/Item?id=700 
  \override Staff.LedgerLineSpanner.color = \emphasisColor
}

\score {
  \new Score \with {
    \remove "Bar_number_engraver"
  } {
    \time 7/4
    \new StaffGroup {
      <<
        \new Staff {
          \small

          \mark "Lydian" 
          \relative c' {
            c4 d e fs \emphasise g a b |
          }

          \mark "Ionian" 
          \relative c' {
            \emphasise c4 d e f g a b |
          }

          \mark "Mixolydian" 
          \relative c' {
            c4 d ef f g a \emphasise bf |
          }

          \mark "Dorian" 
          \relative c' {
            c4 d ef f g a \emphasise bf |
          }

          \break
        }
        \new Staff {
          \relative c' {
            s2 <c e fs b>1 s4 |
          }
          \relative c' {
            s1 s2.
          }
          \relative c' {
            s1 s2.
          }
          \relative c' {
            s1 s2.
          }
        }
      >>
    }
  }
}

\layout {
  \context {
    \Staff
    \remove "Time_signature_engraver"
  }
}