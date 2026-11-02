"""Original 45-second electronic score and transition sounds; no sampled music."""
from pathlib import Path
import wave
import numpy as np

RATE=48000
DURATION=78
rng=np.random.default_rng(271026)
mix=np.zeros((RATE*DURATION,2),dtype=np.float64)

def add(sound,when,volume=1,pan=0):
    offset=int(when*RATE)
    count=min(len(sound),len(mix)-offset)
    if count<=0:return
    mix[offset:offset+count,0]+=sound[:count]*volume*np.sqrt((1-pan)/2)
    mix[offset:offset+count,1]+=sound[:count]*volume*np.sqrt((1+pan)/2)

def note(midi,length=1.4):
    t=np.arange(int(RATE*length))/RATE
    freq=440*2**((midi-69)/12)
    carrier=np.sin(2*np.pi*freq*t)+.27*np.sin(2*np.pi*freq*2*t)+.08*np.sin(2*np.pi*freq*3*t)
    return carrier*(1-np.exp(-t*250))*np.exp(-t*4.5)

chords=[[48,55,59,64],[45,52,55,60],[41,48,52,57],[43,50,55,59]]
for beat in range(154):
    when=beat*.5
    if when<3.5:continue
    t=np.arange(int(.32*RATE))/RATE
    kick=np.sin(2*np.pi*(48*t+2*(1-np.exp(-t*35))))*np.exp(-t*18)
    add(kick,when,.18 if beat%4==0 else .13)
    if beat%2:
        n=rng.standard_normal(int(.12*RATE))
        high=np.concatenate(([0],np.diff(n)))
        t=np.arange(len(n))/RATE
        add(high*np.exp(-t*34),when,.023,.1)
    for eighth in [0,.25]:
        n=rng.standard_normal(int(.045*RATE));t=np.arange(len(n))/RATE
        high=np.concatenate(([0],np.diff(n)))
        add(high*np.exp(-t*100),when+eighth,.009 if eighth==0 else .006,-.35 if beat%2 else .35)
    chord=chords[(beat//8)%4]
    if beat%2==0:add(note(chord[0]-12,.9),when,.12)
    melody=chord[[0,2,1,3,2,1,3,2][beat%8]]+24
    pluck=note(melody)
    add(pluck,when+.125,.07,(-.3,.3)[beat%2])
    add(pluck,when+.375,.018,(-.3,.3)[(beat+1)%2])

for chord_index,when in enumerate(np.arange(0,77,4)):
    t=np.arange(4*RATE)/RATE
    env=np.minimum(t/.3,1)*np.minimum((4-t)/.6,1)
    chord=chords[chord_index%4]
    pad=sum(np.sin(2*np.pi*(440*2**((m-69)/12))*t) for m in chord)/4
    add(pad*env,when,.055)

for when in [4,10,17,25,31,37,45,53,60,68,73]:
    count=int(.52*RATE);t=np.linspace(0,1,count)
    noise=rng.standard_normal(count)
    smooth=np.convolve(noise,np.ones(24)/24,mode='same')
    add(smooth*np.sin(np.pi*t)**2,when-.26,.17,-.15)
    add(note(84,.6),when,.045,.25)
for when in [7,13,19,22,27,33,40,48,55,63,70,75]:
    add(note(88,.15),when,.055)

fade=np.minimum(np.arange(len(mix))/RATE/.2,1)*np.clip((DURATION-np.arange(len(mix))/RATE)/1.4,0,1)
mix*=fade[:,None]
mix=np.tanh(mix*1.25)
mix*=.73/max(.73,np.max(np.abs(mix)))
out=Path(__file__).parent/'out/challenge-score.wav'
out.parent.mkdir(exist_ok=True)
with wave.open(str(out),'wb') as f:
    f.setnchannels(2);f.setsampwidth(2);f.setframerate(RATE)
    f.writeframes((mix*32767).astype('<i2').tobytes())
print(f'Original score: {DURATION}s, {RATE}Hz, stereo; peak {np.max(np.abs(mix)):.3f}')
