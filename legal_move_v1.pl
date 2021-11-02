:- [deduce_backwards],[why_question],[whynot_question],[write_list].
:-dynamic node/4, user_fact/2, not_believe/1, believe/1, user_rule/3, different/1.


fact(1, "Yes, it is a initial fact").
fact(2, "No, I need some explanations about this fact").

choice(1, "Yes, I am satisfied. Exit.").
choice(2, "No, I need more explanations.").

reason(1, "Because of a rule.").
reason(2, "It's an initial fact.").


answer(1, "A fact").
answer(3, "Exit").

% start the conversations

chat:-
    write_node_list,!,
    write_rule_list,!,
    print_welcome,
    conversations.


print_welcome:-
    write("Computer: What do you want to know?"), nl,
    print_prompt(user),
    read(F),
    (
        deduce_backwards(F,node(_ID, F, _R, _DAG))
        -> print_prompt(bot),write(F), write(' is true.'), nl, ! ,
        read_agree, !,
        why_question(F)
    ;                                 % legal move 4: some t ∈ Gi ∪ Nij the player may ask whynot(t)
       print_prompt(bot),write(F), write(' is false.'), nl,!,
       read_agree, !,
       whynot_question(F),!
       ).

conversations:-
    repeat,
    read_agree,  
    write("Computer: What do you want to know?"), nl,
    read_answer(_N),
    different(_),!,halt.
 
print_prompt(bot):-
        my_icon(X), write(X), write(': '), flush_output.
print_prompt(user):-
        user_icon(X), write(X), write(': '), flush_output.
my_icon('Computer ').
user_icon('User').





read_agree :-
    write("Computer: Are you satisfied with the results? or you require additional explanations"),nl,
    write_choice_list,
    print_prompt(user),
    prompt(_, ''),
    read(Nanswer),
    (   Nanswer =:= 1
    ->  print_prompt(bot), write('Bye'),nl,!, halt
    ;   Nanswer =:= 2
    ->  print_prompt(bot), write('Okay, let us move on.'),nl,!
    ;   write('Not a valid choice, try again...'), nl
    ).


read_answer(Nanswer) :-
    write_answer_list,
    print_prompt(user),
    prompt(_, ''),
    read(Nanswer),
    (   Nanswer =:= 3
    ->  print_prompt(bot), write('Bye'),nl,!, halt
    ;    Nanswer =:= 2
    ->  print_prompt(bot), write("Please enter the conclusion: "),nl,!
     ;   Nanswer =:= 1
    ->  print_prompt(bot), write("Please enter the antecedant: "),nl,!
    ;   write('Not a valid choice, try again...'), nl
    ),
    print_prompt(user),
    read(F),
    (
        deduce_backwards(F,node(_ID, F, _R, _DAG))
        -> print_prompt(bot),write(F), write(' is true.'), nl, ! ,
        read_agree, !,
        why_question(F),!
    ;                                 % legal move 4: some t ∈ Gi ∪ Nij the player may ask whynot(t)
       print_prompt(bot),write(F), write(' is false.'), nl,!,
       read_agree, !,
       whynot_question(F),!
       ).







