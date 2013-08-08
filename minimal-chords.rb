#!/usr/bin/ruby

require 'mode'
require 'scale_finder'

ModeInKey.output_modes(Note.by_name("C"))

chords = [
  [%w(E  G  B   ), 'C', 'maj7'       ],
  [%w(E  G# B   ), 'C', 'maj7#5'     ],
  [%w(Eb    B   ), 'C', '-maj7'      ],
  [%w(E  Gb Bb  ), 'C', '7b5'        ],
  [%w(E  G  Bb  ), 'C', '7'          ],
  [%w(Eb G  Bb  ), 'C', '-7'         ],
  [%w(Eb Gb Bb  ), 'C', '-7b5'       ],
  [%w(Eb Gb A   ), 'C', 'dim'        ],
  [%w(E  G  A   ), 'C', '6'          ],
  [%w(Eb G  A   ), 'C', '-6'         ],
  [%w(F  G  Bb  ), 'C', 'sus7'       ],
  [%w(Db F  Bb  ), 'C', 'Csus7b9/G'  ],
  [%w(D  E  G  A), 'C', '69'         ],
  [%w(D  F  G   ), 'C', 'sus4add2'   ],
  [%w(C  D# E G B), 'C', 'maj7#9'     ],
]

verbosity = ARGV.shift.to_i

chords.each do |chord, root, descr|
  scalefinder = ScaleFinder.new(chord, root, descr)
  scalefinder.set_verbosity(verbosity)
  scalefinder.run('ly')
  puts
end
