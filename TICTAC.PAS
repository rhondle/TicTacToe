uses dos, crt;
label top, quit;

const
grid:array[1..25] of char=('1','³','2','³','3','Ä','Å','Ä','Å','Ä','4','³','5','³','6','Ä','Å','Ä','Å','Ä','7','³','8','³','9');
Torg:array[1..11] of byte=(4,12,6,14,10,11,3,9,1,5,13);
tack:array[1..11] of char=('T','I','C','-','T','A','C','-','T','A','C');

var
data:array[1..9] of char;
x,y,i,n,turns,logik,logik2,comp1,goob,thing:integer;
mark:char;
player, won, easy:boolean;
input:char;
s1:string;
check:boolean;
gurp:pointer;

procedure cursoroff; assembler;
asm
    mov ah,1
    mov ch,-4
    mov cl,-4
    int 10h
end;

procedure cursoron; assembler;
asm
    mov ah,1
    mov ch,6
    mov cl,7
    int 10h
end;

procedure writexy(x,y:integer;ch:char);
begin
    gotoxy(x,y);
    write(ch);
end;

procedure colorwrite(s:string);
var

begin
    b:=9;
    for i:=1 to length(s) do
    begin
        textcolor(b);
        inc(b);
        if b>15 then b:=9;
        write(s[i]);
    end;
end;

procedure centr(row:integer;s:string);
begin
    gotoxy(40-length(s) div 2,row);
end;

procedure center(row:integer;s:string);
begin
    gotoxy(40-length(s) div 2,row);
    writeln(s);
end;

procedure flashy; interrupt;
var
i,narfo:integer;
flange:word;
begin
    if thing=6 then
    begin
        flange:=textattr;
        gotoxy(30,4);
        for i:= 0 to 10 do
        begin
            narfo:=goob+i;
            if narfo>11 then narfo:=narfo-11;
            textcolor(torg[narfo]);
            write(tack[i+1],' ');
        end;
        inc(goob);
        if goob=12 then goob:=1;
        textattr:=flange;
        thing:=0;
    end;
    inc(thing);
    port[$20]:=$20;
end;


begin
    cursoroff;
    goob:=1;
    thing:=6;
    easy:=false;
    
    if paramcount>0 then
    begin
        s1:=paramstr(1);
        for i:=1 to length(s1) do
        s1[i]:=upcase(s1[i]);
        if (s1[1]='-') or (s1[1]='/') then
        begin
            if copy(s1,2,length(s1)-1)='EASY' then
            easy:=true;
        end;
    end;
    
    top:
    textcolor(7);
    textbackground(0);
    clrscr;
    getintvec(8,gurp);
    setintvec(8,@flashy);
    textcolor(9);
    i:=random(99);
    if i<50 then
    center(5,'By Marty Anstey & Alastair Brockwell')
    else
    center(5,'By Alastair Brockwell & Marty Anstey');
    textcolor(3);
    center(7,'Version 2.5');
    textcolor(7);
    gotoxy(1,1);
    
    i:=1;
    for x:=1 to 5 do
    begin
        for y:=1 to 5 do
        begin
            write(grid[i]);
            inc(i);
        end;
        writeln;
    end;
    
    for i:=1 to 9 do
    data[i]:=' ';         { clear board }
    
    i:=random(9);
    if i<5 then
    player:=false
    else player:=true;    { player goes first }
    won:=false;           { nobody's won yet! }
    turns:=0;             { 0 turns played    }
    
    gotoxy(80-4,11);
    if easy then
    begin
        textcolor(14);
        center(3,'EASY');
    end;
    
    textcolor(7);
    
    {==[ Main Loop ]=============================================================}
    
    
    repeat
        inc(turns);
        
        if player then        { human }
        begin
            textcolor(10);
            gotoxy(1,11);
            writeln('Your turn');
            repeat
                textcolor(7);
                gotoxy(1,10);
                write('Select a square: ');
                gotoxy(18,10);
                input:=readkey;
                if input=#27 then goto quit;
                val(input,i,x);
                if x<>0 then
                begin
                    gotoxy(1,12);
                    writeln('Please select a square numbered 1 thru 9, ESC quits.');
                end;
                
            until (x=0) and (data[i]=' ');
            gotoxy(18,10);
            write(input);
            mark:='O';
            textcolor(10);
            gotoxy(1,11);
            writeln('                  ');
            if (turns=1) or (turns=2) then logik:=i;
            if (turns=3) or (turns=4) then logik2:=i;
        end;
        
        if not player then    { computer }
        begin
            mark:='X';
            textcolor(12);
            gotoxy(1,11);
            writeln('Thinking...           ');
            
            for n:=1 to 600+random(1000) do
            randomize;
            repeat
                i:=random(9);
                inc(i);
                
                {============================================================================}
                if easy then
                begin
                    if turns=1 then
                    begin
                        i:=random(50);                   { get a random number           }
                        inc(i);                          { fixup to eliminate 0          }
                        if i<30 then i:=5 else           { good chance start on center square    }
                        begin
                            i:=random(9);                { otherwise, select a random    }
                            inc(i);                      { square (also 1 in 9 chance    }
                        end;                             { of landing on center square!) }
                    end;
                end;
                
                if not easy then
                begin
                    if turns=1 then i:=1;
                    if turns=3 then
                    begin
                        if (logik=5) or (logik=7) then i:=9;
                        if (logik>7) or (logik<4) or (logik=6) then i:=7;
                        if logik=4 then i:=3;
                    end;
                    if turns=5 then
                    begin
                        check:=false;
                        if (logik=5) and (logik2<>3) and not check then
                        begin
                            i:=3;
                            check:=true;
                        end
                        else if not check then
                        i:=7;
                        if (logik>6) and (logik2<>3) and not check then
                        begin
                            i:=3;
                            check:=true;
                        end
                        else if not check then
                        i:=4;
                        if (logik<5) and (logik2<>9) and not check then
                        begin
                            i:=9;
                            check:=true;
                        end
                        else if not check then
                        i:=4;
                        if (logik=6) and (logik2<>5) and not check then
                        begin
                            i:=5;
                            check:=true;
                        end
                        else if not check then
                        i:=4;
                    end;
                end;
                
                {==[ Defensive ]=============================================================}
                
                if data[i]=' ' then
                begin
                    if (data[1]='O') and (data[2]='O') and (data[3]=' ') then i:=3
                    else
                    if (data[4]='O') and (data[5]='O') and (data[6]=' ') then i:=6
                    else
                    if (data[7]='O') and (data[8]='O') and (data[9]=' ') then i:=9
                    else
                    if (data[1]='O') and (data[2]=' ') and (data[3]='O') then i:=2
                    else
                    if (data[4]='O') and (data[5]=' ') and (data[6]='O') then i:=5
                    else
                    if (data[7]='O') and (data[8]=' ') and (data[9]='O') then i:=8
                    else
                    if (data[1]=' ') and (data[2]='O') and (data[3]='O') then i:=1
                    else
                    if (data[4]=' ') and (data[5]='O') and (data[6]='O') then i:=4
                    else
                    if (data[7]=' ') and (data[8]='O') and (data[9]='O') then i:=7
                    else
                    
                    if (data[1]='O') and (data[4]='O') and (data[7]=' ') then i:=7
                    else
                    if (data[1]='O') and (data[4]=' ') and (data[7]='O') then i:=4
                    else
                    if (data[1]=' ') and (data[4]='O') and (data[7]='O') then i:=1
                    else
                    if (data[2]='O') and (data[5]='O') and (data[8]=' ') then i:=8
                    else
                    if (data[2]='O') and (data[5]=' ') and (data[8]='O') then i:=5
                    else
                    if (data[2]=' ') and (data[5]='O') and (data[8]='O') then i:=2
                    else
                    if (data[3]='O') and (data[6]='O') and (data[9]=' ') then i:=9
                    else
                    if (data[3]='O') and (data[6]=' ') and (data[9]='O') then i:=6
                    else
                    if (data[3]=' ') and (data[6]='O') and (data[9]='O') then i:=3
                    
                    else
                    if (data[1]='O') and (data[5]='O') and (data[9]=' ') then i:=9
                    else
                    if (data[1]='O') and (data[5]=' ') and (data[9]='O') then i:=5
                    else
                    if (data[1]=' ') and (data[5]='O') and (data[9]='O') then i:=1
                    else
                    if (data[3]='O') and (data[5]='O') and (data[7]=' ') then i:=7
                    else
                    if (data[3]='O') and (data[5]=' ') and (data[7]='O') then i:=5
                    else
                    if (data[3]=' ') and (data[5]='O') and (data[7]='O') then i:=3;
                    
                    {==[ Logic ]=================================================================}
                    
                    if not easy then
                    begin
                        
                        if turns=2 then
                        begin
                            if logik=5 then i:=1 else
                            i:=5;
                        end;
                        
                        if turns=4 then
                        begin
                            { needs cleaning up }
                            if logik=5 then
                            begin
                                if logik2=9 then i:=7;
                            end;
                            if logik=1 then
                            begin
                                if logik2=9 then i:=2;
                            end;
                            if logik=3 then
                            begin
                                if logik2=7 then i:=4;
                            end;
                            if logik=7 then
                            begin
                                if logik2=3 then i:=6;
                            end;
                            if logik=9 then
                            begin
                                if logik2=1 then i:=8;
                            end;
                            if (logik=2) and (logik2=6) then i:=3;
                            if (logik=2) and (logik2=4) then i:=1;
                            if (logik=4) and (logik2=2) then i:=1;
                            if (logik=4) and (logik2=8) then i:=7;
                            if (logik=6) and (logik2=2) then i:=3;
                            if (logik=6) and (logik2=8) then i:=9;
                            if (logik=8) and (logik2=6) then i:=9;
                            if (logik=8) and (logik2=4) then i:=7;
                        end;
                        
                    end;
                    
                    
                    {==[ Offsensive ]============================================================}
                    
                    if (data[1]='X') and (data[2]='X') and (data[3]=' ') then i:=3
                    else
                    if (data[4]='X') and (data[5]='X') and (data[6]=' ') then i:=6
                    else
                    if (data[7]='X') and (data[8]='X') and (data[9]=' ') then i:=9
                    else
                    if (data[1]='X') and (data[2]=' ') and (data[3]='X') then i:=2
                    else
                    if (data[4]='X') and (data[5]=' ') and (data[6]='X') then i:=5
                    else
                    if (data[7]='X') and (data[8]=' ') and (data[9]='X') then i:=8
                    else
                    if (data[1]=' ') and (data[2]='X') and (data[3]='X') then i:=1
                    else
                    if (data[4]=' ') and (data[5]='X') and (data[6]='X') then i:=4
                    else
                    if (data[7]=' ') and (data[8]='X') and (data[9]='X') then i:=7
                    else
                    
                    if (data[1]='X') and (data[4]='X') and (data[7]=' ') then i:=7
                    else
                    if (data[1]='X') and (data[4]=' ') and (data[7]='X') then i:=4
                    else
                    if (data[1]=' ') and (data[4]='X') and (data[7]='X') then i:=1
                    else
                    if (data[2]='X') and (data[5]='X') and (data[8]=' ') then i:=8
                    else
                    if (data[2]='X') and (data[5]=' ') and (data[8]='X') then i:=5
                    else
                    if (data[2]=' ') and (data[5]='X') and (data[8]='X') then i:=2
                    else
                    if (data[3]='X') and (data[6]='X') and (data[9]=' ') then i:=9
                    else
                    if (data[3]='X') and (data[6]=' ') and (data[9]='X') then i:=6
                    else
                    if (data[3]=' ') and (data[6]='X') and (data[9]='X') then i:=3
                    
                    else
                    if (data[1]='X') and (data[5]='X') and (data[9]=' ') then i:=9
                    else
                    if (data[1]='X') and (data[5]=' ') and (data[9]='X') then i:=5
                    else
                    if (data[1]=' ') and (data[5]='X') and (data[9]='X') then i:=1
                    else
                    if (data[3]='X') and (data[5]='X') and (data[7]=' ') then i:=7
                    else
                    if (data[3]='X') and (data[5]=' ') and (data[7]='X') then i:=5
                    else
                    if (data[3]=' ') and (data[5]='X') and (data[7]='X') then i:=3;
                    
                    gotoxy(1,11);
                    writeln('                  ');
                end;
                
            until data[i]=' ';
        end;
        
        {==[ Update the board ]======================================================}
        
        if data[i]=' ' then
        begin
            data[i]:=mark;
            if i=1 then writexy(1,1,mark);
            if i=2 then writexy(3,1,mark);
            if i=3 then writexy(5,1,mark);
            if i=4 then writexy(1,3,mark);
            if i=5 then writexy(3,3,mark);
            if i=6 then writexy(5,3,mark);
            if i=7 then writexy(1,5,mark);
            if i=8 then writexy(3,5,mark);
            if i=9 then writexy(5,5,mark);
            player:=not player;
        end;
        
        {==[ Has someone won? ]======================================================}
        
        if (data[1]=mark) and (data[2]=mark) and (data[3]=mark) or
        (data[4]=mark) and (data[5]=mark) and (data[6]=mark) or
        (data[7]=mark) and (data[8]=mark) and (data[9]=mark) or
        (data[1]=mark) and (data[4]=mark) and (data[7]=mark) or
        (data[2]=mark) and (data[5]=mark) and (data[8]=mark) or
        (data[3]=mark) and (data[6]=mark) and (data[9]=mark) or
        (data[1]=mark) and (data[5]=mark) and (data[9]=mark) or
        (data[7]=mark) and (data[5]=mark) and (data[3]=mark)
        then
        begin
            gotoxy(1,9);
            if mark='O' then
            writeln('Player wins!');
            if mark='X' then
            writeln('Computer wins!');
            won:=true;
        end;
        
        if (turns>8) and (won=false) then
        begin
            textcolor(15);
            gotoxy(1,9);
            writeln('Draw');
            won:=true;
        end;
        
    until (won=true);
    
    gotoxy(1,12);
    write('Play again? [Y/N]');
    
    repeat
        input:=readkey;
        input:=upcase(input);
    until (input='Y') or (input='N');
    
    if input='Y' then goto top;
    
    quit:
    setintvec(8,gurp);
    cursoron;
    clrscr;
    textcolor(15);
    center(2,'T I C - T A C - T O E');
    textcolor(9);
    i:=random(99);
    if i<50 then
    center(4,'By Marty Anstey & Alastair Brockwell')
    else
    center(4,'By Alastair Brockwell & Marty Anstey');
    textcolor(7);
    center(7,'Improved version featuring true game logic,');
    center(8,'beating it is impossible!');
    center(10,'It''s free, it''s fun, and if you want to say hi to');
    center(11,'the programmers, leave us email at redacted@example.com');
    textcolor(7);
    gotoxy(1,15);
end.
