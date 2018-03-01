//
//  AKMIDIInstrument.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AVFoundation
import CoreAudio

/// A version of AKInstrument specifically targeted to instruments that
/// should be triggerable via MIDI or sequenced with the sequencer.
open class AKMIDIInstrument: AKPolyphonicNode, AKMIDIListener {

    // MARK: - Properties

    /// MIDI Input
    open var midiIn = MIDIEndpointRef()

    /// Name of the instrument
    open var name = "AKMIDIInstrument"

    /// Initialize the MIDI Instrument
    ///
    /// - Parameter midiOutputName: Name of the instrument's MIDI output
    ///
    public init(midiOutputName: String? = nil) {
        super.init()
        enableMIDI(name: midiOutputName ?? "Unnamed")
    }

    /// Enable MIDI input from a given MIDI client
    ///
    /// - Parameters:
    ///   - midiClient: A reference to the midi client
    ///   - name: Name to connect with
    ///
    open func enableMIDI(_ midiClient: MIDIClientRef = AudioKit.midi.client,
                         name: String = "Unnamed") {
        CheckError(MIDIDestinationCreateWithBlock(midiClient, name as CFString, &midiIn) { packetList, _ in
            for e in packetList.pointee {
                let event = AKMIDIEvent(packet: e)
                self.handle(event: event)
            }
        })
    }

    private func handle(event: AKMIDIEvent) {
        self.handleMIDI(data1: MIDIByte(event.internalData[0]),
                        data2: MIDIByte(event.internalData[1]),
                        data3: MIDIByte(event.internalData[2]))
    }

    // MARK: - Handling MIDI Data

    /// Handle MIDI commands that come in externally
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number
    ///   - velocity:   MIDI velocity
    ///   - channel:    MIDI channel
    ///
    open func receivedMIDINoteOn(_ noteNumber: HarmonicNoteNumber,
                                 velocity: MIDIVelocity,
                                 channel: MIDIChannel) {
        if velocity > 0 {
            start(noteNumber: noteNumber, velocity: velocity, channel: channel)
        } else {
            stop(noteNumber: noteNumber, channel: channel)
        }
    }

    /// Handle MIDI commands that come in externally
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number
    ///   - velocity:   MIDI velocity
    ///   - channel:    MIDI channel
    ///
    open func receivedMIDINoteOff(noteNumber: HarmonicNoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        stop(noteNumber: noteNumber, channel: channel)
    }

    // MARK: - MIDI Note Start/Stop

    /// Start a note
    ///
    /// - Parameters:
    ///   - noteNumber: Note number to play
    ///   - velocity:   Velocity at which to play the note (0 - 127)
    ///   - channel:    Channel on which to play the note
    ///
    @objc open func start(noteNumber: HarmonicNoteNumber,
                          velocity: MIDIVelocity,
                          channel: MIDIChannel) {
        play(noteNumber: noteNumber, velocity: velocity)
    }

    /// Stop a note
    ///
    /// - Parameters:
    ///   - noteNumber: Note number to stop
    ///   - channel:    Channel on which to stop the note
    ///
    @objc open func stop(noteNumber: HarmonicNoteNumber, channel: MIDIChannel) {
        // OVerride in subclass
    }

    // MARK: - Private functions

    // Send MIDI data to the audio unit
    func handleMIDI(data1: MIDIByte, data2: MIDIByte, data3: MIDIByte) {
        let status = data1 >> 4
        let channel = data1 & 0xF
        if Int(status) == AKMIDIStatus.noteOn.rawValue && data3 > 0 {
            start(noteNumber: HarmonicNoteNumber(data2),
                  velocity: MIDIVelocity(data3),
                  channel: MIDIChannel(channel))
        } else if Int(status) == AKMIDIStatus.noteOn.rawValue && data3 == 0 {
            stop(noteNumber: HarmonicNoteNumber(data2), channel: MIDIChannel(channel))
        }
    }
}
