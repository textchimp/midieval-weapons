#!/usr/bin/python

EVERY_N = 2

# Leap Motion OSC bridge
#
# Packages required:
#
# Leap Motion SDK v2.3.1 (?)
# - Note that this script expects to find 'Leap.py', 'LeapPython.so' and 'libLeap.dylib' in the same folder
#   (These files are provided by the SDK in the lib/ folder)
#
# - pyosc  (`pip install --pre pyosc` or `easy_install pyosc`)
# - readchar (`pip install --pre readchar` or `easy_install readchar`)
# - numpy  (`pip install --pre numpy` or `easy_install numpy`)
#
#
# This script will let you communicate with Sonic Pi via OSC pretty easily,
# but if you want the full orchestra sample experience, you will need the following:
#
#  - LinuxSampler plus Fantasia frontend: http://www.linuxsampler.org/downloads.html
#  - Awesome piano sample library: http://download.linuxsampler.org/instruments/pianos/maestro_concert_grand_v2.rar (~1GB uncompressed)
#  - Possibly a program like Midi Patchbay (on OSX) to connect the MIDI output port from
#    this script to LinuxSampler: http://notahat.com/midi_patchbay/
#
# TODO:
#  - consider using an 'adaptive plane' such as the vertical 'touch emulation' supported by the SDK,
#    so the Y play threshold is not absolute, but moves relative to the hand - could be easier for people to learn to play
#
#  - LOOPS: left thumb pinch starts loop, any note starts and stops are recorded to loop until fingers are unpinched, which
#           sets loop length and starts playback of loop (i.e. multiple non-synced loops playing at once?)

import os, sys, inspect, thread, time
src_dir = os.path.dirname(inspect.getfile(inspect.currentframe()))
arch_dir = '../lib/x64' if sys.maxsize > 2**32 else '../lib/x86'
sys.path.insert(0, os.path.abspath(os.path.join(src_dir, arch_dir)))
import Leap
from Leap import CircleGesture, KeyTapGesture, ScreenTapGesture, SwipeGesture, Bone

from threading import Timer
import threading
import Queue

import socket, OSC

import math

import readchar

# import rtmidi
# from rtmidi.midiutil import open_midiport
# from rtmidi.midiconstants import *

from numpy import interp

# Sonic PI only accepts OSC connections from the same machine, i.e. localhost
send_address_pi = 'localhost',  4559


USE_OSC = True
# if len(sys.argv) > 1:
#     USE_OSC = True


send_address_browser = 'localhost',  57121
BROWSER_OSC = True


DEBUG = 0
if DEBUG:
    import pdb


# indexes into hand arrays
LEFT = 1
RIGHT = 0

hands = [
  { 'pinch': 0, 'fingers': [ [0]*5 ]},
  { 'pinch': 0, 'fingers': [ [0]*5 ]}
]
#
# # import pdb; pdb.set_trace()

sonic_pi_send_counter = 0

# # setup MIDI
# midiout = rtmidi.MidiOut()
# available_ports = midiout.get_ports()
# midiout.open_virtual_port("Leap Motion output")
#
# MIDI_NOTE_MIN = 19
# MIDI_NOTE_MAX = 109
# MIDI_RANGE = MIDI_NOTE_MAX - MIDI_NOTE_MIN
#
# panmidi = 64

# if USE_OSC:
pi = OSC.OSCClient()
try:
    pi.connect(send_address_pi)
except:
    print("ERROR: no connection to Sonic Pi OSC server")
    # USE_OSC = False


if BROWSER_OSC:
    browser = OSC.OSCClient()
    try:
        browser.connect(send_address_browser)
    except:
        print("ERROR: no connection to browser/websockets server")
        BROWSER_OSC = False



# Leap Motion listener

class SampleListener(Leap.Listener):

    # finger_names = ['Thumb', 'Index', 'Middle', 'Ring', 'Pinky']
    # bone_names = ['Metacarpal', 'Proximal', 'Intermediate', 'Distal']
    # state_names = ['STATE_INVALID', 'STATE_START', 'STATE_UPDATE', 'STATE_END']

    def on_connect(self, controller):
        print "Connected\r\n"

        # keep processing when app not focused
        controller.set_policy(Leap.Controller.POLICY_BACKGROUND_FRAMES)

        # Enable gestures - lots to play with here
        #
        # controller.enable_gesture(Leap.Gesture.TYPE_CIRCLE);
        # controller.enable_gesture(Leap.Gesture.TYPE_SCREEN_TAP);
        # controller.enable_gesture(Leap.Gesture.TYPE_SWIPE);
        # controller.enable_gesture(Leap.Gesture.TYPE_KEY_TAP);

        controller.config.set("Gesture.Swipe.MinLength", 100.0) #100
        controller.config.set("Gesture.Swipe.MinVelocity", 750) #750
        controller.config.save()

    def on_frame(self, controller):

        global last_silence_time, note, swipe_rec, panmidi, last_note, rec_state

        frame = controller.frame()

        for pointable in frame.pointables:

            # example attributes for pointable[0]:
            # 'frame', 'hand', 'id', 'invalid', 'is_extended', 'is_finger', 'is_tool', 'is_valid', 'length', 'stabilized_tip_position',
            #'this', 'time_visible', 'tip_position', 'tip_velocity', 'touch_distance', 'touch_zone', 'width'
            #
            # po[0].hand.is_left
            #
            # "A Hand.confidence rating indicates how well the observed data fits the internal model."

            if not pointable.is_valid:
                continue

            if pointable.hand.is_left:
                handid = LEFT
            else:
                handid = RIGHT

            # the pointable id is new each time the hand is lost and refound,
            # but it always ends in a 0 to 4, to indicate thumb to little finger
            fingerid = pointable.id % 10

            fingervel = pointable.tip_velocity
            fingerpos = pointable.tip_position

            if True or fingerid == 1:

                # Send raw position data, in millimetres
                send_pi_osc(("/leap/%s/%s/fpos" % (handid, fingerid)), [fingerpos.x, fingerpos.y, fingerpos.z])
                send_pi_osc(("/leap/%s/%s/fvel" % (handid, fingerid)), [fingervel.x, fingervel.y, fingervel.z])

                # Also send nice normalized values, scaled to an "Interaction Box"
                # see https://developer.leapmotion.com/documentation/python/api/Leap.InteractionBox.html
                i_box = frame.interaction_box
                if i_box.is_valid:
                    norm_pos = i_box.normalize_point(pointable.tip_position)
                    send_pi_osc(("/leap/%s/%s/norm/fpos" % (handid, fingerid)), [ norm_pos.x, norm_pos.y, norm_pos.z ])

                    norm_vel = i_box.normalize_point(pointable.tip_velocity)
                    # send_pi_osc(("/leap/%s/%s/norm/fvel" % (handid, fingerid)), [ norm_vel.x, norm_vel.y, norm_vel.z ])


            if BROWSER_OSC:

                # send_browser_osc( "/hand", [
                #  interp(fingerpos.x, [-100, 100], [0, 1]),
                #  interp(fingerpos.y, [20, 400], [0, 1]),
                #  interp(fingerpos.z, [-200, 200], [1, 0]), pinch
                # ])

                if i_box.is_valid:
                    norm_pos = i_box.normalize_point(pointable.tip_position)
                    send_browser_osc(("/leap/%s/%s/norm/fpos" % (handid, fingerid)), [ norm_pos.x, norm_pos.y, norm_pos.z ])

                    norm_vel = i_box.normalize_point(pointable.tip_velocity)
                    send_browser_osc(("/leap/%s/%s/norm/fvel" % (handid, fingerid)), [ norm_vel.x, norm_vel.y, norm_vel.z ])



        # Get hands - currently just used for 'silence' gesture,
        # i.e. the gesture depends on whole palm movement, not any one finger
        for hand in frame.hands:

            palm_position = hand.palm_position
            palm_velocity = hand.palm_velocity
            palm_normal = hand.palm_normal

            roll = 180.0 * palm_normal.roll / math.pi
            panmidi = interp(roll, [-90, 90], [1, 127])

            if hand.is_left:
                handid = LEFT
            else:
                handid = RIGHT

            if USE_OSC:
                send_pi_osc(("/leap/%s/roll" % handid), [ interp(roll, [-90, 90], [1, 0]) ])
                # send_sonicpi_code( "@leap_roll = %.4f;" % ( interp(roll, [-90, 90], [1, 0]) ) )

                send_pi_osc(("/leap/%s/pinch" % handid), [hand.pinch_strength])

                sphere_radius = interp( hand.sphere_radius, [40, 100], [1, 0])
                send_pi_osc("/leap/sphere_radius", [sphere_radius])

                # palm_normal = hand.palm_normal #interp( hand.palm_normal, [40, 100], [1, 0])
                send_pi_osc("/leap/palm_normal", [hand.palm_normal[0], hand.palm_normal[1], hand.palm_normal[2] ])


            if BROWSER_OSC:
                send_browser_osc(("/leap/%s/pinch" % handid), [hand.pinch_strength])
                send_browser_osc(("/leap/%s/roll" % handid), [ interp(roll, [-90, 90], [1, 0]) ])


# calculate degree of bend of finger using dot product of two bones
# returns: float indicating 'bentness' of finger: 1.0 is straight, 0.0 is fully curled
# ( https://community.leapmotion.com/t/measure-the-bending-finger-in-leap-motion-c/1036/8 )
def finger_bend( finger ):
    proximal = finger.bone(Bone.TYPE_PROXIMAL)
    distal = finger.bone(Bone.TYPE_DISTAL)
    dot = proximal.direction.dot(distal.direction)
    return 1.0 - (1.0 + dot) / 2.0;


def send_browser_osc(path, args):
    try:
        msg = OSC.OSCMessage( path )
        msg.append( [args] )
        browser.send( msg )
        # pi.send( OSC.OSCMessage("/run-code", [22]) ) # why the fuck does this no longer work?
        # print "sent " + args
    except Exception as ex:
        print ex


def send_pi_osc(path, args):

    global sonic_pi_send_counter
    sonic_pi_send_counter += 1

    if sonic_pi_send_counter % EVERY_N == 0:
        try:
            msg = OSC.OSCMessage(path)
            msg.append([args])
            pi.send(msg)
            # pi.send( OSC.OSCMessage("/run-code", [22]) ) # why the fuck does this no longer work?
            # print "sent"
            # print
            # print ', '.join(args)
        except Exception as ex:
            pass
            # print ex



# send code string to sonic pi
def send_sonicpi_code(args):
    try:
        msg = OSC.OSCMessage("/run-code")
        msg.append([0, args])
        pi.send(msg)
        # pi.send( OSC.OSCMessage("/run-code", [22]) ) # why the fuck does this no longer work?
        # print "sent " + args
    except Exception as ex:
        print ex


def setmode(mode):
    global play_mode
    play_mode = mode
    print "\r\nMODE = %d" % mode


def main():

    # set up controller and listener
    listener = SampleListener()
    controller = Leap.Controller()

    # Have the sample listener receive events from the controller
    controller.add_listener(listener)


    # Keep this process running until Enter or space or ctrl+c is pressed
    print "Press Enter or Ctrl+C to quit."
    # print "Press 1 to 0 to change instruments..."
    # try:
    while True:

        print ""
        char = readchar.readkey()
        if char == '\r' or char == ' ' or char == '\x03':
            controller.remove_listener(listener)
            sys.exit(0)

        # the following channel-to-instrument mappings are for my LinuxSampler setup;
        # yours will probably be different (remember you may need to subtract 1 from the channel shown in Linuxsampler)
        elif char == '1':
            setchan(2, "Piano")
        elif char == '2':
            setchan(3, "Harp")
        elif char == '3':
            setchan(6, "Violin (fast)")
        elif char == '4':
            setchan(5, "Cello (plucked)")
        elif char == '5':
            setchan(14, "Clarinet Ensemble (sustained)")
        elif char == '6':
            setchan(8, "Acoustic Guitar")
        elif char == '7':
            setchan(4, "Strings (sustained)")
        elif char == '8':
            setchan(5, "Double Bass piz.")
        elif char == '9':
            setchan(1, "Viola sus.")
        elif char == '0':
            setchan(15, "Drums")

        elif char == 'm':

            setmode(not play_mode)

if __name__ == "__main__":
    main()
