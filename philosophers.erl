-module(philosophers).
-export([dining/0]).
 
sleep(T) ->
  receive
after T ->
		true
	end.
 
doForks(ForkList) ->
  receive				%%Receives messages sent to the process using the send operator (!).
						%%The patterns Pattern are sequentially matched against the first message in time order in the mailbox, then the second, and so on. 
	{grabforks, {Left, Right}} -> doForks(ForkList -- [Left, Right]);
	{releaseforks, {Left, Right}} -> doForks([Left, Right| ForkList]);
	{available, {Left, Right}, Sender} -> 
          Sender ! {areAvailable, lists:member(Left, ForkList) andalso lists:member(Right, ForkList)},		     
          doForks(ForkList);
	{die} -> io:format("Forks put away.~n")
  end.
 
areAvailable(Forks) ->
	forks ! {available, Forks, self()},
	receive
		{areAvailable, false} -> false;
		{areAvailable, true} -> true
	end.
 
 
processWaitList([]) -> false;
processWaitList([H|T]) ->
	{Client, Forks} = H,
	case areAvailable(Forks) of
		true -> Client ! {served},
			true;
		false -> processWaitList(T)
	end.
 
doWaiter([], 0, 0, false) -> 
	forks ! {die},
	io:format("Waiter is leaving.~n"),
	diningRoom ! {allgone};
doWaiter(WaitList, ClientCount, EatingCount, Busy) ->
	receive
		{waiting, Client} ->
			WaitList1 = [Client|WaitList],	%% add to waiting list
			case (not Busy) and (EatingCount<2) of	
				true ->	Busy1 = processWaitList(WaitList1);
				false -> Busy1 = Busy
			end,
			doWaiter(WaitList1, ClientCount, EatingCount, Busy1);
 
		{eating, Client} ->
			doWaiter(WaitList -- [Client], ClientCount, EatingCount+1, false);		
 
		{finished} ->
			doWaiter(WaitList, ClientCount, EatingCount-1, 
				processWaitList(WaitList)); 
		{leaving} ->
			doWaiter(WaitList, ClientCount-1, EatingCount, Busy)
	end.
 
 
philosopher(Name, Forks, 0) -> 	
	io:format("~s is leaving.~n", [Name]),
 
	waiter ! {leaving};
 
 
philosopher(Name, Forks, Cycle) ->
	io:format("~s is thinking.~n", [Name]),
	sleep(random:uniform(3000)),
 
	io:format("~s is hungry.~n", [Name]),
	waiter ! {waiting, {self(), Forks}}, %%sit at table
 
	receive
		{served}-> forks ! {grabforks, Forks},	%%grab forks
			waiter ! {eating, {self(), Forks}},	%%start eating
			io:format("~s is eating.~n", [Name])
	end,
 
	sleep(random:uniform(3000)),
	forks ! {releaseforks, Forks},					%% put forks down
	waiter ! {finished},
 
	philosopher(Name, Forks, Cycle-1).
 
 
dining() ->	AllForks = [1, 2, 3, 4, 5],
		Clients = 5,
		register(diningRoom, self()),											%%self() returns the pid of the calling process
																				%%register(Name, Pid)	Associates the name Name, an atom, with the process Pid.
 
		register(forks, spawn(fun()-> doForks(AllForks) end)),					%%spawn creates a new process and returns the pid.
		register(waiter, spawn(fun()-> doWaiter([], Clients, 0, false) end)),
		Life_span = 20,
		spawn(fun()-> philosopher('Bijesh', {5, 1}, Life_span) end),
		spawn(fun()-> philosopher('Gargi', {1, 2}, Life_span) end),
		spawn(fun()-> philosopher('SaiRam', {2, 3}, Life_span) end),
		spawn(fun()-> philosopher('Vamsi', {3, 4}, Life_span) end),
		spawn(fun()-> philosopher('Prudhvi', {4, 5}, Life_span) end),
 
		receive
 			{allgone} -> io:format("Dining room closed.~n")
 
		end,
		unregister(diningRoom).