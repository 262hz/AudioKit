//
//  AKOscillatorBankAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once

#import "AKBankAudioUnit.h"

@interface AKOscillatorBankAudioUnit : AKBankAudioUnit

- (void)setupWaveform:(int)size;
- (void)setWaveformValue:(float)value atIndex:(UInt32)index;
- (void)startNote:(uint16_t)note velocity:(uint8_t)velocity;
- (void)startNote:(uint16_t)note velocity:(uint8_t)velocity frequency:(float)frequency;
- (void)stopNote:(uint16_t)note;
- (void)reset;

@end

