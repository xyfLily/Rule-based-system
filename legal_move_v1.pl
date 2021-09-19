% :- [readin].
:-dynamic node/4, information/1.
node(1, residence(mary, manchester), initial_fact,[]).
node(2, residence(karl, manchester), initial_fact,[]).
node(3, tier1(manchester), initial_fact, []).

question(1, "Why?").
question(2, "Why not?").
question(3, "Do you agree?").
question(4, "Exit").

rule(1,[residence(X, Y), residence(A, B), indoor_meetings_allowed(Y), indoor_meetings_allowed(B)],can_meet_indoors(X, A)).
rule(2,[tier1(X)], indoor_meetings_allowed(X)).


deduce(Q, node(ID, Q, R , DAG)):-
   node(ID, Q, R , DAG).
deduce(Q, node(ID, Q, R , DAG)):-
   rule(ID_r, A, B),
   check_antecedants(A, NodeList),
   \+ node(_ID, B, _ID_r, _NodeList),!,
    countNumbers(Numbers),
    ID_n is Numbers +1,
    assert(node(ID_n,B,ID_r,NodeList)),
    deduce(Q, node(ID, Q, R, DAG)).
 
countNumbers(Numbers) :-
  aggregate_all(count, node(_,_,_,_), Numbers).

 
check_antecedants([],[]).
check_antecedants([H|T], [node(ID, H, R, DAG)|NodeList]):-
    node(ID, H, R , DAG),
    check_antecedants(T, NodeList).


why(F):-
    node(_N, F, initial_fact, _NL), !,
    write("Because it is an initial fact"), nl.
why(F):-
    node(_N, F, R, NL), !,
    rule(R, _A, F),
    write("Fact "),
    write(F),
    write(" is deduced using rule "),
    write(R),
    write(" from "),
    write(NL),nl.


% Legal move 4. 
whynot(F):-
	deduce(F,_DAG), !,
	node(_N, F, _, _), !,
	write("user: Why not "), 
	write(F),
	write(" ?"),nl,
	why(F).

% legal move 5. 
whynot(F):-
	deduce(F,_DAG), !,
	why(F).

% legal move 6. 
whynot(F):-
	\+ node(_N, F, initial_fact, _NL), !,
	write(F),
	write(" is not an initial fact"),nl.

% leagal move 7. 
whynot(F):-
	node(_N, F, initial_fact, _NL), !,
	write(F),
	write(" is an initial fact").

% leagel move 8. 
whynot(F):-
	rule(R, A, F),
    check(A, N),
	write(N), write(" cannot be deduced."), nl.


check([],[]).
check([H|T], [H|N]):-
    \+ deduce(H, _DAG),!, 
    check(T, N).
check([H|T], N):-
    deduce(H,_DAG),!,
    check(T,N).



read_question(Number) :-
    repeat,
    write('Please select a question or exit:'), nl,
    write_question_list,
    print_prompt(user),
    prompt(_, ''),
    read(Number),
    (   question(Number, QName)
    ->  write('You selected question: '), write(Number), write('. '), write(QName),nl, !
       % write('Enter the fact related to this question: '), read(Fact),nl, !
    ;   write('Not a valid choice, try again...'), nl, fail
    ).

write_question_list :-
    question(N, Name),
    write(N), write('. '), write(Name), nl,
    fail.
write_question_list.


write_node_list :-
    write('FACT:'),nl,
    node(N, Fact, initial_fact, []),
    write(N), write('. '), write(Fact), write(' is an initial fact'),nl,
    fail.
write_node_list.


write_rule_list :-
    write('RULE:'),nl,
    rule(N, Antecedants, C),
    write(N), write('. If '), write(Antecedants), write(' are satisfied then '), write(C), write(' is true'), nl,
    fail.
write_rule_list.



chat:-
	write_node_list,!,
        write_rule_list,!,
        print_welcome,
        conversations.

print_welcome:-
      %  write('Please enter the fact that you want to check'),nl,
      %  print_prompt(user),
        print_prompt(bot),
        read(F),nl,
        deduce(F,node(ID, F, R, DAG)),
        print_prompt(bot),
        write(F), write(' is true.'),nl,
        flush_output.

conversations:-
        repeat,
        read_question(Number),
        print_prompt(bot),
        % why(Fact).
        gen_reply(Number),
        (Number = 4, !; fail
        ).
 

print_prompt(bot):-
        my_icon(X), write(X), write(': '), flush_output.
print_prompt(user):-
        user_icon(X), write(X), write(': '), flush_output.
my_icon('Computer ').
user_icon('User').


gen_reply(1):-
        write('Please enter the fact related to this question: '), nl,
        print_prompt(user),
        read(Fact),nl, !,
        print_prompt(bot),
        why(Fact),nl.

gen_reply(4):-
        write("Bye"),nl,
        flush_output.


subset([], _).
subset([H|T], L2):-
        member(H, L2),
        subset(T, L2).
