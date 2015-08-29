
-module(part2).
-export([print_list/1]).
-export([permutate/1]).
-export([readlines/1]).
-export([checkinput/1]).
-export([playGame/0]).

%%--------------------------------------PROBLEM -1 -------------------------------------------------%%
print_list(List) ->List,Newlist = list(List),io:format("Input 1:~p\n",[List]),io:format("\nInput 2:~p\n",[Newlist]),Output=hd(List -- Newlist),io:format("\nOutput: ~p\n",[Output]).
list([])     -> [];
list([Elem]) -> [Elem];
list(List)   ->	tl(list(List, length(List), [])). %%list(List,length(List)) returns a shuffled list from the given input.%% 
list([], 0, Result) ->				  %%Pattern match to return the resulting List%%
    Result;
list(List, Len, Result) ->			  %%recursively picks the random elements fromt he given input list and shuffles them randomly %%
    {Elem, Rest} = nth_rest(random:uniform(Len), List), %%nth_rest function calculates the ordering of the lists after the list is uniformly randomized%%
    list(Rest, Len - 1, [Elem|Result]).

nth_rest(N, List) -> nth_rest(N, List, []).

nth_rest(1, [E|List], Prefix) -> {E, lists:append(Prefix,List)}; 
nth_rest(N, [E|List], Prefix) -> nth_rest(N - 1, List, [E|Prefix]). %%The input list gets updated everytime nth-rest function is recursively called.%%
 

%%--------------------------------------PROBLEM -2 -------------------------------------------------%%
readlines(FileName)->
	Newlist1 = readline(FileName), %%returns the contents of the file after the file is read.%%
	Length1= length(Newlist1),     %% Newlist1 holds the contents of the file in the form of a list. Length1 is the length of Newlist1%%
	Length2= length(writefile(Newlist1)), %%writefile returns the list of all the contents of the file after skipping the white spaces.%%
					      %%Length2 is the length of the list after white spaces are removed %%
	Newlist2 = string:tokens(Newlist1, "\n"), %%string:tokens tokenizes the Newlist based on the newline character  %%
	Length3 = length(Newlist2), 
	io:format("Count of Words are written to the file successfully.\n"),Len=(Length1-Length2)+Length3,writetoafile(Len). %% writetoafile(Len) Outputs the number of words in a file%%
readline(FileName) ->
    {ok, Device} = file:open(FileName, [read]), %% opens the file and sends it to the Device pointer.
    try get_all_lines(Device)			%% Exception arises if the contents of the file are not properly read or if the file contents are not proper.%%
      after file:close(Device)
    end.

get_all_lines(Device) ->			
    case io:get_line(Device, "") of		%% Reads the contents of the file character by character till EOF is reached%%
        eof  -> [];
        Line -> Line ++ get_all_lines(Device)	%% Updates the Device pointer as soona s the new line character is read.%%
    end.
writefile(Newlist1) ->
	[X || X <- Newlist1, X /= 32].
	
writetoafile(Len)->				%% performs the write operation to a new file. Change the path of the file as and when required%%
	{ok, IODevice} = file:open("D:/Data/Erlang/output.txt", [write]), file:write(IODevice, lists:flatten(io_lib:format("~p", [Len]))), file:close(IODevice).

	

%%--------------------------------------PROBLEM -3 -------------------------------------------------%%
permutate(L) -> perms(atom_to_list(L)). %%atom_to_list converts the input string which can be considered as an atom into a list of characters. %%
perms([]) -> [[]];  
perms(L) -> [[H|T] || H <- L, T <- perms(L--[H])]. %%List comprehension displays the permutations of the input string by recursively %%
						   %%updating the list removing the head of the updated list everytime and then mapping %%
						   %%it to H and T respectively to display all the permutations of the String.%%

	
%%--------------------------------------PROBLEM -4 -------------------------------------------------%%
checkinput(Pattern) ->
	check(match(Pattern,[])). %%check function returns YES if the parenthesis are balanced, otherwise returns NO. match returns a list after all PUSh and POP operations are performed%%
	 
match(Pattern, NewPattern) ->	  %%Performs stack operation. if element of the pattern is opening parenthesis, it is pushed into the stack. %%
				  %%if a matching closing parenthesis is found, it will be popped out of the statck.%%
			if	
				hd(Pattern)=:=123 -> 
					match(tl(Pattern),lists:append(NewPattern,[123]));
				hd(Pattern)=:=40 -> 
					match(tl(Pattern),lists:append(NewPattern,[40]));
				hd(Pattern)=:=91 -> 
					match(tl(Pattern),lists:append(NewPattern,[91]));
				hd(Pattern)=:=125 -> 
					case lists:last(NewPattern) =:= 123 of					%%Condition to pop. if a matching opening parenthesis is found perform POP operation. Otherwise Program is terminated.%%
							true ->
								match(tl(Pattern),lists:droplast(NewPattern));
							false ->
								match([],NewPattern)
						end;
				hd(Pattern)=:=41 -> 
					case lists:last(NewPattern) =:= 40 of					%%Condition to pop. if a matching opening parenthesis is found perform POP operation. Otherwise Program is terminated.%%
							true ->
							match(tl(Pattern),lists:droplast(NewPattern));
							false ->
							match([],NewPattern)
						end;
				hd(Pattern)=:=93 -> 
					case lists:last(NewPattern) =:= 91 of					%%Condition to pop. if a matching opening parenthesis is found perform POP operation. Otherwise Program is terminated.%%
							true ->
							match(tl(Pattern),lists:droplast(NewPattern));
							false ->
							match([],NewPattern)
						end;
				true -> 
					NewPattern
			end.

check(Input)->				%%checks if the Input list is empty or not. Returns YES if Input list is empty i.e., all parenthesis are balanced. %%
	case length(Input) =:= 0 of 
		true -> "YES";
		false ->
		"NO"
	end.


%%--------------------------------------PROBLEM -5 -------------------------------------------------%%	
playGame()->Gameset=['a','b','c','d','e','f','g'],
		SplitGameset=playGameset(Gameset),			%%Returns the set of shuffled alphabets from a to g  %%
		{ActualGameset,Playerset}=lists:split(3,SplitGameset),  %%Selects the Actual perpretrator set and stored in ActualGameset List %%
		startGame(ActualGameset,Playerset).			%%After selection of Actual perpretrator set, startGame function stsarts the game. 
playGameset([])     -> [];
playGameset([Elem]) -> [Elem];
playGameset(Gameset)   -> playGameset(Gameset, length(Gameset), []).
playGameset([], 0, Result) -> Result;
playGameset(Gameset, Len, Result) ->
			 {Elem, Rest} = n_th_rest(random:uniform(Len), Gameset),
			  playGameset(Rest, Len - 1, [Elem|Result]).
n_th_rest(N, Gameset) -> n_th_rest(N, Gameset, []).
n_th_rest(1, [E|Gameset], Prefix) -> {E, lists:append(Prefix,Gameset)};
n_th_rest(N, [E|Gameset], Prefix) -> n_th_rest(N - 1, Gameset, [E|Prefix]).

startGame(ActualGameset,Playerset)->startGame(ActualGameset,Playerset,0,1).		%%Pattern match the startGame function to decide if the player is won or not. In the first turn system selects one correct perpetrator from ActualGameset.%%
startGame(ActualGameset,Playerset,3,1)->io:format("Players lost the game in first attempt. Now try again!!\n"), %% when the third argument values reaches three, announces players have lost the game after turn 1.%%
				        startGame(ActualGameset,Playerset,0,2);		%% Allows the players to play the game again. But this time it shows two correct perpretrators out of ActualGameset%%
startGame(ActualGameset,Playerset,3,2)->io:format("Players lost the game. Actual Perpetrators are ~p.",[ActualGameset]); %% Announces players have lost the game if the count becomes three and all guesses were incorrect%%
startGame(ActualGameset,Playerset,Count,1)->{S1,S2}=lists:split(1,ActualGameset),       %%Picks one correct perpretrator and stores in list S1%%
					    {P1,P2}=lists:split(2,Playerset),		%%Picks two incorrect perpretrator and stires it in list P1%%
					     Results=lists:append(S1,P1),		
					     io:format("Perpetrators set is ~p of which one Perpetrator is correct\n",[Results]), %%Displays the set of three perpretrators of which one is correct.%%
					    {ok, [AX]} = io:fread("Enter your first actual Perpetrator you guess:", "~c"),	  %%Promts the player to enter his guess for first actual perpretrator%%
					    {ok, [BX]} = io:fread("Enter your second Actual Perpetrator you Guess :", "~c"),	  %%prompts the player to enter his guess for second actual perpretrator%%
					    Result=lists:append(AX,BX),								  
						case Result =:= S2 of								  %%Check if the player's guess is corretc or not%%
							true ->	startGame(ActualGameset);					  %%Announces player as the winner if the guess is correct%%
							false ->startGame(ActualGameset,Playerset,(Count+1),1)			  %%asks for another player to enter his guess%%
						end;
startGame(ActualGameset,Playerset,Count,2)->{S1,S2}=lists:split(2,ActualGameset),	%%Picks two correct perpretrator and stores in list S1%%
					    {P1,P2}=lists:split(1,Playerset),		%%Picks one incorrect perpretrator and stires it in list P1%%
					    Results2=lists:append(S1,P1),
					    io:format("Perpetrators set is ~p of which two Perpetrators are correct \n",[Results2]),	%%Displays the set of three perpretrators of which two are correct.%%
					    {ok, [X]} = io:fread("Enter your Guess now:", "~c"),					%%Promts the player to enter his guess for another actual perpretrator%%
						case list_to_atom(X) =:= hd(S2) of							%%Check if the player's guess is corretc or not%%
							true ->	startGame(ActualGameset);						%%Announces player as the winner if the guess is correct%%
							false ->startGame(ActualGameset,Playerset,(Count+1),2)				%%asks for another player to enter his guess%%
						end.
startGame(ActualGameset)->
		io:format("Player won the Game, Actual Perpetrators are: ~p",[ActualGameset]).	%% Announces that the player won the game and displays the actual set of perpretrators.