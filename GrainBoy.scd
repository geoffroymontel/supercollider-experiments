

SynthDef(\grainBoy,

                    {|gpos,grand,olaps,gsize,buf,ltime,pitch|
                          var grain,lag1,lag2,lag3,lag4,lag5;

                          lag1 = Ramp.kr(gpos,ltime);
                          lag2 = Ramp.kr(grand,ltime);
                          lag3 = Ramp.kr(olaps,ltime);
                          lag4 = Ramp.kr(gsize,ltime);
                          lag5 = Ramp.kr(pitch,ltime);

                          grain = Warp1.ar(1,buf,lag1,lag5,lag4,-1,lag3,lag2,4);

                          Out.ar(0,Pan2.ar(grain,0,1));
                    }


        ).send(s)

(
 var win,sedit,slide,slide2,select,grBoxes,oBoxes,pitboxes,shape,scale,blev,ssel,adds,knobVal;

~gpos =  700.collect{|i| 1*(i/700)};
~grand = 700.collect{0.4};
~gsize = 700.collect{0.2};
~olaps = 700.collect{0.3};
~pitch = 700.collect{1};
~orange = [0.5,16];
~gsrange = [0.05,0.5];
~pitrange = [-12,12];
~pbRate = 0.1;


~sflie=SoundFile.new;

  win = Window.new("grain boy", Rect(0,0,840,900));
  win.view.background_(Color.new255(95, 158, 160));

  sedit = SoundFileView(win,Rect(20,20,700,80));

  select = PopUpMenu(win,Rect(20,120,80,20))
           .items_(["Position","grain size","overlaps","rand","pitch"])
           .action_({|val| val.value.postln;
                          case{val.value==0}
                               {slide.value = (~gpos); blev.value_(~gpos.minItem); knobVal=~gpos.minItem; adds = slide.value;}
                               {val.value==1}
                               {slide.value = (~gsize); blev.value_(~gsize.minItem); knobVal=~gsize.minItem; adds = slide.value;}
                               {val.value==2}
                               {slide.value = (~olaps); blev.value_(~olaps.minItem); knobVal=~olaps.minItem; adds = slide.value;}
                               {val.value==3}
                               {slide.value = (~grand); blev.value_(~grand.minItem); knobVal=~grand.minItem; adds = slide.value;}
                               {val.value==4}
                               { slide.value = (~pitch); blev.value_(~pitch.minItem); knobVal=~pitch.minItem; adds = slide.value;}

                   });

  Button.new(win,Rect(740,20,80,20))
            .states_([["Sample Load",Color.black,Color.new255(95, 158, 160)]])
            .action_({
                      File.openDialog("",{|path| ~buffer = Buffer.read(s,path);
                                                  ~sfile = SoundFile.openRead(path);
                                              sedit.soundfile = ~sfile;
                                              sedit.read(0,~sfile.numFrames,block:8);
                                              sedit.refresh; });

                     });

shape = Slider(win,Rect(100,120,270,20))
               .value_(0.1)
               .action_({|val| var varray;

                         case{ssel.value ==0}
                                             { varray =  700.collect{|i|
                                                                        (val.value*(i/(scale.value.squared*700)).sin);
                                                                    }+adds;
                                             }
                              {ssel.value==1}
                                             {
                                                    varray = 700.collect{|i|
                                                                               ((scale.value/700)*i)%val.value
                                                                         }+adds

                                             }
                               {ssel.value==2}
                                             {
                                                varray = 700.collect{|i|
                                                                               ((scale.value/100)*i).fold2(val.value)
                                                                         }+adds
                                             }
                               {ssel.value==3}
                                              {
                                                 varray = 700.collect{|i|
                                                                               ((scale.value/700)*i)%val.value
                                                                         }.reverse+adds

                                              };

                       slide.value_(
                                      varray
                                    );


                                                case{select.value==0}
                                                           {~gpos = varray.min(1.0)}
                                                         {select.value==1}
                                                           {~gsize = varray.min(1.0).max(0.001)}
                                                         {select.value==2}
                                                           {~olaps =varray.min(1.0).max(0.001)}
                                                         {select.value==3}
                                                           {~grand = varray.min(1.0)}
                                                         {select.value==4}
                                                           {~pitch = varray.min(1.0).max(0.001)};

                                                    blev.value_(varray.minItem);
                                                    knobVal = varray.minItem;



               });

scale = Slider(win,Rect(370,120,270,20))
               .value_(0.1)
               .action_({|val| var varray;

                        case{ssel.value ==0}
                                     {  varray = 700.collect{|i|
                                                             (shape.value*(i/(val.value.squared*700)).sin)
                                                            }+adds;
                                      }
                            {ssel.value == 1}
                                              {
                                                     varray = 700.collect{|i|
                                                                                             ((val.value/700)*i)%shape.value
                                                                                        }+adds
                                                               }
                            {ssel.value == 2}
                                             {
                                                 varray = 700.collect{|i|
                                                                                             ((val.value/100)*i).fold2(shape.value)
                                                                                        }+adds
                                              }
                            {ssel.value == 3}
                                            {
                                                     varray = 700.collect{|i|
                                                                                             ((val.value/700)*i)%shape.value
                                                                                        }.reverse+adds

                                             };
                       slide.value_(
                                     varray
                                     );

                                                     case{select.value==0}
                                                           {~gpos = varray.min(1.0)}
                                                         {select.value==1}
                                                           {~gsize = varray.min(1.0).max(0.001)}
                                                         {select.value==2}
                                                           {~olaps =varray.min(1.0).max(0.001)}
                                                         {select.value==3}
                                                           {~grand = varray.min(1.0)}
                                                         {select.value==4}
                                                           {~pitch = varray.min(1.0).max(0.001)};

                                                              blev.value_(varray.minItem);
                                                              knobVal = varray.minItem;





               });




blev = Slider(win,Rect(20,100,700,20))
            .action_({|val| var move;

                       move = val.value - knobVal;

                       knobVal = val.value;

                       slide.value_(slide.value+(move));

                       case{select.value==0}
                           {~gpos = slide.value}
                           {select.value==1}
                           {~gsize = slide.value}
                           {select.value==2}
                           {~olaps = slide.value}
                           {select.value==3}
                           {~grand = slide.value}
                           {select.value==4}
                           {~pitch = slide.value};

                       adds = adds+move;

                      })
              .value_(~gpos.minItem);

knobVal=blev.value;

ssel = PopUpMenu(win,Rect(640,120,80,20))
                .items_(["sine","ramp","triangle","rev ramp","cosine"])
                .action_({adds = slide.value });

  NumberBox(win,Rect(720,140,50,20))
            .value_(~pbRate)
            .clipLo_(0.001)
            .scroll_step_(1)
            .alt_scale_(0.01)
            .ctrl_scale_(0.1)
            .action_({|val| ~pbRate=val.value});

  StaticText(win,Rect(720,170,110,20)).string_("Grain size range").align_(\center);

 grBoxes =   2.collect{|i| NumberBox(win,Rect(720+(i*60),190,50,20))
                                    .value_(~gsrange[i])
                                    .clipLo_(0.001)
                                    .scroll_step_(1)
                                    .alt_scale_(0.01)
                                    .ctrl_scale_(0.1)
                                    .action_({ |val|
                                                    ~gsrange.put(i,val.value);
                                                    case{i==1}{grBoxes[i].clipLo_(grBoxes[0].value)}
                                                        {i==0}{grBoxes[i].clipHi_(grBoxes[1].value)}
                                             })};

 StaticText(win,Rect(720,220,110,20)).string_("Overlap range").align_(\center);

 oBoxes =   2.collect{|i| NumberBox(win,Rect(720+(i*60),240,50,20))
                                    .value_(~orange[i])
                                    .clipLo_(0.001)
                                    .alt_scale_(0.01)
                                    .ctrl_scale_(0.1)
                                    .action_({ |val|
                                                    ~orange.put(i,val.value);
                                                    case{i==1}{oBoxes[i].clipLo_(oBoxes[0].value)}
                                                        {i==0}{oBoxes[i].clipHi_(oBoxes[1].value)}
                                             })};

  StaticText(win,Rect(720,270,110,20)).string_("Pitch Range").align_(\center);

 pitboxes = 2.collect{|i|  NumberBox(win,Rect(720+(i*60),290,50,20))
                                    .value_(~pitrange[i])
                                    .alt_scale_(0.01)
                                    .ctrl_scale_(0.1)
                                    .action_({ |val|
                                                   ~pitrange.put(i,val.value);
                                                    case{i==1}{pitboxes[i].clipLo_(pitboxes[0].value)}
                                                        {i==0}{pitboxes[i].clipHi_(pitboxes[1].value)}
                                             });


                      };


  slide = MultiSliderView(win,Rect(20,140,700,700))
          .valueThumbSize_(1)
          .thumbSize_(1)
          .gap_(0)
          .fillColor_(Color.new255(17, 29, 29);)
          .isFilled_(true)
          .value_(~gpos)
          .indexIsHorizontal_(false)
          .action_({|val|

                     case{select.value==0}
                           {~gpos = val.value}
                         {select.value==1}
                           {~gsize = val.value}
                         {select.value==2}
                           {~olaps = val.value}
                         {select.value==3}
                           {~grand = val.value}
                         {select.value==4}
                            {~pitch = val.value};

                   })
          .mouseUpAction_({|val| blev.value = val.value.minItem; knobVal= val.value.minItem; adds=val.value});
          adds = slide.value;


        Button(win,Rect(720,400,50,50))
              .states_([["play"],["stop"]])
              .action_({|val|
                              case{val.value==1}{~gTask.play}
                                  {val.value==0}{~gTask.stop; ~gsynth.free}
                       });



~gTask = Tdef(\grainBoy,
                          {var gsynth,wait;


                            inf.do{|i|

                             wait = ((~buffer.numFrames/s.sampleRate)/~gpos.size)/~pbRate;

                              s.makeBundle(0.25,{
                                              if(i==0 , {
                                                          ~gsynth = Synth(\grainBoy,[\buf,~buffer.bufnum,
                                                                                   \gsize,(~gsize[i]*(~gsrange[1]-~gsrange[0]))+~gsrange[0],
                                                                                   \olaps,(~olaps[i]*(~orange[1]-~orange[0]))+~orange[0],
                                                                                   \grand,~grand[i],
                                                                                   \gpos,~gpos[i],
                                                                                   \ltime,wait,
                                                                                   \pitch,1*(2**(((~pitch[i%~pitch.size]*(~pitrange[1]-~pitrange[0]))+~pitrange[0])/12)),
                                                                                   ])
                                                        },
                                                         {
                                                           ~gsynth.set    (\buf,~buffer.bufnum,
                                                                                   \gsize,(~gsize[i%~gsize.size]*(~gsrange[1]-~gsrange[0]))+~gsrange[0],
                                                                                   \olaps,(~olaps[i%~olaps.size]*(~orange[1]-~orange[0]))+~orange[0],
                                                                                   \grand,~grand[i%~grand.size],
                                                                                   \gpos,~gpos[i%~gpos.size],
                                                                                   \pitch,1*(2**(((~pitch[i%~pitch.size]*(~pitrange[1]-~pitrange[0]))+~pitrange[0])/12)),
                                                                                   \ltime,wait
                                                                                   )
                                                         }

                                                 );
                                                 }
                                             );
                                         wait.wait
                                         }
                           }

              );



      win.front;
    )

   ~gTask.play; 