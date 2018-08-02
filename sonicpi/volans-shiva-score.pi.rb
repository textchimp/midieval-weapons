# opting for interleaved arrays for L-R pianos because it's a relatively uncommon case
SCORE =
# Piano 1 / Left:
%w(
1: f  [ e4-e_ f4-e f4-e_ b4-e e5-s r-s ]2q5
 : f  [ b3-e  b3-e b3-e_ d4-e f4-s r-s ]2q5
),
# Piano 2 / Right:
%w(
1: f  [ d4-e  d4-e d4-e_ f4-e b4-s r-s ]2q5
 : f  [ a3-e  a3-e a3-e_ c4-e e4-s r-s ]2q5
),
%w(
2: a4,e5-w-f          a4,e5-s-a r-s r-e
 : a3,d4-w-f          a3,d4-s-a r-s r-e
),
%w(
2: d5-w-p             r-q
 : r-w                r-q
),
%w(
3: b5,cs6-w-p         r-q
 : r-w                r-q
),
%w(
3: a4,e5-w-f          a4,e5-s-a r-s r-e
 : a3,d4-w-p          a3,d4-s-f r-s r-e
),
%w(
4: a4,e5-w-f          a4,e5-s-a r-s r-e
 : a3,d4-w-f          a3,d4-s-a r-s r-e
),
%w(
4: p  [ d4-e c5,e5-e-a d4-e c5,e5-e-a d4-e c5,e5-e-a d4-e c5,e5-e-a d4-e c5,e5-e-a ]4q5 r-q
 : p  [ a3-e b2,d3-e-a a3-e b2,d3-e-a a3-e b2,d3-e-a a3-e b2,d3-e-a a3-e b2,d3-e-a ]4q5 r-q
),
%w(
5: e6,b6-w-pp         r-q
 : a4,gs5-w-p         r-q
),
%w(
5: a4,e5-w-f          a4,e5-s-a r-s r-e
 : a3,d4-w-f          a3,d4-s-a r-s r-e
),
%w(
6: [ f  f4-e_ e4-s r-s b4-e  b4-s r-s e5-s r-s   ff  e5-e_ b5-s r-s e4-e_ f4-s r-s f4-e ]4q5
 : [ f  b3-e  b3-s r-s b3-e_ d4-s r-s f4-s r-s   ff  d4-e_ a4-s r-s b3-e  b3-s r-s b3-e ]4q5
),
%w(
6: [ f  d4-e d4-s r-s d4-e_  f4-s r-s b4-s r-s   ff a4-e_    e5-s r-s d4-e  d4-s r-s d4-e ]4q5
 : [ f  a3-e a3-s r-s a3-e_  c4-s r-s e4-s r-s   ff cs4-e_ d4-s r-s a3-e_ a3-s r-s a3-e ]4q5
),
%w(
7: a4,e5-w-f          a4,e5-s-a r-s r-e
 : a3,d4-w-p          a3,d4-s-f r-s r-e
),
%w(
7: b5,cs6-w-p         r-q
 : r-w r-q
),
%w(
8: e6-w-p            a4,e5-s-f r-s r-e
 : r-w                r-q
),
%w(
8: a4,e5-w-f          r-q
 : a3,d4-w-f          a3,d4-s-a  r-s r-e
),
%w(
9: r-w                a4,e5-s-mf r-s r-e
 : a3,d4-w-pp         r-q
),
%w(
9: a4,e5-w-pp          r-q
 : r-w                 a3,d4-s-mf r-s r-e
),
%w(
10: r-w                a4,e5-s-mf r-s r-e
  : a3,d4-w-pp         a3,d4-s-mf r-s r-e
),
%w(
10: a4,e5-w-pp         a4,e5-s-mf r-s r-e
  : r-w                a3,d4-s-mf r-s r-e
),
%w(
11: a4,b5-w-p          a4,e5-s-mf r-s r-e
  : a3,d4-w            a3,d4-s-a  r-s r-e
),
%w(
11: gs5,e6-w-p         r-q
  : r-w                r-q
),
%w(
12: r-w                r-q
  : r-w                r-q
),
%w(
12: a4,e5-w-mf          a4,e5-s-a r-s r-e
  : a3,d4-w             a3,d4-s-a r-s r-e
),
%w(
13: a4,e5-w-pp          r-q
  : a3,d4-w-pp          r-q
),
%w(
13: r-w                a4,e5-s-a r-s r-e
  : r-w                a3,d4-s-a r-s r-e
),
%w(
14: a4,e5-w-mf            a4,e5-s-mf r-s r-e
  : a3,d4-w-mf            a3,d4-s-mf r-s r-e
),
%w(
14: a4,e5-s r-s r-e r-q r-h   r-q
  : a3,d4-s r-s r-e r-q r-h   r-q
), #      ^ this short chord's STOP cancels the longer version of the same chord in piano 1!! (need other channel?)
%w(
15: p  [ d4-e c5,e5-e-a d4-e c5,e5-e-a d4-e c5,e5-e-a d4-e c5,e5-e-a d4-e c5,e5-e-a ]4q5 r-q
 :  p  [ a3-e b2,d3-e-a a3-e b2,d3-e-a a3-e b2,d3-e-a a3-e b2,d3-e-a a3-e b2,d3-e-a ]4q5 r-q
),
%w(
15: a4,e5-w-pp          a4,e5-s-mf r-s r-e
  : a3,d4-w-pp          a3,d4-s-mf r-s r-e
),
%w(
16: e6,b6-w-pp          a4,e5-s-f  r-s r-e
  : gs5-w-pp            a3,d4-s-f  r-s r-e
),
%w(
16: a4,e5-w-pp          r-q
  : a4,e5-w-pp          r-q
), # TODO: following tuplets actually '4e5' but something wrong with calcuation; '2q5' is equiv and works
%w(
17: [ mp  e4-e_ f4-s r-s f4-e_ b4-s r-s e5-s r-s  ]2q5  r-e
  : [ mp  b3-e  b3-s r-s b3-e_ d4-s r-s f4-s r-s  ]2q5  r-e
),
%w(
17: [ mp  d4-e d4-s r-s d4-e_ f4-s r-s b4-s r-s ]2q5  r-e
  : [ mp  a3-e a3-s r-s a3-e_ c4-s r-s e4-s r-s ]2q5  r-e
),
%w(
18: [  f  e4-e_ f4-s r-s f4-e_ b4-s r-s e5-s r-s   e5-e_ b5-s r-s r-e  ff  e4-e_ f4-s r-s  ]4q5
  : [  f  b3-e  b3-s r-s b3-e_ d4-s r-s f4-s r-s   d4-e_ a4-s r-s r-e  ff  b3-e  b3-s r-s  ]4q5
),
%w(
18: [  f  d4-e  d4-s r-s d4-e_ f4-s r-s b4-s r-s   a4-e_  e5-s r-s r-e  ff  d4-e  d4-s r-s  ]4q5
  : [  f  a3-e  a3-s r-s a3-e_ c4-s r-s e4-s r-s   cs4-e_ d4-s r-s r-e  ff  a3-e  a3-s r-s  ]4q5
),
%w(
19: [  f4-e e4-e_ f4-s r-s  f4-e_ a4-s r-s   a4-e_ e5-s r-s    e5-e_  b5-e  r-e  ]4q5  e5-s  r-s r-e
  : [  b4-e a4-e_ b4-s r-s  b4-e_ e4-s r-s   e4-e_ f4-s r-s    f4-e_  db4-e r-e  ]4q5  db4-s r-s r-e
),
%w(
19: [  d4-e d4-e_ e4-s r-s  e4-e_ f4-s r-s   f4-e_  a4-s  r-s  a4-e_  a4-e  r-e  ]4q5  a4-s r-s r-e
  : [  a3-e f3-e_ a3-s r-s  a3-e_ db4-s r-s  db4-e_ db4-s r-s  db4-e_ f3-e  r-e  ]4q5  a3-s r-s r-e
),
%w(
20: e6-w-pp          a4,e5-s-mp  r-s r-e
  : r-w              a3,d4-s-mp  r-s r-e
),
%w(
20: a4,e5-w-p        r-q
  : a3,d4-w-p        r-q
),
%w(
21: a4,e5-w-p        r-q
  : a3,d4-w-p        r-q
),
%w(
21: b4,cs6-w-pp      a4,e5-s-p r-s r-e
  : r-w              a3,d4-s   r-s r-e
),
%w(
22: b5,b6-w-p        a4,e5-s-f r-s r-e
  : gs5,e6-w-pp      a3,d4-s-f r-s r-e
),
%w(
22: a4,e5-w       r-q
  : a3,d4-w        r-q
),
%w{
23: a4,e5-w-p        a4,e5-s-a r-s r-e
  : a3,d4-w-p        a3,d4-s-a r-s r-e
},
%w{
23: (a5,a6-w-mp      a5,a6-q)
  : r-w r-q
},
%w(
24: a4,e5-w-mf        a4,e5-s-a r-s r-e
  : a3,d4-w-mf        a3,d4-s-a r-s r-e
),
%w(
24: r-w               r-q
  : r-w               r-q
),
%w(
25: b4-w-pp           r-q
  : r-w               r-q
),
%w(
25: a4,e5-w-p         a4,e5-s-a r-s r-e
  : a3,d4-w-p         a3,d4-s-a r-s r-e
),
%w(
26: a4,e5-w-mf        a4,e5-s-a r-s r-e
  : a3,d4-w-mf        a3,d4-s-a r-s r-e
),
%w(
26: e6-w              r-q
  : r-w               r-q
),
%w(
27: a4,e5-w-p         a4,e5-s-a r-s r-e
  : a3,d4-w-p         a3,d4-s-a r-s r-e
),
%w{
27: (cs6,b6-w         cs6,b6-q
  : (cs4,fs4-w        cs4,fs4-q
},
# TODO: how to handle unique shorter notes? a4 here
# TODO: accents properly -mf^ including shorter timing?
# TODO: ties break the metronome because of the sleep? use shorter sleep in [dur, sleep****]
%w{
28: (b4,e5-h.-mp                 b4,e5-e)    b4,e5-s-a r-s
  : (a3,d4,a4-h.-mp              a3,d4,a4-e) a3,d4-s-a r-s
},
%w{
28: cs6,b6-h)                    r-h
  : cs4,fs4-h)                   r-h
},
%w{
29: r-w
  : r-w
},
%w{
29: (b4,e5-h.-mp        b4,e5-e)  b4,e5-s r-s
  : (a3,d4-h.-mp        a3,d4-e)  a3,d4-s r-s
}

# constants are included by load() method
START = 29
COUNT = 1 #nil
REPEAT = true #1
METRO = nil
PARTS = :both  # :l, :both
PARTS  ||= :both
# use_bpm 40


template = '
%w(
:
  :
),
%w(
:
  :
) #,
'
