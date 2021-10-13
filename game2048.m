%runs the game function
play_game

%PLAY_GAME: runs the game function in GUI view, waits for inputs and
%contains processing functions
function play_game(src,event)
global game_score %global variable containing the game score
global game_over %global variable containing the state of the game (0 for running, 1 for loss, 2 for win)
global grid %global variable containing the 4x4 game grid with empty and filled numbers in the matrix
clf %clears the GUI figure before each instance of function
game_score=0; %initialises game_score as 0
game_over=0; %initialises game_over as 0 (running)
grid=zeros(4,4); %initialises empty grid
grid=initial(grid); %inputs the first two numbers into empty grid - see function initial() for more

%Reads the audiofiles for the background music and the swiping sound
[bg_music, music_samplerate] = audioread('lofi_bg_music.mp3');
music_full = [bg_music; bg_music; bg_music; bg_music; bg_music; bg_music]; %Concatenates the background music so that it's also long enough for a longer game.
sound(music_full, music_samplerate);
[swipe_sound, swipe_samplerate] = audioread('swipe.mp3');

%Runs the following if and only if game_over condition is 0 (i.e. running)
while game_over==0
    game_area=uipanel; %Creates a panel container for the ui-grid to be placed in
    Welcome = uicontrol('Style','text','String','Welcome to our Game of 2048. Press Start and use the arrow keys to navigate.','FontSize', 12, 'FontName', 'Bahnschrift','Position',[20,315,160,80]); % Places Welcome text
    Restart = uicontrol('Style','pushbutton','String','Restart Game','FontSize', 12, 'FontName', 'Bahnschrift','Position',[40,170,120,60],'BackgroundColor','white', 'Callback',@play_game); % Places Restart Button that calls the main game function
    Stop = uicontrol('Style','pushbutton','String','Stop','FontSize', 12, 'FontName', 'Bahnschrift','Position',[40,90,120,60],'BackgroundColor','white','Callback',@end_game); % Places Stop Button that calls the endgame function
    Score = uicontrol('Style','text','String',['Score: ',num2str(game_score)],'FontSize', 12, 'FontName', 'Bahnschrift','Position',[40,265,120,20]); % Places text with updated score for each iteration
    % Iterates through grid to place the all uicontrol elements
    for i = 1:4
        for j = 1:4
            if grid(i,j)>0 % Checks if number is positive to hide the zeros
            number=grid(i,j); % Sets number to value of grid
            else
                number=[]; % Sets number to empty
            end
            font_colour='w'; % Sets standard font color to white
            switch grid(i,j) % Adds the official colours from 2048 and changes font color to black in case of 2 and 4
                case 0
                    tile_colour='#bbada0';
                case 2
                    tile_colour='#eee4da';
                    font_colour='k';
                case 4
                    tile_colour='#ece0c8';
                    font_colour='k';
                case 8
                    tile_colour='#f2b179';
                case 16
                    tile_colour='#f59564';
                case 32
                    tile_colour='#f57c5f';
                case 64
                    tile_colour='#f75d3a';
                case 128
                    tile_colour='#eccf72';
                case 256
                    tile_colour='#edcc61';
                case 512
                    tile_colour='#ecc850';
                case 1024
                    tile_colour='#edc53f';
                case 2048
                    tile_colour='#eec22e';
                otherwise
                    tile_colour='#3d3a33';
            end
            % Given Matlab doesn't allow to vertically center text, we create two uicontrol objects. One for the background and one for the number in the foreground.
            % They are arranged based on their position in grid
            background_tile = uicontrol(game_area,'Style','text','String', '','Position', [100+80*j,400-80*i,75,75],'BackgroundColor',tile_colour);
            number_tile = uicontrol(game_area,'Style','text','String', number, 'ForegroundColor', font_colour,'FontSize', 18, 'FontName', 'Bahnschrift', 'Position',[100+80*j,400-80*i,75,55],'BackgroundColor',tile_colour);
        end
    end
    
    waitforbuttonpress; %Waits for button input
    key=double(get(gcf,'CurrentCharacter')); %Records button input as an ASCII character to variable key
    %Double value for up arrow is 30, left 28, right 29, down 31
    %Runs the specific command for each type of arrow key, does not do
    %anything when input is unexpected
    switch key
        case 30 %in case of up key does the following
            [grid,add_score]=up(grid); %performs the grid manipulation function and stores the delta score to a variable
            game_score=game_score+add_score; %adds the delta score to global variable game_score that contains the game scoree
            sound(swipe_sound, swipe_samplerate); %Plays the swipe sound when a move is made.
            game_over=game_over_check(grid); %checks if grid meets any of the game over conditions
        case 28 
            [grid,add_score]=left(grid);
            game_score=game_score+add_score;
            sound(swipe_sound, swipe_samplerate);
            game_over=game_over_check(grid);
        case 29
            [grid,add_score]=right(grid);
            game_score=game_score+add_score;
            sound(swipe_sound, swipe_samplerate);
            game_over=game_over_check(grid);
        case 31
            [grid,add_score]=down(grid);
            game_score=game_score+add_score;
            sound(swipe_sound, swipe_samplerate);
            game_over=game_over_check(grid);  
        otherwise %Condition for key press being equal to anything other than arrows
            grid=grid;
    end
    delete(game_area) % Deletes the uipanel game_area to clear the figure while not breaking the buttons
    
end
end_game; % Calls end_game once the game is over
end


function end_game(src,event)
%END_GAME This function is called once the game is over. It then plays
%sounds and prints text based on whether the player won or lost, using the 
%global game_over and game_score variables.
global game_over;
global game_score;
clf;
clear sound; %Clears the sound, so that the background music doesn't overlap with the final sound.
if (game_over == 1)%This if-elseif statement checks whether the user has won or lost the game. In the game_over_check function, losing is defined as game_over = 1 and winning is defined as game_over = 2. 
    %When the user loses, a sad sound is played and the score is printed.
    [song, samplerate] = audioread('game-over.wav');
    sound(song, samplerate);
    End_screen = uicontrol('Style','text','String',['Game Over. You lost, but you still scored: ', num2str(game_score), ' points. Well done!'],'FontSize', 35,'ForegroundColor', 'w', 'FontName', 'Bahnschrift','Position',[60,60,400,300],'BackgroundColor','#f59564');
elseif (game_over == 2)
    %When the user wins, a winning fanfare is played and the score is printed.
    End_screen = uicontrol('Style','text','String',['Game Over. You won! You scored: ', num2str(game_score), ' points. Well done!'],'FontSize', 35,'ForegroundColor', 'w', 'FontName', 'Bahnschrift','Position',[60,60,400,300],'BackgroundColor','#f59564');
    [song, samplerate] = audioread('winning.wav');
    sound(song, samplerate);
end
    game_score=0;
    %The user then has the chance to restart the game.
    Retry = uicontrol('Style','pushbutton','String','Try again!','FontSize', 12, 'FontName', 'Bahnschrift','Position',[200,80,120,60],'BackgroundColor','white', 'Callback', @play_game);
end

function quit(src,event) % Function definition. src and event are used because this function is called by a button
close % Closes all opened functions
end

function [grid]=initial(grid)
%INITIAL This functions generates the initial 2 positions on the grid
%Input grid (matrix)
%Output grid(matrix)
%generates two random positions on the grid
    pos_1=randi(16);
    pos_2=randi(16);
    %condition for generating two unique positions
    while pos_1==pos_2
        pos_1=randi(16);
        pos_2=randi(16);
    end
    %creates array of random positions
    positions=[pos_1 pos_2];
    %loops in the position array elements
    for x=1:2
        %generates a random number from 0 -> 1
        chance=rand();
        % 90% of the time it sets the value of random grid position to 2
        if chance<0.9
            grid(positions(x))=2;
        else
            % 10% of the time it sets value of random grid positions to 4
            grid(positions(x))=4;
        end
    end
end

function [grid]=new(grid)
    pos=randi(16);
        while grid(pos)~=0
            pos=randi(16);
        end
    chance=rand();
    if chance<0.5
        grid(pos)=2;
    else
        grid(pos)=4;
    end
end

function [grid]=shift(grid)
    empty_mat=zeros(4,4);
    for x=1:4
        non_empty=1;
        for y=1:4
            if grid(x,y)~=0
                empty_mat(x,non_empty)=grid(x,y);
                non_empty=non_empty+1;
            end
        end
    end
    grid=empty_mat; % because mo wants it this way
end

function [grid,score]=add(grid)
    score=0;
    for x=1:4
        for y=1:3
            if grid(x,y)~=0 && (grid(x,y)==grid(x,y+1))
                grid(x,y)=2.*grid(x,y);
                grid(x,y+1)=0;
                score=grid(x,y)+score;
            end
        end
    end
end

function [grid_left,add_score]=left(grid)
    [grid_left,temp_game_score]=add(shift(grid));
    grid_left=shift(grid_left);
    if isequal(grid_left,grid)==false
        grid_left=new(grid_left);
        add_score=temp_game_score;
    else
        grid_left=grid;
        add_score=0;
    end
end

function [grid_down,add_score]=down(grid)
    [grid_down,temp_game_score]=add(shift(fliplr(transpose(grid))));
    grid_down=transpose(fliplr(shift(grid_down)));
    if isequal(grid_down,grid)==false
        grid_down=new(grid_down);
        add_score=temp_game_score;
    else
        grid_down=grid;
        add_score=0;
    end
end

function [grid_right,add_score]=right(grid)
    [grid_right,temp_game_score]=add(shift(fliplr(grid)));
    grid_right=fliplr(shift(grid_right));
    if isequal(grid_right,grid)==false
        grid_right=new(grid_right);
        add_score=temp_game_score;
    else
        grid_right=grid;
        add_score=0;
    end
end

function [grid_up,add_score]=up(grid)
    [grid_up,temp_game_score]=add(shift(transpose(grid)));
    grid_up=transpose(shift(grid_up));
    if isequal(grid_up,grid)==false
        grid_up=new(grid_up);
        add_score=temp_game_score;
    else
        grid_up=grid;
        add_score=0;
    end
end

function [game_over]=game_over_check(grid)
%GAME_OVER This function is called every time a move is made, to check
%whether the game is over. When it is over, the game_over value is changed,
%so that the while loop in the play_game function won't run again.
    global game_over;
    if isequal(grid,up(grid),down(grid),left(grid),right(grid))
        %When all moves would result in an equal grid, that means that 
        %there are no useful moves left, so the user lost. Therefore,
        %game_over is set to 1.
        game_over=1;
    elseif ismember(2048, grid)
        %When the grid contains 2048, the user wins, so game over is set to
        %2.
        game_over=2;
    else
        game_over=0;
    end
end
