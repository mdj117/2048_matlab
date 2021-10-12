play_game

function play_game(src,event)
global game_score
global game_over
global grid
clf
game_score=0;
game_over=0;
grid=zeros(4,4);
grid=initial(grid);

while game_over~=1
    game_area=uipanel; %Creates a panel container for the ui-grid to be placed in
    Welcome = uicontrol('Style','text','String','Welcome to our Game of 2048. Press Start and use the arrow keys to navigate.','FontSize', 12, 'FontName', 'Bahnschrift','Position',[20,315,160,80]); % Places Welcome text
    Restart = uicontrol('Style','pushbutton','String','Restart Game','FontSize', 12, 'FontName', 'Bahnschrift','Position',[40,170,120,60],'BackgroundColor','white', 'Callback',@play_game); % Places Restart Button that calls the main game function
    Stop = uicontrol('Style','pushbutton','String','Stop','FontSize', 12, 'FontName', 'Bahnschrift','Position',[40,90,120,60],'BackgroundColor','white','Callback',@end_game); % Places Stop Button that calls the endgame function
    Score = uicontrol('Style','text','String',['Score: ',num2str(game_score)],'FontSize', 12, 'FontName', 'Bahnschrift','Position',[40,265,120,20]); % Places text with updated score for each iteration
    %% Iterates through grid to place the all uicontrol elements
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
            %% Given Matlab doesn't allow to vertically center text, we create two uicontrol objects. One for the background and one for the number in the foreground.
            % They are arranged based on their position in grid
            background_tile = uicontrol(game_area,'Style','text','String', '','Position', [100+80*j,400-80*i,75,75],'BackgroundColor',tile_colour);
            number_tile = uicontrol(game_area,'Style','text','String', number, 'ForegroundColor', font_colour,'FontSize', 18, 'FontName', 'Bahnschrift', 'Position',[100+80*j,400-80*i,75,55],'BackgroundColor',tile_colour);
        end
    end
    
    waitforbuttonpress; %cancer
    key=double(get(gcf,'CurrentCharacter'));
    %u 30, l 28, r 29, d 31
    switch key
        case 30
            grid=up(grid);
            game_over=game_over_check(grid);
        case 28
            grid=left(grid);
            game_over=game_over_check(grid);
        case 29
            grid=right(grid);
            game_over=game_over_check(grid);
        case 31
            grid=down(grid);
            game_over=game_over_check(grid);  
        otherwise
            grid=grid;
    end
    delete(game_area) % Deletes the uipanel game_area to clear the figure while not breaking the buttons
    
end
end_game; % Calls end_game once the game is over
end


function end_game(src,event) % Function definition. src and event are used because this function is called by a button
global game_over;
global game_score;
game_over=1; % Sets game_over to 1. User can also call this function before game is over.
clf; % Clears the figure
End_screen = uicontrol('Style','text','String',['Game Over. You scored: ', num2str(game_score), ' points. Well done!'],'FontSize', 35,'ForegroundColor', 'w', 'FontName', 'Bahnschrift','Position',[60,60,400,300],'BackgroundColor','#f59564'); %Endscreen Text
Quit = uicontrol('Style','pushbutton','String','Quit','FontSize', 12, 'FontName', 'Bahnschrift','Position',[300,80,120,60],'BackgroundColor','white', 'Callback', @quit); % Quit button that calls quit function and closes the game if pressed.
Retry = uicontrol('Style','pushbutton','String','Try again!','FontSize', 12, 'FontName', 'Bahnschrift','Position',[100,80,120,60],'BackgroundColor','white', 'Callback', @play_game); % Retry button calls the function of the main game.
end

function quit(src,event) % Function definition. src and event are used because this function is called by a button
close % Closes all opened functions
end

function [grid]=initial(grid)
    pos_1=randi(16);
    pos_2=randi(16);
    while pos_1==pos_2
        pos_1=randi(16);
        pos_2=randi(16);
    end
    positions=[pos_1 pos_2];
    for x=1:2
    chance=rand();
    if chance<0.9
        grid(positions(x))=2;
    else
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

function [grid]=add(grid)
    for x=1:4
        for y=1:3
            if grid(x,y)~=0 && (grid(x,y)==grid(x,y+1))
                grid(x,y)=2.*grid(x,y);
                grid(x,y+1)=0;
                global game_score;
                game_score=grid(x,y)+game_score;
            end
        end
    end
end

function [grid_left]=left(grid)
    grid_left=shift(add(shift(grid)));
    if isequal(grid_left,grid)==false
        grid_left=new(grid_left);
    end
end

function [grid_down]=down(grid)
    grid_down=transpose(fliplr(shift(add(shift(fliplr(transpose(grid)))))));
    if isequal(grid_down,grid)==false
        grid_down=new(grid_down);
    end
end

function [grid_right]=right(grid)
    grid_right=fliplr(shift(add(shift(fliplr(grid)))));
    if isequal(grid_right,grid)==false
        grid_right=new(grid_right);
    end
end

function [grid_up]=up(grid)
    grid_up=transpose(shift(add(shift(transpose(grid)))));
    if isequal(grid_up,grid)==false
        grid_up=new(grid_up);
    end
end

function [game_over]=game_over_check(grid)
    if isequal(grid,up(grid),down(grid),left(grid),right(grid))
        global game_over;
        game_over=1;
    elseif ismember(2048,grid)
        game_over=2;
    else
        game_over=0;
    end
end
