# opting for interleaved arrays for L-R pianos because it's a relatively uncommon case
SCORE =
# Piano 1 / Left:
%w(
1: ff  [ e4-e_ f4-e f4-e_ b4-e e5-s r-s ]2q5
 : ff  [ b3-e  b3-e b3-e_ d4-e f4-s r-s ]2q5
),
# Piano 2 / Right:
# NOTE: added 'r-t' at start & end to offset piano 2, fits the sound of the recorded piece (reference) better
%w(
1: ff [ r-t d4-e  d4-e d4-e_ f4-e b4-s r-t ]2q5
 : ff [ r-t a3-e  a3-e a3-e_ c4-e e4-s r-t ]2q5
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
},
%w{
37:    (cs6,b6-h.       cs6,b6-e)  r-e
  :    (b4-h.           b4-e)    a3,d4,b4-s-a r-s
},
%w{
37: p  (a4,e5-h.        a4,e5-e) a4,e5-s-a    r-s
  : p  (a3,d4-h.        a3,d4-e) r-e
},
%w{
38: pp (a5,cs6-h.       a5,cs6-e)  mf  b4,e5-s-a r-s
  : mp (a3,d4-h.        a3,d4-e)       a3,d4-s-a r-s
},
%w{
38:    r-w
  :    (bb2,bb3-h.        bb2,bb3-e)   r-e
},
%w{
39: mp (a4,e5-h.        a4,e5-e)   a4,e5-s-a r-s
  : mp (a3,d4-h.        a3,d4-e)   a3,d4-s-a r-s
},
%w{
39: mp (b5,cs6-h.       b5,cs6-e)     r-e
  : mp (b4-h.           b4-e)  b4-s   r-s
},
%w{
40: pp (a6-h.           a6-e)  a6-s           r-s
  : pp r-w
},
%w{
40: p  (b4,e5-h.        b4,e5-e) b4,e5-s-a    r-s
  : p  (a3,d4-h.        a3,d4-e)       r-e
},
%w{
41: mp (a4,e5-h.        a4,e5-e)   a4,e5-s-a r-s
  : mp (d4-h.           d4-e)                r-e
},
%w{
41: pp (c4-h.           c4-e)      c4,d4-s-a r-s
  : p  (bb1,bb2-h.      bb1,bb2-e)           r-e
},
%w{
42:    (b5,cs6-h.       b5,cs6-e)            r-e
  :    (a4,e5-h.        a4,e5-e)  a4,e5-s-a  r-s
},
%w{
42:    (a3,d4-h.        a3,d4-e)  a3,d4-s-a  r-s
  :    r-w
},
# TODO: diminuendo?!
%w{
43: pp [ a4-q_ cs5-q_ b5-q_ gs6-q. r-e ]4q5
  : p  (a3,d4-h.        a3,d4-e)   a3,d4-s-a r-s
},
%w{
43: pp (g5-h.           g5-e)      g5-s-a    r-s
  : p  (b4,e5-h.        b4,e5-e)   b4,e5-s-a r-s
},
%w{
44: mp (b4,e5-h        b4,e5-q.)   b4,e5-s-a r-s
  : mp a3,d4-h..       a3,d4-s-a   r-s
},
%w{
44:    r-w
  :    r-w
}, # TODO: dim
%w{
45: pp [ a4-q_ cs5-q_ b5-q_ gs6-q._ r-e ]4q5
  : p  (a3,d4-h       a3,d4-q.)   a3,d4-s-a r-s
}, # TODO: dim
%w{
45: p  (b4,e5-h     b4,e5-q.)     b4,e5-s-a r-s
  :    d4-q_  a4-q_ e5-q_ cs6-q
},
%w{
46: mp (b4,e5-h        b4,e5-q.)   b4,e5-s-a r-s
  : mp a3,d4-h..       a3,d4-s-a   r-s
},
%w{
46:    r-w
  :    r-w
}, # TODO: dim
%w{
47: mf (b4,e6-h        b4,e6-q.)   b4,e6-s-a r-s
  :    r-w
},
%w{
47: pp (b4,e5-h        b4,e5-q.)   b4,e5-s-a r-s
  : pp (a3,d4-h        a3,d4-q.)   a3,d4-s-a r-s
},
%w{
48: mp (b4,e5-h        b4,e5-q.)   b4,e5-s-a r-s
  : mp a3,d4-h..       a3,d4-s-a   r-s
},
%w{
48:    r-w
  :    r-w
},
%w{
49: p  d5-q_  a5-q_ e6-q_ cs7-q
  : pp [ a4-q_ cs5-q_ b5-q_ gs6-q r-q ]4q5
}, # TODO: 'fff' dynamic (using -a accent for now)
%w{
49: ff (b4,e5-h-a     b4,e5-q.)  b4,e5-s-a r-s
  : ff (a3,d4-h-a     a3,d4-q.)  a3,d4-s-a r-s
},
%w{
50:    r-h     r-q  r-e    mp  b4,e5-s-a r-s
  :    r-h     r-q  r-e    mp  a3,d4-s-a r-s
},
%w{
50: mp (b4,e5-h        b4,e5-q.)   r-e
  : mp a3,d4-h..                   r-e
},
%w{
51:    (b4,e5-h        b4,e5-q.)   b4,e5-s-a r-s
  :    a3,d4-h..       a3,d4-s-a   r-s
},
%w{
51: mf (a6-w
  : p  (bb1,bb2-w
},
%w{
52:    (b4,e5-h        b4,e5-q.)   b4,e5-s-a r-s
  :    a3,d4-h..       a3,d4-s-a   r-s
},
# TODO: actually ties to start of next bar, but a3,d4 also starts there?
%w{
52: mf a6-h...)                    r-s
  : p  bb1,bb2-w)
},
%w{
53: f  e6-h...                     r-s
  :    r-w
},
%w{
53:    (b4,e5-h        b4,e5-q.)   b4,e5-s-a r-s
  :    a3,d4-h..       a3,d4-s-a   r-s
},
%w{
54: mp (a4,e5-h        a4,e5-q.)   r-e
  : mp a3,d4-h..                   r-e
},
%w{
54: mp r-h    r-q.        e5-s-a r-s
  : mp r-h    r-q.          d4-s r-s
},
%w{
55: mf d5,a5-h...-a                 r-s
  : pp a3,d4-h..          a3,d4-s-a r-s
}, #TODO: dim
%w{
55: pp (b4,e5-h        b4,e5-q.)   b4,e5-s-a r-s
  : pp [ a4-q_ cs5-q_ b5-q_ g6-q. r-e ]4q5
},
%w{
56:    r-w
  :    r-w
},
%w{
56: mp (a4,e5-h        a4,e5-q.)   a4,e5-s-a r-s
  : mp a3,d4-h..                   a3,d4-s-a r-s
}

 # SCORE = '


# %w{
# 34: pp (b4,e5-h-pp        b4,e5-q.-pp) b4,e5-s r-s
#   :    (a3,d4-h-pp        a3,d4-q.-pp) a3,d4-s r-s
# }
# constants are included by load() method
START = 50
COUNT = nil
REPEAT = false #1
# REPEAT = false #1
METRO = nil
PARTS = :l  # :l, :both
PARTS  ||= :both
# use_bpm 30
DBG = true

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
