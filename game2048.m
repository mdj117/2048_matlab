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

% grid=[1024 1024 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 0]
% grid=[4 2 4 2; 2 4 2 4; 4 2 4 2; 2 4 8 4]

%Reads the audiofiles for the background music and the swiping sound
[bg_music, music_samplerate] = audioread('lofi_bg_music.mp3');
sound(bg_music, music_samplerate);
[swipe_sound, swipe_samplerate] = audioread('swipe.mp3');
figure
%Runs the following if and only if game_over condition is 0 (i.e. running)
while game_over==0
    target_area=uipanel; %Creates a panel container for the ui-grid to be placed in
    %Title
    uicontrol(target_area,'Style','text','String','2048','FontSize', 30,'ForegroundColor', 'w','BackgroundColor', '#eec22e', 'FontName', 'Bahnschrift','Position',[120,360,135,50]); % Places Welcome text
    %Restart button
    uicontrol('Style','pushbutton','String','Restart Game','FontSize', 12,'ForegroundColor', 'w', 'FontName', 'Bahnschrift','Position',[260,362,135,50],'BackgroundColor','#f59564', 'Callback',@play_game); % Places Restart Button that calls the main game function
    %Stop button
    uicontrol('Style','pushbutton','String','Stop','FontSize', 12,'ForegroundColor', 'w', 'FontName', 'Bahnschrift','Position',[260,302,135,50],'BackgroundColor','#f59564','Callback',@end_game); % Places Stop Button that calls the endgame function
    %Score counter
    uicontrol(target_area,'Style','text','String',['Score: ',num2str(game_score)],'FontSize', 16,'ForegroundColor', 'w','BackgroundColor', '#bbada0', 'FontName', 'Bahnschrift','Position',[120,300,135,50]); % Places text with updated score for each iteration
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
            %Backgroundtile
            uicontrol(target_area,'Style','text','String', '','Position', [50+70*j,300-70*i,65,65],'BackgroundColor',tile_colour);
            %Numbertile
            uicontrol(target_area,'Style','text','String', number, 'ForegroundColor', font_colour,'FontSize', 18, 'FontName', 'Bahnschrift', 'Position',[50+70*j,300-70*i,65,50],'BackgroundColor',tile_colour);
        end
    end
    try %try statement to not show error
click=waitforbuttonpress; %Waits for button input
    if click==1
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
        end
    end
    catch %Does nothing if waitforbuttonpress is not successful
        
    end
    delete(target_area) % Deletes the uipanel game_area to clear the figure while not breaking the buttons
    
end
end_game; % Calls end_game once the game is over
end


function end_game(src,event)
%END_GAME is called once the game is over. It then plays
%sounds and prints text based on whether the player won or lost, using the 
%global game_over and game_score variables.
global game_over;
global game_score;
clf;
clear sound; %Clears the sound, so that the background music doesn't overlap with the final sound.
%Endscreen
uicontrol('Style','text','String',['Game Over. You scored: ', num2str(game_score), ' points. Well done!'],'FontSize', 35,'ForegroundColor', 'w', 'FontName', 'Bahnschrift','Position',[60,60,400,320],'BackgroundColor','#bbada0');

if game_over == 1 %This if-elseif statement checks whether the user has won or lost the game. In the game_over_check function, losing is defined as game_over = 1 and winning is defined as game_over = 2. 
    %When the user loses, a sad sound is played and the score is printed.
    [song, samplerate] = audioread('game-over.wav');
    sound(song, samplerate);
elseif game_over == 2
    %When the user wins, a winning fanfare is played and the score is printed.
    [song, samplerate] = audioread('winning.wav');
    sound(song, samplerate);
end
    game_score=0;
    %The user then has the chance to restart the game.
    %Retry button
    uicontrol('Style','pushbutton','String','Try again!','FontSize', 12,'ForegroundColor', 'w', 'FontName', 'Bahnschrift','Position',[100,80,120,60],'BackgroundColor','#f59564', 'Callback', @play_game);
    %Quit button
    uicontrol('Style','pushbutton','String','Quit','FontSize', 12,'ForegroundColor', 'w', 'FontName', 'Bahnschrift','Position',[300,80,120,60],'BackgroundColor','#f59564', 'Callback', @quit);
end

function quit(src,event) % Function definition. src and event are used because this function is called by a button
global game_over
game_over=1;
close % Closes all opened functions
% clc; % Clears command window
end

function [grid]=initial(grid)
%INITIAL generates the initial 2 positions on the grid
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
%NEW chooses a random empty position to set as 2 or 4
%Input grid (matrix)
%Output grid (matrix)

%pos is a random integer indicating position in matrix
    pos=randi(16);
    %loops until value of grid in random position is 0 (i.e. empty)
        while grid(pos)~=0
            pos=randi(16);
        end
    %generates a random number from 0 -> 1    
    chance=rand();
    % 50% of the time it sets the value of random grid position to 2
    if chance<0.5
        grid(pos)=2;
    else
        % 50% of the time it sets the value of random grid position to 4
        grid(pos)=4;
    end
end

function [temp_mat]=shift(grid)
%SHIFT shifts all the values to the left most empty positions
%Input grid (matrix)
%Output grid (matrix)

%generates empty temporary matrix
    temp_mat=zeros(4,4);
    %loops through the rows of matrix
    for x=1:4
        %initialise non_empty as left most position
        free_spot=1;
        %loops through each column of row x in matrix
        for y=1:4
            %checks if position if not empty, moves the filled position to
            %the first available and left most position in column (i.e.
            %free_spot; moves this pointer (free_spot) up by 1 
            if grid(x,y)~=0
                temp_mat(x,free_spot)=grid(x,y);
                free_spot=free_spot+1;
            end
        end
    end
end

function [grid,score]=add(grid)
%ADD Adds up neighbor numbers in a grid if they are equal (note: only if left
%number is equal to its first right neighbor) and increases score by this
%new value
%Input grid (matrix)
%Output grid (matrix) score (double)
%initialises score as 0
    score=0;
    %loops for each row
    for x=1:4
        %loops for the first three column (fourth column has no right
        %neighbor)
        for y=1:3
            %checks if position is filled and is same as the right neighbor
            if grid(x,y)~=0 && (grid(x,y)==grid(x,y+1))
                %doubles the current position
                grid(x,y)=2.*grid(x,y);
                %sets neighbor as 0
                grid(x,y+1)=0;
                %increases score by the new value of position
                score=grid(x,y)+score;
            end
        end
    end
end

function [grid_left,add_score]=left(grid)
%LEFT shifts all positions to the left and performs necessary additions in
%the grid through matrix manipulations (first shift left, then add the
%common elements, then shift left once again for the gaps)
%Input grid (matrix)
%Output grid_left (matrix) add_score (double)

    %temporarily stores the manipulated matrix and the score delta in array
    [grid_left,temp_game_score]=add(shift(grid));
    grid_left=shift(grid_left);
    %checks if new matrix is same as the old matrix (no move could occur if
    %that is the case)
    if isequal(grid_left,grid)==false
        %see func NEW
        grid_left=new(grid_left);
        add_score=temp_game_score;
    else
        grid_left=grid;
        add_score=0;
    end
end

function [grid_down,add_score]=down(grid)
%DOWN shifts all positions down and performs necessary additions in
%the grid through matrix manipulations (first transposes the grid along the
%diagonal, then flips the grid from left to right, performs shift left and
%addition common elements, then shift left once again for the gaps) -> undoes the transpose and flip to return the final matrix
%Input grid (matrix)
%Output grid_down (matrix) add_score (double)

    %temporarily stores the manipulated matrix and the score delta in array
    [grid_down,temp_game_score]=add(shift(fliplr(transpose(grid))));
    grid_down=transpose(fliplr(shift(grid_down)));
    %checks if new matrix is same as the old matrix (no move could occur if
    %that is the case)
    if isequal(grid_down,grid)==false
        %see func NEW
        grid_down=new(grid_down);
        add_score=temp_game_score;
    else
        grid_down=grid;
        add_score=0;
    end
end

function [grid_right,add_score]=right(grid)
%RIGHT shifts all positions to the right and performs necessary additions in
%the grid through matrix manipulations (first flips from left to right, shift left, then add the
%common elements, then shift left once again for the gaps, then flip once again to return to original)

%Input grid (matrix)
%Output grid_right (matrix) add_score (double)
    [grid_right,temp_game_score]=add(shift(fliplr(grid)));
    grid_right=fliplr(shift(grid_right));
    %checks if new matrix is same as the old matrix (no move could occur if
    %that is the case)
    if isequal(grid_right,grid)==false
        %see func NEW
        grid_right=new(grid_right);
        add_score=temp_game_score;
    else
        grid_right=grid;
        add_score=0;
    end
end

function [grid_up,add_score]=up(grid)
%UP shifts all positions up and performs necessary additions in
%the grid through matrix manipulations (first transposes the grid along the
%diagonal, performs shift left and
%addition common elements, then shift left once again for the gaps) then undoes the transpose to return the final matrix
%Input grid (matrix)
%Output grid_up (matrix) add_score (double)

    [grid_up,temp_game_score]=add(shift(transpose(grid)));
    grid_up=transpose(shift(grid_up));
    %checks if new matrix is same as the old matrix (no move could occur if
    %that is the case)
    if isequal(grid_up,grid)==false
        %see func NEW
        grid_up=new(grid_up);
        add_score=temp_game_score;
    else
        grid_up=grid;
        add_score=0;
    end
end

function [game_over]=game_over_check(grid)
%GAME_OVER is called every time a move is made, to check
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
        %Running condition is 0
        game_over=0;
    end
end
