

Ppar : ListPattern {
	initStreams { arg priorityQ;
		list.do({ arg pattern, i;
			priorityQ.put(0.0, pattern.asStream);
		});
	}

	embedInStream { arg inval;
		var assn;
		var priorityQ = PriorityQueue.new;

		repeats.value.do({ arg j;
			var outval, stream, nexttime, now = 0.0;

			this.initStreams(priorityQ);

			// if first event not at time zero
			if (priorityQ.notEmpty and: { (nexttime = priorityQ.topPriority) > 0.0 }, {
//				outval = inval.copy;
//				outval.put(\freq, \rest);
//				outval.put(\delta, nexttime);

				outval = Event.silent(nexttime, inval);
				inval = outval.yield;
				now = nexttime;
			});

			//inval ?? { this.purgeQueue(priorityQ); ^nil.yield };

			while({
				priorityQ.notEmpty
			},{
				stream = priorityQ.pop;
				outval = stream.next(inval);
				if (outval.isNil, {
					nexttime = priorityQ.topPriority;
					if (nexttime.notNil, {
						// that child stream ended, so rest until next one
//						outval = inval.copy;
//						outval.put(\freq, \rest);
//						outval.put(\delta, nexttime - now);
						outval = Event.silent(nexttime - now, outval);
						inval = outval.yield;
						// inval ?? { this.purgeQueue(priorityQ); ^nil.yield };
						now = nexttime;
					},{
						priorityQ.clear;
					});
				},{
					// requeue stream
					priorityQ.put(now + outval.delta, stream);
					nexttime = priorityQ.topPriority;
					outval.put(\delta, nexttime - now);

					inval = outval.yield;
					// inval ?? { this.purgeQueue(priorityQ); ^nil.yield };
					now = nexttime;
				});
			});
		});
		^inval;
	}

	/*
	purgeQueue { arg priorityQ;
		while { priorityQ.notEmpty } { priorityQ.pop }
	}*/

}

Ptpar : Ppar {
	initStreams { arg priorityQ;
		forBy(0, list.size-1, 2, { arg i;
			priorityQ.put(list.at(i).value, list.at(i+1).asStream);
		});
	}
}

//Ppar : ListPattern {
//	initStreams { arg priorityQ;
//		list.do({ arg pattern, i;
//			priorityQ.put(0.0, pattern.asStream);
//		});
//	}
//	asStream {
//		^Routine({ arg inval;
//			var count = 0, join, cond;
//			join = list.size;
//			cond = Condition({ count >= join });
//			list.do({ arg func;
//				Routine({ arg time;
//					inval.
//					pattern.embedInStream(inval.copy);
//					count = count + 1;
//					cond.signal;
//				}).play;
//			});
//			cond.wait;
//		});
//	}
//}



Pgpar : Ppar {

	embedInStream { arg inevent;
		var	server, ids, patterns, event, ingroup, cleanup, stream;
		var	lag = 0, clock = thisThread.clock,
			groupReleaseTime = inevent[\groupReleaseTime] ? 0.1;

		server = inevent[\server] ?? { Server.default };
		ingroup = inevent[\group];
		ids = { server.nextNodeID } ! this.numberOfGroups;

		event = inevent.copy;
		event[\addAction] = 1;
		event[\type] = \group;
		event[\delta] = 1e-9; // no other sync choice for now. (~ 1 / 20000 sample delay)
		event[\id] = ids;
		event[\group] = ingroup;

		inevent = event.yield.copy;
		cleanup = EventStreamCleanup.new;
		cleanup.addFunction(inevent, { | flag |
			if (flag) { ( lag: lag - clock.beats + groupReleaseTime,
				type: \kill, id: ids, server: server).play };
		});

		patterns = this.wrapPatterns(ids);
		stream = this.class.implClass.new(patterns, repeats).asStream;

		inevent !? { inevent = inevent.copy; inevent[\group] = ingroup };
		loop {
			event = stream.next(inevent) ?? { ^cleanup.exit(inevent) };
			cleanup.update(event);
			lag = max(lag, clock.beats + event.use { ~sustain.value });
			inevent = event.yield;
		}

	}

	numberOfGroups { ^list.size }
	wrapPatterns { arg ids;
		^ids.collect { |id, i| Psetpre(\group, id, list[i]) };
	}

	*implClass { ^Ppar }
}

Pgtpar : Pgpar {
	numberOfGroups { ^list.size div: 2 }

	wrapPatterns { arg ids;
		var patterns = list.copy;
		ids.do { |id, i| patterns[((i << 1) + 1)] = Psetpre(\group, id, patterns[(i << 1) + 1]) };
		^patterns
	}

	*implClass { ^Ptpar }
}
