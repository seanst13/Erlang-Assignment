% AC41011 - Big Data Analysis - Erlang Assingment - Parts 3
% Sean Stewart - 140009213

-module (concharcount).
-export ([load/1,count/3,go/2,join/2,split/2, countsplit/3, rgoLetters/2, rgo/3, waitForRGO/3, sort/1]).

% Imports the file and calls the required functions for calling the word count recursively. 
% Displays the final result. 
load(File)->
    {ok, Bin} = file:read_file(File),
    List = binary_to_list(Bin),
    RoundedLength = round(length(List)/20),
    LowerCase=string:lowercase(List),
    io:fwrite("Split Started ~n"),
    SplitList = split(LowerCase,RoundedLength),
    io:fwrite("split complete ~n"),
    Result = countsplit(SplitList,[], 0),
    io:format("Result: ~p ~n", [Result]).
% joins all the individual chunk tuples into one A-Z list
countsplit([], ResultList, 0) -> ResultList; 
countsplit([],ResultList, SpawnedProccesses)->
receive
    % Returns the list for each chunk and combines them. 
    {{NewResult}, Pid} ->
        io:fwrite("RECEIVED PROCESS FROM: ~p ~n", [Pid]),
        List = NewResult, 
        L = sort(List),     
        Result2=join(ResultList,L),
        io:fwrite("LIST SORTED AND ADDED ~n"),        
        countsplit([], Result2, SpawnedProccesses -1)         
    end;

% Spawns a process for each chunk of text. 
countsplit([H|T],ResultList, SpawnedProccesses)->
    PID = spawn(concharcount,go,[H, self()]),
    io:fwrite("GO PROCESS SPAWNED: ~p ~n", [PID]),
    countsplit(T, ResultList,SpawnedProccesses + 1).
%  Joins all the returned lists to the ifnal result.
join([],[])->[];
join([],R)->R;
join([H1|T1],[H2|T2])->
    {C,N}=H1,
    {C1,N1}=H2,
    [{C1,N+N1}]++join(T1,T2).

% Organises each returned list into alphabetical order 
sort([Pivot|T]) ->
    sort([ X || X <- T, X < Pivot]) ++
    [Pivot] ++
    sort([ X || X <- T, X >= Pivot]);
sort([]) -> [].


% divides the text into chunks
split([],_)->[];
split(List,Length)->
S1=string:substr(List,1,Length),
case length(List) > Length of
   true->S2=string:substr(List,Length+1,length(List));
   false->S2=[]
end,
[S1]++split(S2,Length).


% Calls the Letter Count Process and returns the combined results.
go(Chunk, ParentProcess)->
    Alph=[$a,$b,$c,$d,$e,$f,$g,$h,$i,$j,
        $k,$l,$m,$n,$o,$p,$q,$r,$s,$t,$u,$v,$w,$x,$y,$z],
    rgoLetters(Alph, Chunk),
    CombinedResult = waitForRGO([], self(), 0),
    io:fwrite("RESULT COMBINED FOR ~p ~n", [ParentProcess]),     
    ParentProcess ! {CombinedResult, ParentProcess}.

% Recursively calls itself until the list has receieved all 26 letters
waitForRGO(CombinedResult, ParentProcess, 26)->
ParentProcess ! {CombinedResult};
waitForRGO(CombinedResult, ParentProcess, SpawnedProccesses)->
receive
        {Result, Pid} ->
            io:fwrite("RECIEVED RGO PROCESS: ~p ~n", [Pid]),
            io:fwrite("RESULT.... ~p ~n", [Result]),
            NewResult = CombinedResult++[Result],
            waitForRGO(NewResult, ParentProcess, SpawnedProccesses+1)
end.    
    

% Spawn instances of RGO for each letter in the alphabet 
rgoLetters([], Chunk) -> [];
rgoLetters([Letter|T], Chunk) ->
    Pid = spawn(concharcount, rgo, [Letter, Chunk, self()]),
    io:fwrite("RGO PROCESS SPAWNED: ~p ~n", [Pid]),
    rgoLetters(T, Chunk).

% counts how many instances of each letter there are in a chunk of text 
%  and puts them in each corresponding tuple
rgo(H,Chunk, ParentProcess)->
    N=count(H,Chunk,0),
    Result = {[H],N},
    ParentProcess ! {Result, self()}.

% Counts the number of letters in a specific chunk
count(Char, [],N)->N;
count(Char, [H|T],N) ->
   case Char==H of
   true-> count(Char,T,N+1);
   false -> count(Char,T,N)
end.