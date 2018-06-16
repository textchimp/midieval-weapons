# Installation instructions for Mac.

If you haven't already, go to python.org and download Python 2.7.14.

Then, run the following commands:

```
npm install osc express ws
pip2 install --pre pyosc
pip2 install --pre readchar
pip2 install --pre numpy
```

Download the latest version of [Sonic Pi](http://sonic-pi.net/) and launch it.

Clone this repo.

Plug the Leap Motion in your computer, download the Leap Motion SDK from the website and launch it.

In terminal windows/tabs:

`cd` into `/leap` and run: 

```
python2 leap-to-osc.py
```

In another window, run: 
```
node osc-websockets-bridge.js
```

Finally, open the `/web` folder and open `leap-p5.html` file in your browser. 

You should be able to draw dots in your browser using your fingers!

