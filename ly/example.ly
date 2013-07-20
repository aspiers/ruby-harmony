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
    \remove "System_start_delimiter_engraver"
    \remove "Bar_number_engraver"
  } {
    \new Staff {
      \relative c' {
        <c e gs b>1
      } |

      \time 7/4
      \small

      \relative c' {
        c4^\markup { \small "C lydian (in G)" } d e fs \emphasise g a b |
      }

      \relative c' {
        \emphasise c4^\markup { \small "C ionian" } d e f g a b |
      }

      \relative c' {
        c4^\markup { \small "C mixolydian (in F)" } d e f g a \emphasise bf |
      }

      \relative c' {
        c4^\markup { \small "C dorian (in Bb)" } d ef f g a \emphasise bf |
      }

      \break
    }
  }
}

\layout {
  \context {
    \Staff
    \remove "Time_signature_engraver"
  }
}