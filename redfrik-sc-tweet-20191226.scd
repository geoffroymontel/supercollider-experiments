// original

play{c=ar(e=SinOsc,0,pi**ar(SinOscFB,ar(Duty,b=("00".size.."0000000".size).reciprocal,0,Dseq("0 0 00 0 0 000  _0 0 0 00 00 00000+  !".ascii,inf)),ar(e,d=$0.ascii.reciprocal).max*0.cos.sin));ar(LeakDC,ar(Splay,c+ar(PitchShift,c,e=0.cos.cos,b.reciprocal,d,d,b)))*e}// #SuperCollider


// clues
("00".size.."0000000".size);
Pseq("0 0 00 0 0 000  _0 0 0 00 00 00000+  !".ascii,1).asStream.nextN(50);

