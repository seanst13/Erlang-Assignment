% AC41011 - Big Data Analysis - Erlang Assingment - Parts 1 and 2
% Sean Stewart - 140009213

-module (coursework).
-export ([pi/0,pi/3,uniqueList/0,uniqueList/2, importFile/1 ]).

%Part One: Calculate Pi
	pi() -> 4 * pi(0,1,1).

	pi(InitialValue,Multiplier,Divisor) ->
	    Answer = 1 / Divisor,
	% If Answer is Greater than 6 Decicimal Places,
	% Recursively call the function until it is smaller and then return the result. 
	% I.e 4 * (1/1 + 1/3 - 1/5 + 1/7 - 1/9 ... etc.) 
		case Answer > 0.000001 of
			true -> pi(InitialValue+(Multiplier*Answer), Multiplier*-1, Divisor+2);
			false -> InitialValue        
	    end. 

%Part 2: Display Unique Items
	uniqueList() -> uniqueList([2,5,3,6,3,2,7,8,5,6],[]).
	uniqueList([Head|Tail], List) ->    
		L = List ++ [Head],
		uniqueList([X||X <-Tail, X/= Head], L);
	uniqueList([], L = [_|_]) -> 
		io:format("~n This list has unique elements: ~p~n", [L]),
		io:format("~n Total unique elements: ~p ~n", [length(L)]).

% Part 2 Bonus: Displaying Unique Words in a Text File: 
	importFile(FileName)->
		{ok, List} = file:read_file(FileName),
		L=binary_to_list(List),
		% Convert text into lowercase and filter out all additional characters. 
	   	Y = string:tokens(string:to_lower(L),"\r\n \\,!?;.[]:()*#$/\\<>&+@%=~~{}^£_\"1234567890"),
	   	io:format("Read ~p words~n", [length(Y)]),
		uniqueList(Y,[]).