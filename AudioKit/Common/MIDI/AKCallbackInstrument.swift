//
//  AKCallbackInstrument.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

/// Function type for MIDI callbacks
public typealias AKMIDICallback = (AKMIDIStatus, HarmonicNoteNumber, MIDIVelocity) -> Void

/// MIDI Instrument that triggers functions on MIDI note on/off commands
open class AKCallbackInstrument: AKMIDIInstrument {

    // MARK: Properties

    /// All callbacks that will get triggered by MIDI events
    open var callback: AKMIDICallback?

    /// Initialize the callback instrument
    ///
    /// - parameter midiInputName: Name of the instrument's MIDI input
    /// - parameter callback: Initial callback
    ///
    public init(midiInputName: String = "callback midi in", callback: AKMIDICallback? = nil) {
        super.init()
        let midi = AudioKit.midi
        self.enableMIDI(midi.client, name: midiInputName)
        self.callback = callback
        avAudioNode = AVAudioMixerNode()
        AudioKit.engine.attach(self.avAudioNode)
    }

    fileprivate func triggerCallbacks(_ status: AKMIDIStatus,
                                      noteNumber: HarmonicNoteNumber,
                                      velocity: MIDIVelocity) {
        _ = callback.map { $0(status, noteNumber, velocity) }
    }

    /// Will trigger in response to any noteOn Message
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number being started
    ///   - velocity:   MIDI Velocity (0-127)
    ///   - channel:    MIDI Channel
    ///
    override open func start(harmonicNoteNumber: HarmonicNoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel) {
        triggerCallbacks(.noteOn, noteNumber: harmonicNoteNumber, velocity: velocity)
    }

    /// Will trigger in response to any noteOff Message
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number being stopped
    ///   - channel:    MIDI Channel
    ///
    override open func stop(harmonicNoteNumber: HarmonicNoteNumber, channel: MIDIChannel) {
        triggerCallbacks(.noteOff, noteNumber: harmonicNoteNumber, velocity: 0)
    }
}
