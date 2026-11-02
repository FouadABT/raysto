"""Original 38-second score, paper-like noise, ticks and transition accents."""
from pathlib import Path
import wave
import numpy as np

RATE, DURATION = 48000, 38
rng = np.random.default_rng(270038)
mix = np.zeros((RATE * DURATION, 2), np.float64)

def add(sound, when, gain=1, pan=0):
    offset = int(when * RATE)
    if offset < 0:
        sound = sound[-offset:]
        offset = 0
    count = min(len(sound), len(mix) - offset)
    if count <= 0:
        return
    mix[offset:offset+count, 0] += sound[:count] * gain * np.sqrt((1-pan)/2)
    mix[offset:offset+count, 1] += sound[:count] * gain * np.sqrt((1+pan)/2)

def pluck(midi, duration=.8):
    t = np.arange(int(RATE * duration))/RATE
    hz = 440 * 2 ** ((midi-69)/12)
    s = np.sin(2*np.pi*hz*t) + .23*np.sin(2*np.pi*2*hz*t) + .08*np.sin(2*np.pi*3*hz*t)
    return s * (1-np.exp(-350*t)) * np.exp(-5.5*t)

chords = [[48,55,59,64],[45,52,55,60],[41,48,52,57],[43,50,55,59]]
beat = 60/112
for i in range(int(DURATION/beat)):
    when = i*beat
    chord = chords[(i//8)%4]
    t = np.arange(int(.24*RATE))/RATE
    kick = np.sin(2*np.pi*(44*t+1.7*(1-np.exp(-35*t))))*np.exp(-23*t)
    if i % 2 == 0:
        add(kick,when,.13)
        add(pluck(chord[0]-12,.7),when,.1)
    else:
        n = rng.standard_normal(int(.08*RATE)); t=np.arange(len(n))/RATE
        brush=np.concatenate(([0],np.diff(n)))*np.exp(-55*t)
        add(brush,when,.012,-.25)
    add(pluck(chord[[0,2,1,3][i%4]]+24),when+.06,.048,(-.35,.35)[i%2])
    if i%4==3:
        add(pluck(chord[2]+24,.35),when+beat*.65,.025,.4)
    for off in [0,beat/2]:
        t=np.arange(int(.025*RATE))/RATE
        n=rng.standard_normal(len(t))
        add(n*np.exp(-190*t),when+off,.009,(-.4,.4)[i%2])

for i,when in enumerate(np.arange(0,38,beat*8)):
    t=np.arange(int(beat*8*RATE))/RATE
    env=np.minimum(t/.4,1)*np.minimum((beat*8-t)/.6,1)
    chord=chords[i%4]
    pad=sum(np.sin(2*np.pi*(440*2**((m-69)/12))*t) for m in chord)/4
    add(pad*env,when,.037)

# Paper swipes are synthesized filtered noise with a soft attack and a quick tail.
for when in [0.1,4.95,11.95,18.45,26.95,33.95]:
    t=np.linspace(0,1,int(.48*RATE)); noise=rng.standard_normal(len(t))
    smooth=np.convolve(noise,np.ones(18)/18,mode='same')
    add(smooth*np.sin(np.pi*t)**1.4,when-.18,.18,-.25)
for when in [1,1.6,2.3,5.7,6.1,6.8,8.2,10,13.35,15,19.2,20.4,22.1,24,28.5,30.3,35.4]:
    t=np.arange(int(.035*RATE))/RATE
    click=(rng.standard_normal(len(t))*.5+np.sin(2*np.pi*1200*t))*np.exp(-140*t)
    add(click,when,.047,.2)
for when in [8.6,13.4,21,30,35]:
    add(pluck(83,.5),when,.055,-.2)
    add(pluck(88,.4),when+.1,.025,.3)

# Fade only the tail; the visual ending remains open for the next chapter.
t=np.arange(len(mix))/RATE
mix*= (np.minimum(t/.06,1)*np.clip((DURATION-t)/.55,0,1))[:,None]
mix=np.tanh(mix*1.3)
mix*=.75/max(.75,float(np.max(np.abs(mix))))
out=Path(__file__).parent/'out/judges-score.wav'
out.parent.mkdir(exist_ok=True)
with wave.open(str(out),'wb') as f:
    f.setnchannels(2);f.setsampwidth(2);f.setframerate(RATE)
    f.writeframes((mix*32767).astype('<i2').tobytes())
print(f'Original soundtrack: {DURATION}s stereo, no third-party samples.')
