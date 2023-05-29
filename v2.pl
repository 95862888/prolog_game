/* санитар -- a sample adventure game, by David Matuszek.
   Consult this file and issue the command:   start.  */

:- dynamic at/2, i_am_at/1, alive/1.   /* Needed by SWI-Prolog. */
:- retractall(at(_, _)), retractall(i_am_at(_)), retractall(alive(_)).

/* This defines my current location. */

i_am_at(палата).


/* These facts describe how the rooms are connected. */

path(санитар, d, cave).

path(cave, u, санитар).
path(cave, w, коридор).

path(коридор, e, cave).
path(коридор, s, палата).

path(палата, n, коридор) :- at(фонарик, in_hand).
path(палата, n, коридор) :-
        write('Идти по тёмному коридору без фонарика? Это глупая затея.'), nl,
        !, fail.
path(палата, s, кабинет).

path(кабинет, n, палата).
path(кабинет, w, cage).

path(cage, e, кабинет).

path(closet, w, кабинет).

path(кабинет, e, closet) :- at(ключик, in_hand).
path(кабинет, e, closet) :-
        write('Дверь заперта.'), nl,
        fail.


/* These facts tell where the various objects in the game
   are located. */

at(ключ, санитар).
at(ключик, коридор).
at(фонарик, кабинет).
at(см_рубашка, closet).


/* This fact specifies that the санитар is alive. */

alive(санитар).


/* These rules describe how to pick up an object. */

take(X) :-
        at(X, in_hand),
        write('Он уже у вас!'),
        nl, !.

take(X) :-
        i_am_at(Place),
        at(X, Place),
        retract(at(X, Place)),
        assert(at(X, in_hand)),
        write('OK.'),
        nl, !.

take(_) :-
        write('Не вижу его здесь.'),
        nl.


/* These rules describe how to put down an object. */

drop(X) :-
        at(X, in_hand),
        i_am_at(Place),
        retract(at(X, in_hand)),
        assert(at(X, Place)),
        write('OK.'),
        nl, !.

drop(_) :-
        write('Он уже у вас есть.'),
        nl.


/* These rules define the six direction letters as calls to go/1. */

n :- go(n).

s :- go(s).

e :- go(e).

w :- go(w).

u :- go(u).

d :- go(d).


/* This rule tells how to move in a given direction. */

go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, There),
        retract(i_am_at(Here)),
        assert(i_am_at(There)),
        look, !.

go(_) :-
        write('Вы не можете пойти сюда.').


/* This rule tells how to look about you. */

look :-
        i_am_at(Place),
        describe(Place),
        nl,
        notice_objects_at(Place),
        nl.


/* These rules set up a loop to mention all the objects
   in your vicinity. */

notice_objects_at(Place) :-
        at(X, Place),
        write('Здесь лежит '), write(X), write(' .'), nl,
        fail.

notice_objects_at(_).


/* These rules tell how to handle attacking the lion and the санитар. */

attack :-
        i_am_at(cage),
        write('Плохая идея! Опытный глав. врач моментально поймал вас!'), nl,
        !, die.

attack :-
        i_am_at(cave),
        write('Это не работает. Санитар'), nl,
        write('просто продолжает стоять на посту.').

attack :-
        i_am_at(санитар),
        at(см_рубашка, in_hand),
        retract(alive(санитар)),
        write('Вы прокрались за спину санитару и надели на него смирительую рубашку.'), nl,
        write('Он продолжает дёргаться, но уже не может помешать вам сбежать.'), nl,
        write('Вы надеваете его колпак. Теперь вы тут санитар.'),
        nl, !.

attack :-
        i_am_at(санитар),
        write('Попытки щекотать санитара ничего не дают.'), nl,
        write('Он всё ещё стоит на посту и не даст вам сбежать.'), nl.

attack :-
        write('Здесь только мягкие стены!.'), nl.


/* This rule tells how to die. */

die :-
        !, finish.


/* Under UNIX, the   halt.  command quits Prolog but does not
   remove the output window. On a PC, however, the window
   disappears before the final output can be seen. Hence this
   routine requests the user to perform the final  halt.  */

finish :-
        nl,
        write('Игра окончена. Напишите команду   halt.  '),
        nl, !.


/* This rule just writes out game instructions. */

instructions :-
        nl,
        write('Enter commands using standard Prolog syntax.'), nl,
        write('Available commands are:'), nl,
        write('start.                   -- to start the game.'), nl,
        write('n.  s.  e.  w.  u.  d.   -- to go in that direction.'), nl,
        write('take(Object).            -- to pick up an object.'), nl,
        write('drop(Object).            -- to put down an object.'), nl,
        write('attack.                  -- to attack an enemy.'), nl,
        write('look.                    -- to look around you again.'), nl,
        write('instructions.            -- to see this message again.'), nl,
        write('halt.                    -- to end the game and quit.'), nl,
        nl.


/* This rule prints out instructions and tells where you are. */

start :-
        instructions,
        look.


/* These rules describe the various rooms.  Depending on
   circumstances, a room may have more than one description. */

describe(палата) :-
        at(ключ, in_hand),
        write('Поздравляю!!  Вы достали ключ'), nl,
        write('Вы смогли сбежать из дурки!.'), nl,
        finish, !.

describe(палата) :-
        write('Вы в большой палате.  На севере тёмный длинный коридор.'), nl,
        write('На юге кабинет главного врача.  Ваша'), nl,
        write('задача добыть ключ от дверей палаты'), nl,
        write('принести его сюда, открыть дверь и сбежать'), nl,
        write('на свободу.'), nl.

describe(кабинет) :-
        write('Вы в маленьком кабинете.  Выход на севере.'), nl,
        write('На западе есть какая-то дверь, она кажется'), nl,
        write('незапертой.  На востоке есть дверь поменьше.'), nl.

describe(cage) :-
        write('Вы в кабинете главного врача! Он выглядит недовольным'), nl,
        write('и, кажется, хочет вас поймать. Надо бежать!'), nl.

describe(closet) :-
        write('Это просто старая кладовка.'), nl.

describe(коридор) :-
        write('Вы в другой палате.  Выход из неё на юге.'), nl,
        write('На восток ведёт длинный, тёмный и загадочный'), nl,
        write('коридор.'), nl.

describe(cave) :-
        alive(санитар),
        at(ключ, in_hand),
        write('Санитар видит вас с ключем в руках и ловит вас!'), nl,
        write('    ...Всё закончилось очень быстро....'), nl,
        die.

describe(cave) :-
        alive(санитар),
        write('Здесь стоит на посту санитар.'), nl,
        write('Возможно стоит по тихому уйти отсюда....'), nl, !.
describe(cave) :-
        write('Здесь лежит санитар в смирительной рубашке!'), nl.

describe(санитар) :-
        alive(санитар),
        write('Вы раскачиваетесь на люстре над головой санитара.'), nl,
        write('Не уверен, что это поможет вам сбжать.'), nl.

describe(санитар) :-
        write('Вы качаетесь на люстре на глазах связанного санитара!'), nl.
