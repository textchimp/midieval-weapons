# opting for interleaved arrays for L-R pianos because it's a relatively uncommon case
SCORE =
# Piano 1 / Left:
%w(
1: ff  [ e4-e_ f4-e f4-e_ b4-e e5-s r-s ]2q5
 : ff  [ b3-e  b3-e b3-e_ d4-e f4-s r-s ]2q5
),
# Piano 2 / Right:
%w(
1: ff [ d4-e  d4-e d4-e_ f4-e b4-s r-s ]2q5
 : ff [ a3-e  a3-e a3-e_ c4-e e4-s r-s ]2q5
),
%w(
2: f  a4,e5-w          a4,e5-s-a r-s r-e
 : f  a3,d4-w          a3,d4-s-a r-s r-e
),
%w(
2: p  d5-w             r-q
 :    r-w              r-q
),
%w(
3: p  b5,cs6-w         r-q
 :    r-w              r-q
),
%w(
3: f  a4,e5-w          a4,e5-s-a r-s r-e
 : p  a3,d4-w       f  a3,d4-s-a r-s r-e
),
%w(
4: f  a4,e5-w          a4,e5-s-a r-s r-e
 :    a3,d4-w          a3,d4-s-a r-s r-e
),
%w(
4: p  [ d4-e c5,e5-e-a d4-e c5,e5-e-a d4-e c5,e5-e-a d4-e c5,e5-e-a d4-e c5,e5-e-a ]4q5 r-q
 : p  [ a3-e b2,d3-e-a a3-e b2,d3-e-a a3-e b2,d3-e-a a3-e b2,d3-e-a a3-e b2,d3-e-a ]4q5 r-q
),
%w(
5: pp e6,b6-w            r-q
 :  p a4,gs5-w           r-q
),
%w(
5: f  a4,e5-w            a4,e5-s-a r-s r-e
 :    a3,d4-w            a3,d4-s-a r-s r-e
),
%w(
6: f  [ f4-e_ e4-s r-s b4-e  b4-s r-s e5-s r-s       e5-e_  b5-s r-s  ff  e4-e_ f4-s r-s f4-e ]4q5
 : f  [ b3-e  b3-s r-s b3-e_ d4-s r-s f4-s r-s       d4-e_  a4-s r-s  ff  b3-e  b3-s r-s b3-e ]4q5
),
%w(
6:    [ d4-e d4-s r-s d4-e_  f4-s r-s b4-s r-s       a4-e_  e5-s r-s  ff  d4-e  d4-s r-s d4-e ]4q5
 : f  [ a3-e a3-s r-s a3-e_  c4-s r-s e4-s r-s       cs4-e_ d4-s r-s  ff  a3-e_ a3-s r-s a3-e ]4q5
),
%w(
7: f  a4,e5-w          a4,e5-s-a r-s r-e
 : p  a3,d4-w       f  a3,d4-s-a r-s r-e
),
%w(
7: p  b5,cs6-w         r-q
 :    r-w r-q
),
%w(
8: pp e6-w          f  a4,e5-s    r-s r-e
 :    r-w              r-q
),
%w(
8:  f a4,e5-w          r-q
 :  f a3,d4-w          a3,d4-s-a  r-s r-e
),
%w(
9:    r-w          mf  a4,e5-s-a  r-s r-e
 : pp a3,d4-w          r-q
),
%w(
9: pp a4,e5-w          r-q
 : r-w             mf  a3,d4-s-a  r-s r-e
),
%w(
10:    r-w            mf  a4,e5-s-a r-s r-e
  : pp a3,d4-w        mf  a3,d4-s-a r-s r-e
),
%w(
10: pp a4,e5-w        mf  a4,e5-s-a r-s r-e
  : r-w               mf  a3,d4-s-a r-s r-e
),
%w(
11: p  a4,b5-w        mf  a4,e5-s-a r-s r-e
  :    a3,d4-w            a3,d4-s-a r-s r-e
),
%w(
11: p  gs5,e6-w           r-q
  :    r-w                r-q
),
%w(
12:    r-w                r-q
  :    r-w                r-q
),
%w(
12: mf a4,e5-w            a4,e5-s-a r-s r-e
  :    a3,d4-w            a3,d4-s-a r-s r-e
),
%w(
13: pp a4,e5-w            r-q
  : pp a3,d4-w            r-q
),
%w(
13:    r-w                a4,e5-s-a r-s r-e
  :    r-w                a3,d4-s-a r-s r-e
),
%w(
14:    a4,e5-w        mf  a4,e5-s-a r-s r-e
  :    a3,d4-w        mf  a3,d4-s-a r-s r-e
),
%w(
14:    a4,e5-s r-s r-e r-q r-h   r-q
  :    a3,d4-s r-s r-e r-q r-h   r-q
), #      ^ this short chord's STOP cancels the longer version of the same chord in piano 1!! (need other channel?)
%w(
15: p  [ d4-e c5,e5-e-a d4-e c5,e5-e-a d4-e c5,e5-e-a d4-e c5,e5-e-a d4-e c5,e5-e-a ]4q5 r-q
 :  p  [ a3-e b2,d3-e-a a3-e b2,d3-e-a a3-e b2,d3-e-a a3-e b2,d3-e-a a3-e b2,d3-e-a ]4q5 r-q
),
%w(
15: pp a4,e5-w        mf  a4,e5-s-a r-s r-e
  : pp a3,d4-w        mf  a3,d4-s-a r-s r-e
),
%w(
16: pp e6,b6-w         f  a4,e5-s-a r-s r-e
  : pp gs5-w           f  a3,d4-s-a r-s r-e
),
%w(
16: pp a4,e5-w            r-q
  : pp a4,e5-w            r-q
), # TODO: following tuplets actually '4e5' but something wrong with calcuation; '2q5' is equiv and works
%w(
17: ff [ e4-e_ f4-s r-s f4-e_ b4-s r-s e5-s r-s ]2q5  r-e
  : ff [ b3-e  b3-s r-s b3-e_ d4-s r-s f4-s r-s ]2q5  r-e
),
%w(
17: ff [ d4-e  d4-s r-s d4-e_ f4-s r-s b4-s r-s ]2q5  r-e
  : ff [ a3-e  a3-s r-s a3-e_ c4-s r-s e4-s r-s ]2q5  r-e
),
%w(
18: f  [ e4-e_ f4-s r-s f4-e_ b4-s r-s e5-s r-s   e5-e_ b5-s r-s r-e  ff  e4-e_ f4-s r-s  ]4q5
  : f  [ b3-e  b3-s r-s b3-e_ d4-s r-s f4-s r-s   d4-e_ a4-s r-s r-e  ff  b3-e  b3-s r-s  ]4q5
),
%w(
18: f  [ d4-e  d4-s r-s d4-e_ f4-s r-s b4-s r-s   a4-e_  e5-s r-s r-e  ff  d4-e  d4-s r-s  ]4q5
  : f  [ a3-e  a3-s r-s a3-e_ c4-s r-s e4-s r-s   cs4-e_ d4-s r-s r-e  ff  a3-e  a3-s r-s  ]4q5
),
%w(
19:    [ f4-e e4-e_ f4-s r-s  f4-e_ a4-s r-s   a4-e_ e5-s r-s    e5-e_  b5-e  r-e  ]4q5  e5-s-a  r-s r-e
  :    [ b4-e a4-e_ b4-s r-s  b4-e_ e4-s r-s   e4-e_ f4-s r-s    f4-e_  db4-e r-e  ]4q5  db4-s-a r-s r-e
),
%w(
19:    [ d4-e d4-e_ e4-s r-s  e4-e_ f4-s r-s   f4-e_  a4-s  r-s  a4-e_  a4-e  r-e  ]4q5  a4-s    r-s r-e
  :    [ a3-e f3-e_ a3-s r-s  a3-e_ db4-s r-s  db4-e_ db4-s r-s  db4-e_ f3-e  r-e  ]4q5  a3-s-a  r-s r-e
),
%w(
20: pp e6-w           mp  a4,e5-s-a  r-s r-e
  : r-w               mp  a3,d4-s-a  r-s r-e
),
%w(
20: p  a4,e5-w        r-q
  : p  a3,d4-w        r-q
),
%w(
21: p  a4,e5-w        r-q
  : p  a3,d4-w        r-q
),
%w(
21: pp b4,cs6-w       p  a4,e5-s-a r-s r-e
  :    r-w            p  a3,d4-s-a r-s r-e
),
%w(
22: p  b5,b6-w        f  a4,e5-s-a r-s r-e
  : pp gs5,e6-w       f  a3,d4-s-a r-s r-e
),
%w(
22:    a4,e5-w             r-q
  :    a3,d4-w             r-q
),
%w{
23: p  a4,e5-w           a4,e5-s-a r-s r-e
  : p  a3,d4-w           a3,d4-s-a r-s r-e
},
%w{
23: mp (a5,a6-w          a5,a6-q)
  :    r-w r-q
},
%w(
24: mf a4,e5-w           a4,e5-s-a r-s r-e
  : mf a3,d4-w           a3,d4-s-a r-s r-e
),
%w(
24:    r-w               r-q
  :    r-w               r-q
),
%w(
25: pp b4-w              r-q
  :    r-w               r-q
),
%w(
25: p  a4,e5-w           a4,e5-s-a r-s r-e
  : p  a3,d4-w           a3,d4-s-a r-s r-e
),
%w(
26: mf a4,e5-w           a4,e5-s-a r-s r-e
  : mf a3,d4-w           a3,d4-s-a r-s r-e
),
%w(
26:    e6-w              r-q
  :    r-w               r-q
),
%w(
27: p  a4,e5-w           a4,e5-s-a r-s r-e
  : p  a3,d4-w           a3,d4-s-a r-s r-e
),
%w{
27: (cs6,b6-w            cs6,b6-q
  : (cs4,fs4-w           cs4,fs4-q
},
# TODO: how to handle unique shorter notes? a4 here, ie. 'a3,d4,a4-h.|a4-s'
%w{
28: mp (b4,e5-h.         b4,e5-e)    b4,e5-s-a r-s
  : mp (a3,d4,a4-h.      a3,d4,a4-e) a3,d4-s-a r-s
},
%w{
28:    cs6,b6-h)         r-h
  :    cs4,fs4-h)        r-h
},
%w{
29: r-w
  : r-w
},
%w{
29: mp (b4,e5-h.         b4,e5-e) b4,e5-s r-s
  : mp (a3,d4-h.         a3,d4-e) a3,d4-s r-s
},
%w{
30:    (b4-h.            b4-e)    r-e
  :    r-h      r-q      r-e      r-e
},
%w{
30:    r-h      r-q      r-e      b4,e5-s-a r-s
  :    (a3,d4-h.-a       a3,d4-e) a3,d4-s-a r-s
},
%w{
31: pp (gs5,a6-h         gs5,a6-q.) gs5,a6-s r-s
  :    r-w
},
%w{
31:    (b4,e5-h.         b4,e5-e)   b4,e5-s-a r-s
  :    (a3,d4-h.-a       a3,d4-e)   a3,d4-s-a r-s
},
%w{
32: mp (b4,e5-h.       b4,e5-e)   r-e
  : mp (a3,d4-h.       a3,d4-e)   r-e
},
%w{
32:    r-h r-q             r-e     f  b4,e5-s r-s
  :    r-h r-q             r-e     f  a3,d4-s r-s
},
%w{
33:    (b4,e5-h.            b4,e5-e)   r-e
  :    (a3,d4-h.            a3,d4-e)   r-e
},
%w{
33:    r-h r-q              r-e        b4,e5-s r-s
  :    r-h r-q              r-e        a3,d4-s r-s
},
%w{
34: pp (e5,a6-h        e5,a6-q.)       e5,a6-s r-s
  :    r-w
},
%w{
34: pp (b4,e5-h        b4,e5-q.)       b4,e5-s-a r-s
  : pp (a3,d4-h        a3,d4-q.)       a3,d4-s-a r-s
},
%w{
35:    (b4,e5-h.       b4,e5-e)        r-e
  :    r-w
},
%w{
35:    r-h r-q              r-e     f  b4,e5-s-a r-s
  :    (a3,d4-h.       a3,d4-e)     f  a3,d4-s-a r-s
},
%w{
36: mp (b4,e5-h.        b4,e5-e)   r-e
  : mp (a3,d4-h.        a3,d4-e)   r-e
},
%w{
36:    r-h r-q             r-e    pp  b4,e5-s r-s
  :    r-h r-q             r-e    pp  a3,d4-s r-s
}

# SCORE = '


# %w{
# 34: pp (b4,e5-h-pp        b4,e5-q.-pp) b4,e5-s r-s
#   :    (a3,d4-h-pp        a3,d4-q.-pp) a3,d4-s r-s
# }
# constants are included by load() method
START = 1
COUNT = nil
REPEAT = false #1
# REPEAT = false #1
METRO = nil
PARTS = :both  # :l, :both
PARTS  ||= :both
# use_bpm 40


# template = '
# %w(
# :
#   :
# ),
# %w(
# :
#   :
# ) #,
# '
